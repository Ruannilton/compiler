import std/tables
import std/strformat

type TokenType = enum
    TokenEOF,
    TokenMinus,
    TokenPlus,
    TokenStar,
    TokenSlash,
    TokenAssign,
    TokenIntValue,
    TokenIdentifier,
    TokenIntKeyword,
    TokenStringKeyword,
    TokenBoolKeyword,
    TokenTrueKeyword,
    TokenFalseKeyword,
    TokenSemiColonKeyword,
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

type NodeType = enum
    RootNode,
    AddOperator,
    SubtractOperator,
    MultiplyOperator,
    DivideOperator,
    IntValue,
    Asign,
    Identifier,
    EqualsOperator,
    NotEqualsOperator,
    GreaterOperator,
    LessOperator,
    GreaterEqualsOperator,
    LessEqualsOperator,
    CompoundStatement,
    GlueStatement,
    IfNode

var mapTokenToNode: Table[TokenType,NodeType] = initTable[TokenType,NodeType]()
mapTokenToNode[TokenMinus] = SubtractOperator
mapTokenToNode[TokenPlus] = AddOperator
mapTokenToNode[TokenStar] = MultiplyOperator
mapTokenToNode[TokenSlash] = DivideOperator
mapTokenToNode[TokenIntValue] = IntValue

mapTokenToNode[TokenIdentifier] = Identifier
mapTokenToNode[TokenAssign] = Asign
mapTokenToNode[TokenEquals] = EqualsOperator
mapTokenToNode[TokenNotEquals] = NotEqualsOperator
mapTokenToNode[TokenGreater] = GreaterOperator
mapTokenToNode[TokenLess] = LessOperator
mapTokenToNode[TokenGreaterEquals] = GreaterEqualsOperator
mapTokenToNode[TokenLessEquals] = LessEqualsOperator

var opPrecedence: Table[NodeType,int64] = initTable[NodeType,int64]()
opPrecedence[IntValue] = 0
opPrecedence[Identifier] = 0
opPrecedence[SubtractOperator] = 10
opPrecedence[AddOperator] = 10
opPrecedence[MultiplyOperator] = 20
opPrecedence[DivideOperator] = 20
opPrecedence[EqualsOperator] = 20
opPrecedence[NotEqualsOperator] = 20
opPrecedence[GreaterOperator] = 40
opPrecedence[LessOperator] = 40
opPrecedence[GreaterEqualsOperator] = 40
opPrecedence[LessEqualsOperator] = 40

proc expressionFinal(tp: TokenType):bool = 
    return tp in [TokenSemiColonKeyword,TokenLeftParen,TokenRightParen]

proc expressionToken(tp: TokenType):bool = 
    return tp in [
    TokenMinus,
    TokenPlus,
    TokenStar,
    TokenSlash,
    TokenIntValue,
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

proc tokenToNode(tp: TokenType):NodeType =
    if mapTokenToNode.hasKey(tp):
        return mapTokenToNode[tp]
    else:
        raise newException(OSError, &"Cannot convert {tp} to NodeType")

proc getPrecedence(op: NodeType):int64 = 
    if opPrecedence.hasKey(op):
        return opPrecedence[op]
    else:
        raise newException(OSError, &"NodeType {op} has no precedence rule")

proc getPrecedence(op: TokenType):int64 =  getPrecedence(tokenToNode(op))


proc isDeclaration(op: TokenType): bool =
    return op in [ TokenIntKeyword, TokenStringKeyword, TokenBoolKeyword]

export TokenType,NodeType,tokenToNode,getPrecedence,isDeclaration,expressionFinal,expressionToken