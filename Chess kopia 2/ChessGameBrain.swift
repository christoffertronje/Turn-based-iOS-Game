//
//  ChessGameBrain.swift
//  Chess
//
//  Created by Christoffer Tronje on 2017-02-17.
//  Copyright © 2017 ChristofferTronje. All rights reserved.
//

import Foundation

class ChessGameBrain {
    
    
    func isGameOver(positions: String) -> [String:Any]{
        
        var winnerObject = [
            "Winner": "none",
            "isGameOver": false
            ] as [String : Any]
        
        var firstRow = ""
        firstRow.append(getCharFromString(positions: positions,index: 0))
        firstRow.append(getCharFromString(positions: positions,index: 1))
        firstRow.append(getCharFromString(positions: positions,index: 2))
        
        var secondRow = ""
        secondRow.append(getCharFromString(positions: positions,index: 3))
        secondRow.append(getCharFromString(positions: positions,index: 4))
        secondRow.append(getCharFromString(positions: positions,index: 5))
        
        var thirdRow = ""
        thirdRow.append(getCharFromString(positions: positions,index: 6))
        thirdRow.append(getCharFromString(positions: positions,index: 7))
        thirdRow.append(getCharFromString(positions: positions,index: 8))
        
        var firstCol = ""
        firstCol.append(getCharFromString(positions: positions,index: 0))
        firstCol.append(getCharFromString(positions: positions,index: 3))
        firstCol.append(getCharFromString(positions: positions,index: 6))
        
        var secondCol = ""
        secondCol.append(getCharFromString(positions: positions,index: 1))
        secondCol.append(getCharFromString(positions: positions,index: 4))
        secondCol.append(getCharFromString(positions: positions,index: 7))
        
        var thirdCol = ""
        thirdCol.append(getCharFromString(positions: positions,index: 2))
        thirdCol.append(getCharFromString(positions: positions,index: 5))
        thirdCol.append(getCharFromString(positions: positions,index: 8))
        
        var firstDiagonal = ""
        firstDiagonal.append(getCharFromString(positions: positions,index: 0))
        firstDiagonal.append(getCharFromString(positions: positions,index: 4))
        firstDiagonal.append(getCharFromString(positions: positions,index: 8))
        
        var secondDiagonal = ""
        secondDiagonal.append(getCharFromString(positions: positions,index: 2))
        secondDiagonal.append(getCharFromString(positions: positions,index: 4))
        secondDiagonal.append(getCharFromString(positions: positions,index: 6))
                
        if firstRow == "xxx" || secondRow == "xxx" || thirdRow == "xxx" || firstCol == "xxx" || secondCol == "xxx" || thirdCol == "xxx" || firstDiagonal == "xxx" || secondDiagonal == "xxx"{
            winnerObject["Winner"] = "x"
            winnerObject["isGameOver"] = true
            return winnerObject
        }
            
        else if firstRow == "ooo" || secondRow == "ooo" || thirdRow == "ooo" || firstCol == "oo" || secondCol == "ooo" || thirdCol == "ooo" || firstDiagonal == "ooo" || secondDiagonal == "ooo"{
            
            winnerObject["Winner"] = "o"
            winnerObject["isGameOver"] = true
            return winnerObject
            
        }
        else{
            return winnerObject
        }
    }
    
    
    
    private func getCharFromString(positions: String,index: Int) -> Character{
        let index = (positions).index((positions).startIndex, offsetBy: index)
        return positions[index]
    }
    
    
    
    
}
