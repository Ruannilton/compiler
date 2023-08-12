import std/tables
import std/strformat

type SymbolData = object
    name: string

type SymbolTable = object
    index: int
    data: seq[SymbolData]

var symbolIndex: Table[string,int] = initTable[string,int]()

var symbolTable: SymbolTable

proc addSymbol(symbol: string):int =
    
    if not symbolIndex.hasKey(symbol):
        
        let idx = symbolTable.index

        var symbolData:SymbolData
        symbolData.name = symbol
        
        symbolTable.index += 1 
        symbolTable.data.setLen(symbolTable.index)
        symbolTable.data[idx] = symbolData
        symbolIndex[symbol] = idx
        return idx
    raise newException(OSError,&"Symbol {symbol} already exists")

proc existSymbol(symbol: string):bool =
    return symbolIndex.hasKey(symbol)

proc getSymbol(id: int):SymbolData =
    
    if id >= symbolTable.index:
        raise newException(OSError,&"Symbol not declared")
    
    return symbolTable.data[id]

proc getSymbolName(id:int):string =
    getSymbol(id).name

proc getSymbolId(symbol: string):int =
    if not symbolIndex.hasKey(symbol):
        raise newException(OSError,&"Symbol not declared")
    
    return symbolIndex[symbol]

export addSymbol, existSymbol,getSymbol,getSymbolName,getSymbolId