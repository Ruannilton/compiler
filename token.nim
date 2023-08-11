import std/strformat
import std/tables
import types

var reservedKeys: Table[string,TokenType] = initTable[string, TokenType]()

reservedKeys["int"] = TokenIntKeyword
reservedKeys["bool"] = TokenBoolKeyword
reservedKeys["string"] = TokenStringKeyword
reservedKeys["true"] = TokenTrueKeyword
reservedKeys["false"] = TokenFalseKeyword
reservedKeys["if"] = TokenIf
reservedKeys["else"] = TokenElse

type Token = object
    tokenType: TokenType
    value: int64
    name: string

proc initToken(self: var Token, t: TokenType, value: int64) =
    self.tokenType = t
    self.value = value

proc initToken(self: var Token, t: TokenType, name: string) =
    self.tokenType = t
    self.name = name

proc initToken(self: var Token, t: TokenType) =
    self.tokenType = t

proc getType(self: Token): TokenType = self.tokenType

proc getValue(self: Token): int64 = self.value

proc getIdentifier(self: Token): string = self.name

proc getIdentifier(name: string): TokenType =
    if reservedKeys.hasKey(name):
        result = reservedKeys[name]
    else:
        result = TokenIdentifier

proc `$`(self: Token): string =
    if self.tokenType == TokenIntValue:
        result = &"[{self.tokenType}, {self.value}]"
    elif self.tokenType == TokenIdentifier:
        result = &"[{self.tokenType}, {self.name}]"
    else:
        result = &"[{self.tokenType}]"

export Token,initToken,`$`,getType,getValue,getIdentifier,getIdentifier