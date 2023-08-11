import scanner
import tokenizer
import tokenQueue
import ast
import treeNode

var sc : Scanner = createScanner("testcase.txt")

var queue: TokenQueue = tokenize(sc)

echo "Tokenizer done"

let expressions = syntaxTree(queue)

echo "Syntax Tree done"

generateDot(expressions, "main.dot")

echo "Done"