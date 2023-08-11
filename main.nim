import scanner
import tokenizer
import tokenQueue
import ast
import treeNode

var sc : Scanner = createScanner("testcase.txt")

var queue: TokenQueue = tokenize(sc)

var expressions: seq[TreeNode] = syntaxTree(queue)

for tree in expressions:
    generateDot(tree, "main.dot")
