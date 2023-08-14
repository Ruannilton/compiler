import std/tables
import std/strformat
import types

type SymbolData = object
    name: string
    symbolType: SymbolType
    dataType: DataType

type SymbolTable = object
    index: int
    data: seq[SymbolData]

var symbolIndex: Table[string,int] = initTable[string,int]()

var symbolTable: SymbolTable

proc addSymbol(symbol: string, symbolType: SymbolType, dataType: DataType):int =
    
    if not symbolIndex.hasKey(symbol):
        
        let idx = symbolTable.index

        var symbolData: SymbolData
        symbolData.name = symbol
        symbolData.symbolType = symbolType
        symbolData.dataType = dataType

        symbolTable.index += 1 
        symbolTable.data.setLen(symbolTable.index)
        symbolTable.data[idx] = symbolData
        symbolIndex[symbol] = idx
        return idx
    raise newException(OSError,&"Symbol {symbol} already exists")

proc existSymbol(symbol: string):bool =
    return symbolIndex.hasKey(symbol)

proc getSymbolId(symbol: string):int =
    if not symbolIndex.hasKey(symbol):
        raise newException(OSError,&"Symbol not declared")
    
    return symbolIndex[symbol]

proc getSymbol(id: int): SymbolData = 
    if id >= symbolTable.index:
        raise newException(OSError,&"Symbol not declared")
    return symbolTable.data[id]

proc getSymbol(id: string): SymbolData = getSymbol(getSymbolId(id))


proc getName(self: SymbolData): string = self.name

proc getType(self: SymbolData): SymbolType = self.symbolType

proc getDataType(self: SymbolData): DataType = self.dataType

proc setType(self: var SymbolData, sType:SymbolType) = self.symbolType = sType

proc setDataType(self: var SymbolData, dType:DataType) = self.dataType = dType

export SymbolData, addSymbol, existSymbol, getSymbolId, getSymbol, getName, getType, getDataType, setType, setDataType