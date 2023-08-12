import std/strformat
import std/tables
import types

let reservedKeys: Table[string,TokenType] = {
 "int": TokenIntType,
 "bool": TokenBoolType,
 "char": TokenCharType,
 "true": TokenTrueKeyword,
 "false": TokenFalseKeyword,
 "if": TokenIf,
 "else": TokenElse,
 "while": TokenWhile
}.toTable()

type Token = object
    line: int
    index: int
    case tokenType: TokenType
    of TokenIntValue: 
        intVal: int
    of TokenTrueKeyword,TokenFalseKeyword,TokenBoolValue: 
        boolVal: bool
    of TokenCharValue: 
        charVal: char
    of TokenIdentifier: 
        name: string
    else:
        discard

proc createToken(tp: TokenType, value: int, line,index:int): Token =
    var tk = Token(tokenType: tp)
    tk.intVal = value
    tk.line = line
    tk.index = index
    result = tk

proc createToken(tp: TokenType, value: bool,line,index:int): Token = 
    var tk = Token(tokenType: tp)
    tk.boolVal = value
    tk.line = line
    tk.index = index
    result = tk

proc createToken(tp: TokenType, value: char,line,index:int): Token = 
    var tk = Token(tokenType: tp)
    tk.charVal = value
    tk.line = line
    tk.index = index
    result = tk

proc createToken(tp: TokenType, name: string,line,index:int): Token = 
    var tk = Token(tokenType: tp)
    tk.name = name
    tk.line = line
    tk.index = index
    result = tk

proc createToken(tp: TokenType, line, index:int): Token = 
    var tk = Token(tokenType: tp)
    tk.line = line
    tk.index = index
    result = tk



proc getType(self: Token): TokenType = self.tokenType

proc getIntValue(self: Token): int = self.intVal
proc getBoolValue(self: Token): bool = self.boolVal
proc getCharValue(self: Token): char = self.charVal

proc getIdentifier(self: Token): string = self.name

proc getIdentifierType(name: string): TokenType =
    if reservedKeys.hasKey(name):
        result = reservedKeys[name]
    else:
        result = TokenIdentifier

proc `$`(self: Token): string =
    case self.tokenType
        of TokenIntValue:
            result = &"[{self.tokenType}, {self.intVal}]"
        of TokenBoolValue:
            result = &"[{self.tokenType}, {self.boolVal}]"
        of TokenCharValue:
            result = &"[{self.tokenType}, {self.charVal}]"
        of TokenIdentifier:
            result = &"[{self.tokenType}, {self.name}]"
        else:
            result = &"[{self.tokenType}]"

export Token,`$`,getType,getIntValue,getBoolValue,getCharValue,getIdentifier,getIdentifier,createToken,getIdentifierType