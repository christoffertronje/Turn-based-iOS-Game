//
//  ChessBrain.swift
//  MultiPeerTest
//
//  Created by Christoffer Tronje on 2017-02-08.
//  Copyright © 2017 ChristofferTronje. All rights reserved.
//

import Foundation

class ChessBrain {
    
    
    var comingFromBool: Dictionary<String,Bool> = [
        "login": false,
        "searchGame": false,
        "gameView": false
    ]
    var token = ""
    var username = ""
    var games: Array<Dictionary<String, Any>> = [[String:Any]]()
    var opponent = ""
    var gamePosition = ""
    var gameID = 0
    
    
    public func jsonParse(jsonData: Data) ->Dictionary<String,Any>{
        var hej : Dictionary<String, Any> = ["": ["", ""]]
        do{
            hej = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<String,Any>
            return hej
        }
        catch{
            return hej
        }
    }
    
    func dictionaryToArray(dic: Dictionary<String,Any> ) -> Array<Dictionary<String,Any>>{
        return dic["sql"]! as! Array<Dictionary<String,Any>>
    }
   
    func prepareMessage(query:String) -> Dictionary<String, Any> {
        var searchGame: Dictionary<String,Any> = [
            "query": query,
            "username": self.username,
            "token": self.token,
            "Pos": self.gamePosition
        ]
        
        if query == "newGame" || query == "updateGame"{
            searchGame["opponent"] = self.opponent
        }
        if query == "getSingleGameState" || query == "gameOver" ||  query == "updateGame"{
            searchGame["GameID"] = self.gameID
        }
        if query == "updateGame"{
            searchGame["Turn"] = self.opponent
        }
        
        return searchGame
    }

    
    func buildingServerMessage(IP:String,method:String,message:Dictionary<String,Any>)->URLRequest{
        var server = URLRequest(url: URL(string: IP)!)
        server.httpMethod = method
        do{
            let jsonDic = try JSONSerialization.data(withJSONObject: message, options: .prettyPrinted)
            server.httpBody = jsonDic
            
        }
        catch{
            print("could not convert to json!")
            let failure = URLRequest(url: URL(string: IP)!)
            return failure
        }
        
        server.addValue("application/json", forHTTPHeaderField: "Content-Type")
        server.addValue("application/json", forHTTPHeaderField: "Accept")
        return server
    }
    
    func comingFromDestination(comingFrom: String){
        if comingFrom == "login"{
            comingFromBool["login"] = true
            comingFromBool["searchPlayer"] = false
            comingFromBool["gameView"] = false
        }
        else if comingFrom == "searchPlayer"{
            comingFromBool["login"] = false
            comingFromBool["searchPlayer"] = true
            comingFromBool["gameView"] = false
        }
        else if comingFrom == "gameView"{
            comingFromBool["login"] = false
            comingFromBool["searchPlayer"] = false
            comingFromBool["gameView"] = true
        }
    }
}





