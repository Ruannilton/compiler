import scanner
import tokenizer
import tokenQueue
import ast
import treeNode
import os
import commandLine
import std/strutils

let params = commandLineParams()

let inpt = params.join(" ")

let cmd : CommandLine = newCommandLine(inpt)

var sc : Scanner = createScanner(cmd.getInputFile())

var queue: TokenQueue = tokenize(sc)

if cmd.getDebug():
    queue.toFile(cmd.getDebugOut())

let expressions = syntaxTree(queue)

generateDot(expressions, cmd.getOutputFile())
