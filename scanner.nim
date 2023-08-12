import system

type Scanner = object
    index: int
    line: int
    content: string
    done: bool

proc createScanner(file : string): Scanner =
    result.content = readFile(file)
    result.index = 0
    result.line = 0
    result.done = false

proc nextChar(self: var Scanner):char =
    if self.index == self.content.len():
        result = '\0'
        self.done = true
    else:
        let current = self.content[self.index]
        self.index += 1
        result = current

proc putBack(self: var Scanner) =
    if self.index > 0:
        self.index -= 1

proc skipWitheSpace(self: var Scanner) =
    while true:
        let c = self.nextChar()
        if ord(c) in {ord(' '), ord('\t'), ord('\n'), ord('\r')}:
            if ord(c) == ord('\n'):
                self.line += 1
            continue
        else:
            break
    self.putBack()

proc done(self: Scanner):bool =
    if self.index == self.content.len() or self.done:
        result = true
    else:
        result = false

proc getLine(self: Scanner): int = self.line
proc getIndex(self: Scanner): int = self.index

export Scanner,createScanner,skipWitheSpace,nextChar,putBack,done,getLine,getIndex

