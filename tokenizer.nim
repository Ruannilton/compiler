import token
import scanner
import strutils
import tokenQueue
import types

proc nextInt(scanner :var Scanner): Token =
    var value: int64 = 0
    var c: char = scanner.nextChar()
    
    while isDigit(c):
        let i = ord(c) - ord('0')
        value = value * 10 + i
        c = scanner.nextChar()
    
    scanner.putBack()
    result.initToken(TokenIntValue, value)

proc nextKeyword(scanner :var Scanner): Token =    
    var c: char = scanner.nextChar()
    var buffer: seq[char]

    while isAlphaAscii(c) or isDigit(c) or c == '_':
        buffer.add(c)
        c = scanner.nextChar()

    var id: string = join(buffer, "")

    let tp = getIdentifier(id)

    if tp == TokenIdentifier:
        result.initToken(tp,id)
    else:
        result.initToken(tp)

    scanner.putBack()

proc nextToken(scanner: var Scanner):Token =
    scanner.skipWitheSpace()
    let c : char = scanner.nextChar()

    case c:
        of '+':
            result.initToken(TokenPlus)
        of '-':
            result.initToken(TokenMinus)
        of '*':
            result.initToken(TokenStar)
        of '/':
            result.initToken(TokenSlash)
        of '\0':
            result.initToken(TokenEOF)
        of '{':
            result.initToken(TokenLeftBrace)
        of '}':
            result.initToken(TokenRightBrace)
        of '=':
            let nextc = scanner.nextChar()
            case nextc
                of '=':
                    result.initToken(TokenEquals)
                else:
                    scanner.putBack()
                    result.initToken(TokenAssign)
        of ';':
            result.initToken(TokenSemiColonKeyword)
        of '>':
            let nextc = scanner.nextChar()
            case nextc
                of '=':
                    result.initToken(TokenGreaterEquals)
                else:
                    scanner.putBack()
                    result.initToken(TokenGreater)
        of '<':
            let nextc = scanner.nextChar()
            case nextc
                of '=':
                    result.initToken(TokenLessEquals)
                else:
                    scanner.putBack()
                    result.initToken(TokenLess)
        of '!':
            let nextc = scanner.nextChar()
            case nextc
                of '=':
                    result.initToken(TokenLessEquals)
                else:
                    raise newException(OSError,"Token \'!\' is not valid")
        else:
            scanner.putBack()

            if isDigit(c):
                result = nextInt(scanner)
            elif isAlphaAscii(c) or c == '_':
                result = nextKeyword(scanner)


proc tokenize(scanner: var Scanner):TokenQueue = 
    var tks: TokenQueue

    while not scanner.done():
        var tk: Token = nextToken(scanner)
        
        tks.enqueue(tk)
    
    return tks

export tokenize