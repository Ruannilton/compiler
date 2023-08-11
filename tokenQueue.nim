import token
import types

type TokenQueue = object 
    values : seq[Token]
    index: int64

proc initTokenQueue(tokenList: seq[Token]): TokenQueue =
    result.index = 0
    result.values = tokenList

proc empty(self: TokenQueue): bool = self.values.len == self.index

proc enqueue(self: var TokenQueue, token: Token) = self.values.add(token)

proc dequeue(self: var TokenQueue): Token =
    if not self.empty():
        result = self.values[self.index]
        self.index += 1
    else:
        result.initToken(TokenEOF)

proc peak(self: TokenQueue): Token =
    if not self.empty():
        return self.values[self.index]
    result.initToken(TokenEOF)
   



export TokenQueue, initTokenQueue,enqueue,dequeue,peak,empty