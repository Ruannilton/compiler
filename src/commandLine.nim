import std/parseopt

type CommandLine = object
    inputFile: string
    outputFile: string
    debug: bool
    debugOut: string

proc newCommandLine(input: string):CommandLine =
    var p = initOptParser(input)

    while true:
        p.next()
        case p.kind
        of cmdEnd: break
        of cmdShortOption,cmdLongOption:
            if p.key == "o" or p.key == "out":
                result.outputFile = p.val
            elif p.key == "d" or p.key == "debug":
                result.debug = true 
                result.debugOut = p.val
        of cmdArgument:
            result.inputFile = p.key

proc getInputFile(self: CommandLine): string = self.inputFile

proc getOutputFile(self: CommandLine): string = self.outputFile

proc getDebug(self: CommandLine): bool = self.debug

proc getDebugOut(self: CommandLine): string = self.debugOut

export CommandLine,newCommandLine,getInputFile,getOutputFile,getDebug,getDebugOut