import std/tables
import std/strformat

type SymbolData = object
    name: string

type SymbolTable = object
    index: int64
    data: seq[SymbolData]

var symbolIndex: Table[string,int64] = initTable[string,int64]()

var symbolTable: SymbolTable

proc addSymbol(symbol: string):int64 =
    
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

proc getSymbol(id: int64):SymbolData =
    
    if id >= symbolTable.index:
        raise newException(OSError,&"Symbol not declared")
    
    return symbolTable.data[id]

proc getSymbolName(id:int64):string =
    getSymbol(id).name

proc getSymbolId(symbol: string):int64 =
    if not symbolIndex.hasKey(symbol):
        raise newException(OSError,&"Symbol not declared")
    
    return symbolIndex[symbol]

export addSymbol, existSymbol,getSymbol,getSymbolName,getSymbolId