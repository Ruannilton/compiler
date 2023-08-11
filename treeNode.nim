import std/tables
import std/strformat
import token
import types
import symbolTable

var nodeCounter : int64 = 0

type TreeNode = ref object
    nodeId: int64
    left, right,mid : TreeNode
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


proc debugNode(root:TreeNode): string =

    if root.nodeType == GlueStatement:
        return debugNode(root.left)

    if root.nodeType == CompoundStatement:
        var lines: seq[string]
        var current = root.right

        while current != nil:
            lines.add(&"{debugNode(current.left)}\n")
            current = current.right

        var ret = "{\n"
        let l = lines.len() - 1
        
        for index in countdown(l,0):
            ret.add(lines[index])

        ret.add("}")
        return ret

    if root.nodeType == IntValue:
        return &"{root.value}"

    if root.nodeType == Identifier:
        return getSymbolName(root.id)

    if root.nodeType == Asign:
        return &"{debugNode(root.left)} = {debugNode(root.right)}"

    let op = opToString[root.nodeType]

    
  
    return &"({debugNode(root.left)} {op} {debugNode(root.right)})"

proc createNode(nodeType: NodeType, value :int64, left,right: TreeNode, mid: TreeNode = nil):TreeNode =
    var tmp: TreeNode = new(TreeNode)
    tmp.nodeType = nodeType
    tmp.value = value
    tmp.left = left
    tmp.right = right
    tmp.mid = mid
    tmp.nodeId = nodeCounter
    nodeCounter = nodeCounter + 1
    return tmp

proc createNode(nodeType: NodeType, identifier :string, left,right: TreeNode):TreeNode =
    var tmp: TreeNode = new(TreeNode)
    tmp.nodeType = nodeType
    tmp.id = getSymbolId(identifier)
    tmp.left = left
    tmp.right = right
    tmp.mid = nil
    tmp.nodeId = nodeCounter
    nodeCounter = nodeCounter + 1
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
        
        
proc generateDot(node: TreeNode, name:string) =

  var dotFile: File
  discard open(dotFile, name, fmWrite)

  dotFile.write("digraph Tree {\n")
  dotFile.write("  node [shape=box];\n\n")

  proc getNodeColor(nodeType: NodeType): string =
    case nodeType
    of IntValue: return "lightblue"
    of Identifier: return "lightgreen"
    of CompoundStatement: return "lightpink"
    of IfNode: return "mediumorchid"
    else: return "white"

  proc traverse(node: TreeNode) =
    
   
    let nodeType = node.nodeType

    var labelStr = &"{nodeType}"

    case nodeType
        of IntValue:
            labelStr.add(&"\\n {node.value}")
        of IfNode:
            labelStr.add(&"\\n mid? left : right")
        of Identifier:
            labelStr.add(&"\\n {getSymbolName(node.id)}")
        else:
            if opToString.hasKey(nodeType):
                labelStr.add(&"\\n left {opToString[nodeType]} right")

    let nodeColor = getNodeColor(nodeType)
    dotFile.write("  node", node.nodeId, " [label=\"", labelStr, "\", style=filled, fillcolor=", nodeColor,"];\n")

    if node.left != nil:
      traverse(node.left)
      dotFile.write("  node", node.nodeId, " -> node", node.left.nodeId, " [label=\"left\"];\n")

    if node.mid != nil:
      traverse(node.mid )
      dotFile.write("  node", node.nodeId, " -> node", node.mid .nodeId, " [label=\"mid\"];\n")

    if node.right != nil:
      traverse(node.right)
      dotFile.write("  node", node.nodeId, " -> node", node.right.nodeId, " [label=\"right\"];\n")

  traverse(node)
  dotFile.write("}\n")
  close(dotFile)

export TreeNode,createNode,debugNode,generateDot