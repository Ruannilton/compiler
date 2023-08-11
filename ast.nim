import tokenQueue
import token
import types
import treeNode
import symbolTable
import std/strformat


proc isNextToken(queue: TokenQueue, t: TokenType):bool = 
    var tk : Token = queue.peak()
    var tkType = tk.getType()
    return tkType == t

proc isNextToken(queue: TokenQueue, t: seq[TokenType]):bool = 
    var tk : Token = queue.peak()
    var tkType = tk.getType()
    return tkType in t

proc matchNextToken(queue: TokenQueue, t: TokenType) = 
    var tk : Token = queue.peak()
    var tkType = tk.getType()

    if tkType != t:
        raise newException(OSError,&"{t} expected but got {tkType}")

proc matchNextToken(queue: TokenQueue, t: seq[TokenType]) = 
    var tk : Token = queue.peak()
    var tkType = tk.getType()
    let r = tkType in t
    if not r:
        raise newException(OSError,&"{t} expected but got {tkType}")

proc compoundStatement(queue: var TokenQueue): TreeNode

proc parseExpression(queue: var TokenQueue, precedence: int64 = 0): TreeNode =  
    
    let tk = queue.dequeue()
    var nextType :TokenType = tk.getType()

    if not expressionToken(nextType):
        raise newException(OSError, &"Invalid expression token: {nextType}")

    if tk.getType() == TokenIdentifier and not existSymbol(tk.getIdentifier()):
        raise newException(OSError, &"Symbol not declared: {tk.getIdentifier()}")

    var lvalue : TreeNode = createNode(tk)
    nextType = queue.peak().getType()

    if expressionFinal(nextType):
        return lvalue
    
    if not expressionToken(nextType):
        raise newException(OSError, &"Invalid expression token: {nextType}")

    let prec = getPrecedence(nextType) 

    while prec >= precedence:
        discard queue.dequeue()

        var rvalue: TreeNode = parseExpression(queue, prec)
        
        let ndType:NodeType = tokenToNode(nextType)

        lvalue = createNode(ndType,0,lvalue,rvalue)

        nextType = queue.peak().getType()

        if expressionFinal(nextType):
            return lvalue

    return lvalue

proc parseAssign(queue: var TokenQueue):TreeNode =
    let tk = queue.dequeue()

    if not existSymbol(tk.getIdentifier()):
        raise newException(OSError, &"Symbol not declared: {tk.getIdentifier()}")

    let lvalue : TreeNode = createNode(tk)

    matchNextToken(queue,TokenAssign)
    discard queue.dequeue() # discard =

    let rvalue = parseExpression(queue,0)

    return createNode(Asign,lvalue,rvalue)

proc parseDeclaration(queue: var TokenQueue):TreeNode =
    let types = @[TokenIntKeyword,TokenStringKeyword,TokenBoolKeyword]
    matchNextToken(queue,types)
    discard queue.dequeue() # discard type

    let lvalue = queue.dequeue()

    discard addSymbol(lvalue.getIdentifier())

    let next = queue.peak()

    if next.getType() == TokenAssign:
        discard queue.dequeue()
        
        let rvalue = parseExpression(queue,0)

        return createNode(Asign,createNode(lvalue),rvalue)
    
    return nil

proc parseIfStatement(queue: var TokenQueue): TreeNode =
    matchNextToken(queue,TokenIf)
    discard queue.dequeue() # discard if

    matchNextToken(queue,TokenLeftParen)
    discard queue.dequeue() # discard (

    let exp = parseExpression(queue)

    matchNextToken(queue,TokenRightParen)
    discard queue.dequeue() # discard )

    let whenTrue = compoundStatement(queue)
    var whenFalse: TreeNode = nil

    if isNextToken(queue,TokenElse):
        discard queue.dequeue() # discard else
        whenFalse = compoundStatement(queue)

    result = createNode(IfNode,0,whenTrue,whenFalse,exp)

proc parseWhileStatement(queue: var TokenQueue): TreeNode =
    matchNextToken(queue,TokenWhile)
    discard queue.dequeue() # discard if

    matchNextToken(queue,TokenLeftParen)
    discard queue.dequeue() # discard (

    let exp = parseExpression(queue)

    matchNextToken(queue,TokenRightParen)
    discard queue.dequeue() # discard )

    let whenTrue = compoundStatement(queue)
   

    result = createNode(WhileNode,0,whenTrue,nil,mid = exp)

proc parseStatement(queue: var TokenQueue): TreeNode =

    let tk : Token = queue.peak()

    let tkType = tk.getType();

    if tkType == TokenLeftBrace:
        return compoundStatement(queue)

    elif isDeclaration(tkType):
        let decl = parseDeclaration(queue)
        result = decl
        matchNextToken(queue,TokenSemiColonKeyword)
        discard queue.dequeue() # discard semicolon
    
    elif tkType == TokenIdentifier:
        result = parseAssign(queue)
        matchNextToken(queue,TokenSemiColonKeyword)
        discard queue.dequeue() # discard semicolon
    elif tkType == TokenIf:
        result = parseIfStatement(queue)
    elif tkType == TokenWhile:
        result = parseWhileStatement(queue)
    else:
        raise newException(OSError, &"wrong program: {tkType}")

proc compoundStatement(queue: var TokenQueue): TreeNode = 
    matchNextToken(queue,TokenLeftBrace)
    discard queue.dequeue() # skip {
    
    var lastNode: TreeNode = nil
    var tmp: TreeNode
    var tkType = queue.peak().getType()
    
    while tkType != TokenRightBrace:
        
        if tkType == TokenEOF:
            raise newException(OSError, "Missing }")

        if tkType == TokenLeftBrace:
            tmp = compoundStatement(queue)
        else:
            tmp = parseStatement(queue)
        
        if tmp != nil:
            if lastNode != nil:
                lastNode = createNode(GlueStatement,tmp,lastNode)
            else:
                lastNode = tmp

        tkType = queue.peak().getType()
    
    matchNextToken(queue,TokenRightBrace)
    discard queue.dequeue() # skip }

    return createNode(CompoundStatement,nil,lastNode)

proc syntaxTree(queue: var TokenQueue): TreeNode =
    var lastNode: TreeNode = nil
    var tmp: TreeNode
    var tkType = queue.peak().getType()
    
    while tkType != TokenEOF:
        case tkType
            of TokenLeftBrace:
                tmp = compoundStatement(queue)
            of TokenIf:
                tmp = parseIfStatement(queue)
            of TokenWhile:
                tmp = parseWhileStatement(queue)
            else:
                tmp = parseStatement(queue)
        
        if tmp != nil:
            if lastNode != nil:
                lastNode = createNode(GlueStatement,tmp,lastNode)
            else:
                lastNode = tmp

        tkType = queue.peak().getType()

    return createNode(RootNode,nil,lastNode)




export syntaxTree