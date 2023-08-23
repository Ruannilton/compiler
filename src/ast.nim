import tokenQueue
import token
import types
import treeNode
import symbolTable
import std/strformat

proc getExpressionResultType(ltype:DataType, ntype:NodeType, rtype:DataType):DataType = 
    
    if not expressionToken(ntype.toTokenType()):
        raise newException(OSError, &"Invalid expression token: {ntype}")
    
    if ltype == Void or rtype == Void:
        raise newException(OSError, &"Operation {ntype} betewn {ltype} and {rtype} is invalid")

    case ntype
        of IntNode: return Int
        of CharNode: return Char
        of BoolNode: return Bool
        of  AddNode, SubtractNode, MultiplyNode, DivideNode:
            if ltype == Bool or rtype == Bool: raise newException(OSError, &"Operation {ntype} betewn {ltype} and {rtype} is invalid")
            elif ltype == rtype: return ltype
            elif ltype == Int or rtype == Int: return Int
            else: raise newException(OSError, &"Operation {ntype} betewn {ltype} and {rtype} is invalid")
        of EqualsNode, NotEqualsNode:
            if (ltype == Bool and rtype == Bool) or (ltype != Bool and rtype != Bool): return Bool
            else: raise newException(OSError, &"Operation {ntype} betewn {ltype} and {rtype} is invalid")
        of GreaterNode, LessNode, GreaterEqualsNode, LessEqualsNode:
            if ltype == Bool or rtype == Bool: raise newException(OSError, &"Operation {ntype} betewn {ltype} and {rtype} is invalid")
            elif ltype != Bool and rtype != Bool: return Bool
            else: raise newException(OSError, &"Operation {ntype} betewn {ltype} and {rtype} is invalid")
        else:
            raise newException(OSError, &"Operation {ntype} betewn {ltype} and {rtype} is invalid")

proc isNextToken(queue: TokenQueue, t: TokenType, skip: int = 0):bool = 
    var tk : Token = queue.peak(skip)
    var tkType = tk.getType()
    return tkType == t

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

proc compoundStatement(queue: var TokenQueue,fnId: int): TreeNode
proc parseCallParamsList(queue: var TokenQueue): TreeNode
proc parseFunctionCall(queue: var TokenQueue): TreeNode

proc parseExpression(queue: var TokenQueue, precedence: int = 0): TreeNode =  
    
    let tk = queue.dequeue()
    var nextType :TokenType = tk.getType()

    if not expressionToken(nextType):
        raise newException(OSError, &"Invalid expression token: {nextType}")

    var lvalue : TreeNode = nil

    if tk.getType() == TokenIdentifier:
        if not existSymbol(tk.getIdentifier()):
            raise newException(OSError, &"Symbol not declared: {tk.getIdentifier()}")
        elif isNextToken(queue, TokenLeftParen):
            queue.putBack()
            lvalue = parseFunctionCall(queue)
        else:
            lvalue = createNode(tk)
    else:
        lvalue = createNode(tk)

    nextType = queue.peak().getType()

    if expressionFinal(nextType):
        return lvalue
    
    if not expressionToken(nextType):
        raise newException(OSError, &"Invalid expression token: {nextType}")


    while nextType.getPrecedence() >= precedence:
        discard queue.dequeue()

        var rvalue: TreeNode = parseExpression(queue, nextType.getPrecedence())
        
        let ndType: NodeType = nextType.toNodeType()
        
        let lType = getExpressionResultType(lvalue.getDataType(),ndType,rvalue.getDataType())

        lvalue = createNode(ndType,lvalue,rvalue,lType)

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

    let rvalue = parseExpression(queue)

    if lvalue.getDataType() != rvalue.getDataType():
        raise newException(OSError, &"Can't assign {rvalue.getDataType()} to {lvalue.getDataType()}")

    return createNode(AsignNode,rvalue,lvalue)

