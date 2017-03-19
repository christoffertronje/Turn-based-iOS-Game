//
//  SecondUIViewController.swift
//  MultiPeerTest
//
//  Created by Christoffer Tronje on 2017-02-12.
//  Copyright © 2017 ChristofferTronje. All rights reserved.
//

import UIKit

class ShowGameSceen: UIViewController{
    
    
    
    //@IBOutlet var UIButtons: [UIButton]!
    
    @IBOutlet var UIButtons: [UIButton]!
    
    @IBOutlet weak var opponentLabel: UILabel!
    
    @IBOutlet weak var UIMessageLabel: UILabel!
    
    @IBOutlet weak var playersImage: UIImageView!
    
    
    
    var chessBrain = ChessBrain()
    var chessBrainGame = ChessGameBrain()
    var player = [
        "type" : "",
        "picture": ""
    ]
    var winnerObject = [String:Any]()
    var gameState = [0,0,0,0,0,0,0,0,0]
    var buttonToBeChanged = 0
    var moveMade = false
    var onGoingProcess = false
    var timer: Timer?
    var currentPositions = ""
    var gameOver = false
    var passedData: Dictionary<String,Any> = [String:Any]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.chessBrain.gameID = passedData["GameID"] as! Int
        opponentLabel.text = "Opponent: \(passedData["Opp"]!)"
        chessBrain.opponent = passedData["Opp"]! as! String
        
