import std/tables
import std/strformat
import token
import types
import symbolTable

type TreeNode = ref object 
    left, right : TreeNode
    nodeType : NodeType
    value: int64
    id: int64

var opToString: Table[NodeType,string] = initTable[NodeType,string]()

opToString[SubtractOperator] = "-"
opToString[AddOperator] = "+"
opToString[MultiplyOperator] = "*"
opToString[DivideOperator] = "/"
opToString[Asign] = "="

opToString[EqualsOperator] = "=="
opToString[NotEqualsOperator] = "!="
opToString[GreaterEqualsOperator] = ">="
opToString[LessEqualsOperator] = "<="
opToString[GreaterOperator] = ">"
opToString[LessOperator] = "<"

proc printNode(root:TreeNode, space: var int64, level: int64) = 
    var rootValue : string = ""

    if root == nil:
        return

    if root.nodeType == IntValue:
        rootValue = &"{root.value}"
    elif root.nodeType == Identifier:
        rootValue = &"{getSymbolName(root.id)}"
    else:
        rootValue = opToString[root.nodeType]

    space += 2

    printNode(root.right, space, level + 1)

    stdout.write('\n')
    for _ in 2..space:
       stdout.write(' ')
    
    echo &"[{level}]", rootValue 

    printNode(root.left, space, level + 1)

proc printNode(root:TreeNode) =
    var space: int64 = 0
    var level: int64  = 0
    printNode(root, space, level)


proc debugNode(root:TreeNode): string =
    if root.nodeType == IntValue:
        return &"{root.value}"

    if root.nodeType == Identifier:
        return getSymbolName(root.id)

    if root.nodeType == Asign:
        return &"{debugNode(root.left)} = {debugNode(root.right)}"

    let op = opToString[root.nodeType]

    return &"({debugNode(root.left)} {op} {debugNode(root.right)})"

proc createNode(nodeType: NodeType, value :int64, left,right: TreeNode):TreeNode =
    var tmp: TreeNode = new(TreeNode)
    tmp.nodeType = nodeType
    tmp.value = value
    tmp.left = left
    tmp.right = right
    return tmp

proc createNode(nodeType: NodeType, identifier :string, left,right: TreeNode):TreeNode =
    var tmp: TreeNode = new(TreeNode)
    tmp.nodeType = nodeType
    tmp.id = getSymbolId(identifier)
    tmp.left = left
    tmp.right = right
    return tmp
   
proc createNode(nodeType: NodeType, value :int64):TreeNode =
    result = createNode(nodeType,value,nil,nil)

proc createNode(nodeType: NodeType, identifier :string):TreeNode =
    result = createNode(nodeType,identifier,nil,nil)

proc createNode(nodeType: NodeType, left,right: TreeNode):TreeNode =
    return createNode(nodeType,0,left,right)

proc createNode(token: Token): TreeNode =
    if token.getType() == TokenIntValue:
        result = createNode(IntValue,token.getValue())
    elif token.getType() == TokenIdentifier:
        result = createNode(Identifier,token.getIdentifier)
        
export TreeNode,printNode,createNode,debugNode