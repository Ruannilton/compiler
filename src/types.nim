import std/tables
import std/strformat

type TokenType = enum
    TokenEOF
    TokenMinus
    TokenPlus
    TokenStar
    TokenSlash
    TokenAssign
    TokenIntValue
    TokenBoolValue
    TokenCharValue
    TokenIdentifier
    TokenTrueKeyword
    TokenFalseKeyword
    TokenSemiColonKeyword
    TokenEquals
    TokenNotEquals
    TokenGreater
    TokenLess
    TokenGreaterEquals
    TokenLessEquals
    TokenLeftBrace
    TokenRightBrace
    TokenIf
    TokenElse
    TokenLeftParen
    TokenRightParen
    TokenWhile
    TokenIntType
    TokenBoolType
    TokenCharType
    TokenVoidType
    TokenReturn
    TokenComma

type NodeType = enum
    RootNode
    AddNode
    SubtractNode
    MultiplyNode
    DivideNode
    IntNode
    BoolNode
    AsignNode
    CharNode
    IdentifierNode
    EqualsNode
    NotEqualsNode
    GreaterNode
    LessNode
    GreaterEqualsNode
    LessEqualsNode
    CompoundNode
    GlueNode
    IfNode
    WhileNode
    CastNode
    FunctionNode
    ReturnNode
    FunctionCallNode

type DataType = enum
    None,
    Void,
    Int,
    Char,
    Bool

type SymbolType = enum
    Variable
    Function

let mapTokenToNode: Table[TokenType,NodeType] = {
    TokenMinus: SubtractNode,
    TokenPlus: AddNode,
    TokenStar: MultiplyNode,
    TokenSlash: DivideNode,
    TokenIntValue: IntNode,
    TokenIdentifier: IdentifierNode,
    TokenAssign: AsignNode,
    TokenEquals: EqualsNode,
    TokenNotEquals: NotEqualsNode,
    TokenGreater: GreaterNode,
    TokenLess: LessNode,
    TokenGreaterEquals: GreaterEqualsNode,
    TokenLessEquals: LessEqualsNode,
    TokenIf: IfNode,
    TokenWhile: WhileNode
}.toTable()

let mapNodeToToken: Table[NodeType, TokenType] = {
  SubtractNode: TokenMinus,
  AddNode: TokenPlus,
  MultiplyNode: TokenStar,
  DivideNode: TokenSlash,
  IntNode: TokenIntValue,
  IdentifierNode: TokenIdentifier,
  AsignNode: TokenAssign,
  EqualsNode: TokenEquals,
  NotEqualsNode: TokenNotEquals,
  GreaterNode: TokenGreater,
  LessNode: TokenLess,
  GreaterEqualsNode: TokenGreaterEquals,
  LessEqualsNode: TokenLessEquals,
  IfNode: TokenIf,
  WhileNode: TokenWhile
}.toTable()

let opPrecedence: Table[NodeType,int] = {
    IntNode,IdentifierNode: 0,
    SubtractNode,AddNode: 10,
    MultiplyNode,DivideNode,EqualsNode,NotEqualsNode: 20,
    GreaterNode,LessNode,GreaterEqualsNode,LessEqualsNode: 40
}.toTable()

let opToString: Table[TokenType,string] = {
    TokenMinus: "-",
    TokenPlus: "+",
    TokenStar: "*",
    TokenSlash: "/",
    TokenAssign: "=",
    TokenEquals: "==",
    TokenNotEquals: "!=",
    TokenGreaterEquals: ">=",
    TokenLessEquals: "<=",
    TokenGreater: ">", 
    TokenLess: "<", 
}.toTable()

proc expressionFinal(tp: TokenType):bool = 
    return tp in [TokenSemiColonKeyword,TokenLeftParen,TokenRightParen,TokenComma]

proc expressionToken(tp: TokenType):bool = 
    return tp in [
        TokenMinus,
        TokenPlus,
        TokenStar,
        TokenSlash,
        TokenIntValue,
        TokenCharValue,
        TokenBoolValue,
        TokenIdentifier,
        TokenTrueKeyword,
        TokenFalseKeyword,
        TokenEquals,
        TokenNotEquals,
        TokenGreater,
        TokenLess,
        TokenGreaterEquals,
        TokenLessEquals,
    ]


proc toNodeType(self: TokenType): NodeType =
    if mapTokenToNode.hasKey(self):
        return mapTokenToNode[self]
    else:
        raise newException(OSError, &"Cannot convert {self} to NodeType")

proc toTokenType(self: NodeType): TokenType =
    if mapNodeToToken.hasKey(self):
        return mapNodeToToken[self]
    else:
        raise newException(OSError, &"Cannot convert {self} to TokenType")

proc getPrecedence(self: NodeType): int = 
    if opPrecedence.hasKey(self):
        return opPrecedence[self]
    else:
        raise newException(OSError, &"NodeType {self} has no precedence rule")

proc getPrecedence(self: TokenType): int = self.toNodeType().getPrecedence()

proc getSymbol(self: TokenType):string = 
    if opToString.hasKey(self):
        return opToString[self]
    else:
        raise newException(OSError, &"{self} does not contains a symbol")

proc hasSymbol(self: TokenType):bool = opToString.hasKey(self)

proc getSymbol(self: NodeType):string = getSymbol(self.toTokenType())

proc hasSymbol(self: NodeType):bool = 
    if not mapNodeToToken.hasKey(self): return false
    return opToString.hasKey(mapNodeToToken[self])

proc getDataType(self: TokenType): DataType = 
    case self
    of TokenIntType, TokenIntValue: return Int
    of TokenBoolType, TokenBoolValue: return Bool
    of TokenCharType, TokenCharValue: return Char
    of TokenVoidType: return Void
    else: return None

export TokenType,NodeType,DataType,SymbolType,getPrecedence,expressionFinal,expressionToken,getSymbol,hasSymbol,toNodeType,toTokenType,getDataType