        for button in UIButtons{
            button.addTarget(self, action:#selector(self.moveMade(button:)), for: .touchUpInside)
        }
        self.updateGame()
        timer = Timer.scheduledTimer(timeInterval: 3,
                                     target: self,
                                     selector: #selector(self.updateGame),
                                     userInfo: nil,
                                     repeats: true)
        
        
        if passedData["White"] as! String == self.chessBrain.username.lowercased(){
            player["type"] = "x"
            player["picture"] = "cross.png"
        }
        else{
            player["type"] = "o"
            player["picture"] = "ring.png"
        }
        
        self.playersImage.image = UIImage(named: player["picture"]!)
        self.chessBrain.gamePosition = self.passedData["Pos"] as! String
        self.winnerObject = self.chessBrainGame.isGameOver(positions: self.passedData["Pos"] as! String)
        if self.winnerObject["isGameOver"] as! Bool{
            self.gameOver = true
        }
    }
    
    
    
    
    @IBAction func goBackButton(_ sender: UIButton) {       // go back to menu button
        if onGoingProcess{
            return
        }
        if timer != nil{
            timer?.invalidate()
            timer = nil
        }
        
        performSegue(withIdentifier: "fromGameToMainView", sender: self)
    }
    
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {     // prepare segue for going back to menu
        if let destination = segue.destination as? ViewController{
            chessBrain.comingFromDestination(comingFrom: "gameView")
            destination.chessBrain = chessBrain
            print("leaving game...")
        }
    }
    
    
    func moveMade(button: UIButton){        // "tile" clicked
        if onGoingProcess || gameOver{
            return
        }
        onGoingProcess = true
        if (passedData["Turn"] as? String == passedData["Opp"] as? String) || self.moveMade{
            self.UIMessageLabel.text = "Not your turn!"
            self.onGoingProcess = false
            return
        }
        else if gameState[button.tag] == 1{
            self.UIMessageLabel.text = "Invalid move!"
            self.onGoingProcess = false
            return
        }
        self.currentPositions = self.chessBrain.gamePosition
        self.chessBrain.gamePosition = ""
        let positionLength = (passedData["Pos"] as! String).characters.count
        for i in 0..<positionLength{
            // let index = (passedData["Pos"] as! String).index((passedData["Pos"] as! String).startIndex, offsetBy: i)
            
            if i == button.tag{
                self.chessBrain.gamePosition.append(player["type"]!)
                self.buttonToBeChanged = i
            }
                
            else{
                if(UIButtons[i].imageView?.image == UIImage(named:"cross.png")){
                    self.chessBrain.gamePosition.append("x")
                }
                else if(UIButtons[i].imageView?.image == UIImage(named:"ring.png")){
                    self.chessBrain.gamePosition.append("o")
                }
                else{
                    self.chessBrain.gamePosition.append("i")
                }
            }
        }
        self.loadPositions(positions: self.chessBrain.gamePosition)
        let message = self.chessBrain.prepareMessage(query: "updateGame")
        self.sendRequest(method: "POST", postDictionary: message)
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func sendRequest(method: String, postDictionary: Dictionary<String, Any>){      // send request to server
        
        let server = self.chessBrain.buildingServerMessage(IP: IP, method: method, message: postDictionary)
        
        let task = URLSession.shared.dataTask(with: server) { data, response, error in
            guard let data = data, error == nil else {
                print("något gick fel")
                print(method)
                print(postDictionary)
                print("Current positions: \(self.currentPositions)")
                self.loadPositions(positions: self.currentPositions)
                //  self.prepareRequest(method: method, postString: postString)
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                // print("statusCode should be 200, but is \(httpStatus.statusCode)")
                //  print("response = \(response)")
            }
            
            // start handling different requests
            
            
            if method == "POST"{
                let dic = self.chessBrain.jsonParse(jsonData: data)
                let response = dic["response"] as! String
                
                if response == "Game Over/Deleted"{
                    return
                }
                
                if response == "Current state" {        // getting games current state
                    let sqlarray = (dic["sql"] as! Array<Dictionary<String,Any>>)[0]
                    self.passedData["Pos"] = sqlarray["Pos"]
                    self.loadPositions(positions: sqlarray["Pos"] as! String)
                    
                    self.passedData["Turn"] = sqlarray["Turn"]
                    if(self.passedData["Turn"] as! String == self.chessBrain.username.lowercased()){
                        self.moveMade = false
                    }
                    self.winnerObject = self.chessBrainGame.isGameOver(positions: self.passedData["Pos"] as! String)

                    
                }else if response == "MoveMade" {     // move made
                    
                    self.moveMade = true
                    let sqlarray = (dic["sql"] as! Array<Dictionary<String,Any>>)[0]
                    self.passedData["Pos"] = sqlarray["Pos"]
                    self.passedData["Turn"] = sqlarray["Turn"]
                    self.chessBrain.gamePosition = sqlarray["Pos"] as! String
                    // print(sqlarray["Pos"] ?? "funkar inte")
                    self.winnerObject = self.chessBrainGame.isGameOver(positions: self.passedData["Pos"] as! String)
                    if self.winnerObject["isGameOver"] as! Bool{   // game is over
                        self.removeGameIfLoserEnter()
                    }
                }
                
                self.winnerObject = self.chessBrainGame.isGameOver(positions: self.passedData["Pos"] as! String)
                if self.winnerObject["isGameOver"] as! Bool{   // game is over
                    
                    self.removeGameIfLoserEnter()
                }
                else if self.gameIsTie(){
                    self.removeGameIfTie()
                    self.gameIsOver(clientMessage: "GAME IS A TIE")
                }
            }
            self.onGoingProcess = false
        }
        task.resume()
    }
    
    func loadPositions(positions: String){
        let positionLength = positions.characters.count
        for i in 0..<positionLength{
            let index = positions.index(positions.startIndex, offsetBy: i)
            if positions[index] == "x"{
                DispatchQueue.main.async {
                    self.UIButtons[i].setImage(UIImage(named: "cross.png"),for: UIControlState())
                }
                gameState[i] = 1
            }
            else if positions[index] == "o"{
                DispatchQueue.main.async {
                    self.UIButtons[i].setImage(UIImage(named: "ring.png"),for: UIControlState())
                }
                gameState[i] = 1
            }
            else if positions[index] == "i"{
                DispatchQueue.main.async {
                    self.UIButtons[i].setImage(nil,for: UIControlState())
                }
                gameState[i] = 0
            }
            
        }
    }
    
    func updateGame(){
        let dic = self.chessBrain.prepareMessage(query: "getSingleGameState")
        print("Updating the game...")
        self.sendRequest(method: "POST", postDictionary: dic)
    }
    
    func gameIsTie() -> Bool {
        for i in 0..<self.gameState.count{
            if gameState[i] == 0{
                return false
            }
        }
        return true
    }
    
    func gameIsOver(clientMessage: String){
        self.timer?.invalidate()
        DispatchQueue.main.async {
            self.UIMessageLabel.text = clientMessage
        }
    }
    
    func removeGameIfLoserEnter(){
        
        
        if self.player["type"] != self.winnerObject["Winner"] as? String{       // if user is loser
            self.gameIsOver(clientMessage: "GAME OVER YOU LOST")
            let message = self.chessBrain.prepareMessage(query: "gameOver")
            self.sendRequest(method: "POST", postDictionary: message)
        }
        else if self.player["type"] == self.winnerObject["Winner"] as? String{      // if user is winner
            self.gameIsOver(clientMessage: "GAME OVER YOU WON")
        }
    }
    
    @IBAction func rightSwipe(_ sender: UISwipeGestureRecognizer) {
        timer?.invalidate()
        performSegue(withIdentifier: "fromGameToMainView", sender: self)
    }
    
    func removeGameIfTie(){
        if self.winnerObject["Winner"] as! String == "none" && self.chessBrain.username.lowercased() == self.passedData["Turn"] as! String{
            
            print(self.winnerObject["Winner"] as! String)
            print("TURN: \(self.passedData["Turn"])")
            print("USERNAME: \(self.chessBrain.username)")
            let message = self.chessBrain.prepareMessage(query: "gameOver")
            self.sendRequest(method: "POST", postDictionary: message)
            
        }
    }
    
}
