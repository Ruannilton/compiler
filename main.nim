import scanner
import tokenizer
import tokenQueue
import ast
import treeNode


var sc : Scanner = createScanner("testcase.c")

var queue: TokenQueue = tokenize(sc)
queue.toFile("queue.txt")

echo "Tokenizer done"

let expressions = syntaxTree(queue)

echo "Syntax Tree done"

generateDot(expressions, "main.dot")

echo "Done"