import tokenQueue
import token
import types
import treeNode
import symbolTable
import std/strformat

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

proc parseStatement(queue: var TokenQueue): TreeNode =

    let tk : Token = queue.peak()

    let tkType = tk.getType();


    if isDeclaration(tkType):
        let decl = parseDeclaration(queue)
        result = decl
        discard queue.dequeue() # discard semicolon
    
    elif tkType == TokenIdentifier:
        result = parseAssign(queue)
        discard queue.dequeue() # discard semicolon
    
    else:
        raise newException(OSError, "wrong program")

proc syntaxTree(queue: var TokenQueue): seq[TreeNode] =
    var expresions : seq[TreeNode]
    
    while not queue.empty():
        let exp : TreeNode = parseStatement(queue)
        
        if exp == nil:
            continue

        echo debugNode(exp)
        expresions.add(exp)

        if queue.peak().getType() == TokenEOF:
            break

    return expresions





export syntaxTree