proc parseVariableDeclaration(varType: DataType, varIdentifier: Token, queue: var TokenQueue): TreeNode =
    discard addSymbol(varIdentifier.getIdentifier(),Variable,varType)
    
    if isNextToken(queue, TokenSemiColonKeyword):
        return nil
    
    # declaration and asign

    discard queue.dequeue() # discard =
    
    let rvalue = parseExpression(queue)
    let lval = createNode(varIdentifier.getIdentifier())

    if lval.getDataType() != rvalue.getDataType():
        raise newException(OSError, &"Can't assign {rvalue.getDataType()} to {lval.getDataType()}")

    return createNode(AsignNode,rvalue,lval)

proc parseCallParamsList(queue: var TokenQueue): TreeNode = 
   

    var lastNode: TreeNode = nil
    var tmp: TreeNode
    var tkType = queue.peak().getType()
    
    while tkType != TokenRightParen:
        tmp = parseExpression(queue,0)
        
        if tmp != nil:
            if lastNode != nil:
                lastNode = createGlueNode(lastNode,tmp)
            else:
                lastNode = tmp

        while isNextToken(queue,TokenComma):
            discard queue.dequeue() # discard semicolon
        
        tkType = queue.peak().getType()

   

    return lastNode

proc parseFunctionParams(queue: var TokenQueue) =
    
    while not isNextToken(queue, TokenRightParen):
        let typeDef = queue.dequeue().getType().getDataType() # get type 
        let identy = queue.dequeue() # get identifier
        
        discard addSymbol(identy.getIdentifier(),Variable,typeDef)

        if not isNextToken(queue, TokenComma):
            matchNextToken(queue, TokenRightParen)
        else:
            discard queue.dequeue() # discard ,

proc parseFunctionDeclaration(varType: DataType, varIdentifier: Token, queue: var TokenQueue): TreeNode =
    let fnId = addSymbol(varIdentifier.getIdentifier(),Function,varType)


    matchNextToken(queue, TokenLeftParen)
    discard queue.dequeue()

    # parse function parameters
    parseFunctionParams(queue)

    matchNextToken(queue, TokenRightParen)
    discard queue.dequeue()
    
    let fnBody = compoundStatement(queue,fnId)
    return createNode(varIdentifier.getIdentifier(),fnBody)

proc parseFunctionCall(queue: var TokenQueue): TreeNode = 
    let tk = queue.dequeue()

    if not existSymbol(tk.getIdentifier()):
        raise newException(OSError, &"Symbol not declared: {tk.getIdentifier()}")
    
    matchNextToken(queue,TokenLeftParen)
    discard queue.dequeue() # discard (
    
    let fnBody: TreeNode = parseCallParamsList(queue)

    matchNextToken(queue,TokenRightParen)
    discard queue.dequeue() # discard )

    return createNode(tk.getIdentifier(),fnBody, FunctionCallNode)

proc parseDeclaration(queue: var TokenQueue):TreeNode =
    matchNextToken(queue,@[TokenIntType,TokenBoolType,TokenCharType,TokenVoidType])

    let typeDef = queue.dequeue().getType().getDataType() # get type 
    let identy = queue.dequeue() # get identifier
   
    # varibale declaration
    if isNextToken(queue,TokenAssign) or isNextToken(queue, TokenSemiColonKeyword):
        return parseVariableDeclaration(typeDef,identy,queue)
    
    # function declaration
    if isNextToken(queue,TokenLeftParen):
        return parseFunctionDeclaration(typeDef,identy,queue)

    return nil

proc parseIfStatement(queue: var TokenQueue, fnId: int): TreeNode =
    matchNextToken(queue,TokenIf)
    discard queue.dequeue() # discard if

    matchNextToken(queue,TokenLeftParen)
    discard queue.dequeue() # discard (

    let exp = parseExpression(queue)

    matchNextToken(queue,TokenRightParen)
    discard queue.dequeue() # discard )

    let whenTrue = compoundStatement(queue,fnId)
    var whenFalse: TreeNode = nil

    if isNextToken(queue,TokenElse):
        discard queue.dequeue() # discard else
        whenFalse = compoundStatement(queue,fnId)

    result = createNode(exp,whenTrue,whenFalse)

