import token
import scanner
import strutils
import tokenQueue
import types
import std/strformat

proc parseChar(scanner :var Scanner): Token =
    let line = scanner.getLine()
    let index = scanner.getIndex()
    var value: char = scanner.nextChar()
    var nextC: char = scanner.nextChar()
    
    if nextC != '\'':
        raise newException(OSError,&"\' expected, got {nextC}")

    return createToken(TokenCharValue, value,line,index)  

proc parseInt(scanner :var Scanner): Token =
    var value: int = 0
    var c: char = scanner.nextChar()
    
    let line = scanner.getLine()
    let index = scanner.getIndex()

    while isDigit(c):
        let i = ord(c) - ord('0')
        value = value * 10 + i
        c = scanner.nextChar()
    
    scanner.putBack()
    result = createToken(TokenIntValue, value,line,index)

proc parseKeyword(scanner :var Scanner): Token =    
    var c: char = scanner.nextChar()
    var buffer: seq[char]

    let line = scanner.getLine()
    let index = scanner.getIndex()

    while isAlphaAscii(c) or isDigit(c) or c == '_':
        buffer.add(c)
        c = scanner.nextChar()

    let name: string = join(buffer, "")

    let tp:TokenType = getIdentifierType(name)

    case tp
    of TokenIdentifier:
        result = createToken(TokenIdentifier,name,line,index)
    of TokenTrueKeyword:
        result = createToken(TokenBoolValue,true,line,index)
    of TokenFalseKeyword:
        result = createToken(TokenBoolValue,false,line,index)
    else:
        result = createToken(tp,line,index)
    scanner.putBack()

proc nextToken(scanner: var Scanner):Token =
    scanner.skipWitheSpace()
    
    let c : char = scanner.nextChar()

    let line = scanner.getLine()
    let index = scanner.getIndex()

    case c:
        of '+':
            result = createToken(TokenPlus,line,index)
        of '-':
            result = createToken(TokenMinus,line,index)
        of '*':
            result = createToken(TokenStar,line,index)
        of '/':
            result = createToken(TokenSlash,line,index)
        of '\0':
            result = createToken(TokenEOF,line,index)
        of '{':
            result = createToken(TokenLeftBrace,line,index)
        of '}':
            result = createToken(TokenRightBrace,line,index)
        of '(':
            result = createToken(TokenLeftParen,line,index)
        of ')':
            result = createToken(TokenRightParen,line,index)
        of '\'':
            result = parseChar(scanner)
        of '=':
            let nextc = scanner.nextChar()
            case nextc
                of '=':
                    result = createToken(TokenEquals,line,index)
                else:
                    scanner.putBack()
                    result = createToken(TokenAssign,line,index)
        of ';':
            result = createToken(TokenSemiColonKeyword,line,index)
        of '>':
            let nextc = scanner.nextChar()
            case nextc
                of '=':
                    result = createToken(TokenGreaterEquals,line,index)
                else:
                    scanner.putBack()
                    result = createToken(TokenGreater,line,index)
        of '<':
            let nextc = scanner.nextChar()
            case nextc
                of '=':
                    result = createToken(TokenLessEquals,line,index)
                else:
                    scanner.putBack()
                    result = createToken(TokenLess,line,index)
        of '!':
            let nextc = scanner.nextChar()
            case nextc
                of '=':
                    result = createToken(TokenLessEquals,line,index)
                else:
                    raise newException(OSError,"Token \'!\' is not valid")
        of ',':
            result = createToken(TokenComma,line,index)
        else:
            scanner.putBack()

            if isDigit(c):
                result = parseInt(scanner)
            elif isAlphaAscii(c) or c == '_':
                result = parseKeyword(scanner)
            else:
                echo c, line
                raise newException(OSError,&"Failed to parse token at line {line} and position {index}")



proc tokenize(scanner: var Scanner):TokenQueue = 
    var tks: TokenQueue
    

    while not scanner.done():
        var tk: Token = nextToken(scanner)
        if tk.getType() == TokenEOF: break
        tks.enqueue(tk)
    
    let line = scanner.getLine()
    let index = scanner.getIndex()
    let teof = createToken(TokenEOF,line,index)
    tks.enqueue(teof)

    

    

    return tks

export tokenize