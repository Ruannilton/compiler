import scanner
import tokenizer
import tokenQueue
import ast
import treeNode

var sc : Scanner = createScanner("testcase.txt")

var queue: TokenQueue = tokenize(sc)

let expressions = syntaxTree(queue)

generateDot(expressions, "main.dot")