proc parseWhileStatement(queue: var TokenQueue, fnId: int): TreeNode =
    matchNextToken(queue,TokenWhile)
    discard queue.dequeue() # discard if

    matchNextToken(queue,TokenLeftParen)
    discard queue.dequeue() # discard (

    let exp = parseExpression(queue)

    matchNextToken(queue,TokenRightParen)
    discard queue.dequeue() # discard )

    let whenTrue = compoundStatement(queue,fnId)
   

    result = createNode(WhileNode, exp, whenTrue)

proc parseReturnStatement(queue: var TokenQueue, fnId :int): TreeNode =
    matchNextToken(queue,TokenReturn)
    discard queue.dequeue() # discard return

    let exp = parseExpression(queue)
    let dt = exp.getDataType()
    
    let symbolData = getSymbol(fnId)

    if symbolData.getType() != Function:
        raise newException(OSError,&"Can not return ouside a function")

    if dt == Void or dt == None:
        raise newException(OSError,&"return type can not be {dt}")
    
    if symbolData.getDataType() != dt:
        raise newException(OSError,&"Can not return a {dt} to a {symbolData.getDataType()} function")

    return createNode(ReturnNode, exp, dt)

proc parseStatement(queue: var TokenQueue, fnId: int): TreeNode =

    let tk : Token = queue.peak()
    let tkType = tk.getType();
    
    case tkType
    of TokenLeftBrace:
        return compoundStatement(queue, fnId)

    of TokenIntType,TokenBoolType,TokenCharType,TokenVoidType:
        let decl = parseDeclaration(queue)
        result = decl
        if isNextToken(queue,TokenSemiColonKeyword):
            discard queue.dequeue() # discard semicolon
    
    of TokenIdentifier:
        if isNextToken(queue, TokenAssign, 1):
            result = parseAssign(queue)
        elif isNextToken(queue, TokenLeftParen, 1):
            result = parseFunctionCall(queue)
        else:
            raise newException(OSError,&"wrong program at {tk.getLine()}: {tk}, {queue.peak(1)}")

        matchNextToken(queue,TokenSemiColonKeyword)
        discard queue.dequeue() # discard semicolon
    of TokenIf:
        result = parseIfStatement(queue,fnId)
    of TokenWhile:
        result = parseWhileStatement(queue,fnId)
    of TokenReturn:
        result = parseReturnStatement(queue, fnId)
    else:
        raise newException(OSError, &"wrong program at {tk.getLine()}: {tkType}")

proc parseStatementList(queue: var TokenQueue, fnId: int): TreeNode = 
    var lastNode: TreeNode = nil
    var tmp: TreeNode
    var tkType = queue.peak().getType()
    
    while tkType != TokenRightBrace and tkType != TokenEOF:
    
        if tkType == TokenLeftBrace:
            tmp = compoundStatement(queue,fnId)
        else:
            tmp = parseStatement(queue, fnId)
        
        if tmp != nil:
            if lastNode != nil:
                lastNode = createGlueNode(lastNode,tmp)
            else:
                lastNode = tmp

        while isNextToken(queue,TokenSemiColonKeyword):
            discard queue.dequeue() # discard semicolon
        
        tkType = queue.peak().getType()
    return lastNode

proc compoundStatement(queue: var TokenQueue, fnId: int): TreeNode = 
    matchNextToken(queue,TokenLeftBrace)
    discard queue.dequeue() # skip {
    
    let lastNode : TreeNode = parseStatementList(queue, fnId)
    
    matchNextToken(queue,TokenRightBrace)
    discard queue.dequeue() # skip }

    return createNode(CompoundNode,lastNode)

proc syntaxTree(queue: var TokenQueue): TreeNode =

    let lastNode: TreeNode = parseStatementList(queue, 0)

    return createNode(RootNode,lastNode)




export syntaxTree