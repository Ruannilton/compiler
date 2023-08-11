import tokenQueue
import token
import types
import treeNode
import symbolTable
import std/strformat




proc compoundStatement(queue: var TokenQueue): TreeNode

proc parseExpression(queue: var TokenQueue, precedence: int64 = 0): TreeNode =  
    
    let tk = queue.dequeue()

    if tk.getType() == TokenIdentifier and not existSymbol(tk.getIdentifier()):
        raise newException(OSError, &"Symbol not declared: {tk.getIdentifier()}")

    var lvalue : TreeNode = createNode(tk)
    
    var nextType :TokenType = queue.peak().getType()

    if nextType == TokenSemiColonKeyword:
        return lvalue
    
    let prec = getPrecedence(nextType) 

    while prec >= precedence:
        discard queue.dequeue()

        var rvalue: TreeNode = parseExpression(queue, prec)
        
        let ndType:NodeType = tokenToNode(nextType)

        lvalue = createNode(ndType,0,lvalue,rvalue)

        nextType = queue.peak().getType()

        if nextType == TokenSemiColonKeyword:
            return lvalue

    return lvalue

proc parseAssign(queue: var TokenQueue):TreeNode =
    let tk = queue.dequeue()

    if not existSymbol(tk.getIdentifier()):
        raise newException(OSError, &"Symbol not declared: {tk.getIdentifier()}")

    let lvalue : TreeNode = createNode(tk)

    discard queue.dequeue() # discard =

    let rvalue = parseExpression(queue,0)

    return createNode(Asign,lvalue,rvalue)

proc parseDeclaration(queue: var TokenQueue):TreeNode =
    discard queue.dequeue()

    let lvalue = queue.dequeue()

    discard addSymbol(lvalue.getIdentifier())

    let next = queue.peak()

    if next.getType() == TokenAssign:
        discard queue.dequeue()
        
        let rvalue = parseExpression(queue,0)

        return createNode(Asign,createNode(lvalue),rvalue)
    
    return nil

proc parseStatement(queue: var TokenQueue): TreeNode =

    let tk : Token = queue.peak()

    let tkType = tk.getType();

    if tkType == TokenLeftBrace:
        return compoundStatement(queue)

    elif isDeclaration(tkType):
        let decl = parseDeclaration(queue)
        result = decl
        discard queue.dequeue() # discard semicolon
    
    elif tkType == TokenIdentifier:
        result = parseAssign(queue)
        discard queue.dequeue() # discard semicolon
    
    else:
        raise newException(OSError, "wrong program")

proc compoundStatement(queue: var TokenQueue): TreeNode = 
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
    
    discard queue.dequeue() # skip }

    return createNode(CompoundStatement,nil,lastNode)

proc syntaxTree(queue: var TokenQueue): TreeNode =
    var lastNode: TreeNode = nil
    var tmp: TreeNode
    var tkType = queue.peak().getType()
    
    while tkType != TokenEOF:
        
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

    return createNode(RootNode,nil,lastNode)




export syntaxTree