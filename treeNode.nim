import std/strformat
import token
import types
import symbolTable

var nodeCounter : int = 0

type TreeNode = ref object
    nodeId: int
    dataType: DataType = None
    case nodeType: NodeType
    of IntNode: 
        valueInt:  int
    of BoolNode:
        valueBool: bool
    of CharNode:
        valueChar: char
    of IdentifierNode:
        id: int
    of RootNode, CompoundNode, ReturnNode:
        child: TreeNode
    of IfNode:
        wTrue, wFalse, exp: TreeNode
    of FunctionNode:
        fnId: int
        fnBody: TreeNode
    else:
        left, right: TreeNode
    
proc newNodeId():int = 
    result = nodeCounter
    nodeCounter += 1

# int node
proc createNode(value: int): TreeNode =
    var node = TreeNode(nodeType: IntNode)
    node.dataType = Int
    node.nodeId = newNodeId()
    node.valueInt = value
    return node

# bool node
proc createNode(value: bool): TreeNode =
    var node = TreeNode(nodeType: BoolNode)
    node.dataType = Bool
    node.nodeId = newNodeId()
    node.valueBool = value
    return node

# char node
proc createNode(value: char): TreeNode =
    var node = TreeNode(nodeType: CharNode)
    node.dataType = Char
    node.nodeId = newNodeId()
    node.valueChar = value
    return node

# identifier node
proc createNode(identifier: string): TreeNode =
    var node = TreeNode(nodeType: IdentifierNode)
    node.nodeId = newNodeId()
    node.id = getSymbolId(identifier)
    node.dataType = getSymbol(node.id).getDataType()
    return node

# single child node
proc createNode(nodeType: NodeType, child:TreeNode,dataType: DataType = None): TreeNode =
    var node = TreeNode(nodeType: nodeType)
    node.dataType = dataType
    node.child = child
    node.nodeId = newNodeId()
    return node

# if node
proc createNode(expression, whenTrue, whenFalse:TreeNode): TreeNode =
    var node = TreeNode(nodeType: IfNode)
    node.dataType = None
    node.nodeId = newNodeId()
    node.wTrue = whenTrue
    node.wFalse = whenFalse
    node.exp = expression
    return node

# function node
proc createNode(identifier: string, body:TreeNode):TreeNode = 
    var node = TreeNode(nodeType: FunctionNode)
    node.nodeId = newNodeId()
    node.fnId = getSymbolId(identifier)
    node.dataType = getSymbol(node.fnId).getDataType()
    node.fnBody = body
    return node

# default node
proc createNode(nodeType: NodeType,rvalue, lvalue:TreeNode,dataType: DataType = None): TreeNode =
    var node = TreeNode(nodeType: nodeType)
    node.dataType = dataType
    node.nodeId = newNodeId()
    node.left = lvalue
    node.right = rvalue
    return node

proc createGlueNode(first, second:TreeNode): TreeNode =
    var node = TreeNode(nodeType: GlueNode)
    node.dataType = None
    node.nodeId = newNodeId()
    node.left = first
    node.right = second
    return node
####


proc createNode(token: Token): TreeNode =
    if token.getType() == TokenIntValue:
        result = createNode(token.getIntValue())
    if token.getType() == TokenBoolValue:
        result = createNode(token.getBoolValue())
    if token.getType() == TokenCharValue:
        result = createNode(token.getCharValue())
    elif token.getType() == TokenIdentifier:
        result = createNode(token.getIdentifier())
        
        
proc generateDot(node: TreeNode, name:string) =

  var dotFile: File
  discard open(dotFile, name, fmWrite)

  dotFile.write("digraph Tree {\n")
  dotFile.write("  node [shape=box];\n\n")

  proc getNodeColor(nodeType: NodeType): string =
    case nodeType
    of IntNode: return "lightblue"
    of IdentifierNode: return "lightgreen"
    of CompoundNode: return "lightpink"
    of WhileNode,IfNode: return "mediumorchid"
    of BoolNode: return "lightsalmon"
    of FunctionNode: return "gold"
    of ReturnNode: return "firebrick1"
    else: return "white"

  proc traverse(node: TreeNode) =
    let nodeType = node.nodeType

    var labelStr = &"{nodeType}"

    labelStr.add(&"\\nType: {node.dataType}")

    case nodeType
        of IntNode:
            labelStr.add(&"\\n {node.valueInt}")
        of BoolNode:
            labelStr.add(&"\\n {node.valueBool}")
        of CharNode:
            labelStr.add(&"\\n {node.valueChar}")
        of IfNode:
            labelStr.add(&"\\n exp? left : right")
        of WhileNode:
            labelStr.add(&"\\n while right? left")
        of IdentifierNode:
            labelStr.add(&"\\n {getSymbol(node.id).getName()}")
        of FunctionNode:
            labelStr.add(&"\\n {getSymbol(node.fnId).getName()}")
        else:
            if nodeType.hasSymbol():
                labelStr.add(&"\\n left {nodeType.getSymbol()} right")

    let nodeColor = getNodeColor(nodeType)
    dotFile.write("  node", node.nodeId, " [label=\"", labelStr, "\", style=filled, fillcolor=", nodeColor,"];\n")

    case nodeType:
        of IntNode,BoolNode,CharNode,IdentifierNode: discard
        of IfNode:
            if node.wTrue != nil:
                traverse(node.wTrue)
                dotFile.write("  node", node.nodeId, " -> node", node.wTrue.nodeId, " [label=\"true\"];\n")

            if node.exp != nil:
                traverse(node.exp)
                dotFile.write("  node", node.nodeId, " -> node", node.exp.nodeId, " [label=\"exp\"];\n")

            if node.wFalse != nil:
                traverse(node.wFalse)
                dotFile.write("  node", node.nodeId, " -> node", node.wFalse.nodeId, " [label=\"false\"];\n")
        of CompoundNode,RootNode,ReturnNode:
            if node.child != nil:
                traverse(node.child)
                dotFile.write("  node", node.nodeId, " -> node", node.child.nodeId, " [label=\"child\"];\n")
        of FunctionNode:
            if node.fnBody != nil:
                traverse(node.fnBody)
                dotFile.write("  node", node.nodeId, " -> node", node.fnBody.nodeId, " [label=\"body\"];\n")
        of GlueNode:
            if node.left != nil:
                traverse(node.left)
                dotFile.write("  node", node.nodeId, " -> node", node.left.nodeId, " [label=\"first\"];\n")
            if node.right != nil:
                traverse(node.right)
                dotFile.write("  node", node.nodeId, " -> node", node.right.nodeId, " [label=\"second\"];\n")
        else:
            if node.left != nil:
                traverse(node.left)
                dotFile.write("  node", node.nodeId, " -> node", node.left.nodeId, " [label=\"left\"];\n")
            if node.right != nil:
                traverse(node.right)
                dotFile.write("  node", node.nodeId, " -> node", node.right.nodeId, " [label=\"right\"];\n")

  traverse(node)
  dotFile.write("}\n")
  close(dotFile)

proc getDataType(self: TreeNode):DataType = self.dataType
proc setDataType(self: var TreeNode, dataType: DataType) = 
    self.dataType = dataType

export TreeNode,createNode,generateDot,createGlueNode,getDataType,setDataType