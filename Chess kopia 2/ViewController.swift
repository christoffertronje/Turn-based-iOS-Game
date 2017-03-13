//
//  ViewController.swift
//  MultiPeerTest
//
//  Created by Christoffer Tronje on 2017-01-29.
//  Copyright © 2017 ChristofferTronje. All rights reserved.
//

import UIKit
import GameKit

//var gameInDisplay:Dictionary<String,Any> = [String:Any]()
var IP = "https://kalle.dsmynas.com:1024"
//var IP = "http://192.168.38.104:8888"


class ViewController: UIViewController{
    
    
    @IBOutlet weak var gamesView: UIView!
    
    var passedData:Array<Dictionary<String, Any>> = [[String:Any]]()
    
    @IBOutlet weak var responseLabel: UILabel!
    
    
    @IBOutlet weak var signedInAsLabel: UILabel!
    
    @IBOutlet weak var currentState: UILabel!       // state textfield - ta bort skiten
    
    //    @IBOutlet weak var inputText: UITextField!      // input text
    
    override func viewDidLoad() {       // when UI have loaded
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if(self.chessBrain.username != ""){
            self.changeLoggedInLabel()
            self.createStartedGames()
            self.updateGames()
        }
        
        if self.chessBrain.comingFromBool["login"]!{
            print("kommer från login")
            //      self.inputText.delegate = self
            
        }
        else if self.chessBrain.comingFromBool["searchPlayer"]!{
            print("kommer från search player")
            self.createNewGame()
        }
        else if self.chessBrain.comingFromBool["gameView"]! {
            print("kommer från game")
            self.games = chessBrain.games
            self.changeLoggedInLabel()
            self.createStartedGames()
            self.updateGames()
            
        }
        timer = Timer.scheduledTimer(timeInterval: 10,
                                     target: self,
                                     selector: #selector(self.updateGames),
                                     userInfo: nil,
                                     repeats: true)
        
    }
    var comingFromLogin = true
    var comingFromSearchPlayer = false
    var gameToBeDisplayed = 0
    var chessBrain = ChessBrain()
    var timer = Timer()
    var uiarray = [UIButton]()
    var games:Array<Dictionary<String, Any>> = [[String:Any]]()
    var onGoingProcess = false
    
    @IBAction func sendPostRequest(_ sender: UIButton) {        // new game button
        
        timer.invalidate()
        performSegue(withIdentifier: "toSearchView", sender: self)
        /*
         if onGoingProcess{
         return
         }
         onGoingProcess = true
         if inputText.text!.lowercased() == self.chessBrain.username.lowercased(){
         responseLabel.text = "Can't start game with yourself"
         }
         else if self.inputText.text! == ""{
         responseLabel.text = "Empty fields!"
         }
         else{
         self.chessBrain.opponent = inputText.text!
         let searchGame = self.chessBrain.prepareMessage(query: "newGame")  // self.chessBrain.createSendObject(query:"newGame",username:self.chessBrain.username,opponent: self.inputText.text!,token:self.chessBrain.token)
         self.prepareRequest(method: "POST", message: searchGame)
         }
         */
    }
    
    @IBAction func randomGame(_ sender: UIButton) {     // random game button
        if onGoingProcess{
            return
        }
        onGoingProcess = true
        if games.count < 10 {
            //       self.chessBrain.opponent = inputText.text!
            let test = self.chessBrain.prepareMessage(query: "newGameRandom")         // self.chessBrain.createSendObject(query:"newGameRandom",username:self.chessBrain.username,opponent: "",token:self.chessBrain.token)
            //       self.removeTextFromInput(UIText: self.inputText)
            self.prepareRequest(method:"POST", message: test)
            self.createStartedGames()
        }else{
            responseLabel.text = "Maximum number of games"
        }
    }
    
    
    @IBAction func logOutButton(_ sender: UIButton) {
        timer.invalidate()
        performSegue(withIdentifier: "fromMainViewToLogin", sender: self)
    }
    
    
    
    private func sendRequest(method: String, postDictionary: Dictionary<String, Any>){      // send request to server
        let server = self.chessBrain.buildingServerMessage(IP: IP, method: method, message: postDictionary)
        
        let task = URLSession.shared.dataTask(with: server) { data, response, error in
            guard let data = data, error == nil else {
                print("något gick fel")
                print(method)
                print(postDictionary)
                //  self.prepareRequest(method: method, postString: postString)
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                // print("statusCode should be 200, but is \(httpStatus.statusCode)")
                //  print("response = \(response)")
            }
            
            // start handling different requests
            
            
            if method == "POST"{
                let message = self.chessBrain.jsonParse(jsonData: data)
                self.postFunction(message: message)
            }
            self.onGoingProcess = false
            
        }
        task.resume()
    }
    
    private func createGameButton(game: Dictionary<String,Any>,tag:Int,spacing: Double)->UIButton{      // create a button for each started game
        
        let button = UIButton()
        let spaces = (spacing*0.9)/Double(self.gamesView.frame.height)
        let multiplyer = 0.1-spaces
        if self.games[tag]["Turn"] as? String == self.chessBrain.username.lowercased(){
            button.backgroundColor = UIColor.init(red: 91/255, green: 140/255, blue: 132/255, alpha: 1)
            button.layer.borderColor = UIColor.init(red: 91/255, green: 140/255, blue: 132/255, alpha: 1).cgColor
        }else{
            button.backgroundColor = UIColor.init(red: 117/255, green: 39/255, blue: 52/255, alpha: 1)
            button.layer.borderColor = UIColor.init(red: 117/255, green: 39/255, blue: 52/255, alpha: 1).cgColor
            
        }
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.setTitle(game["Opp"] as? String, for: .normal)
        
        
        button.translatesAutoresizingMaskIntoConstraints = false
        self.gamesView.addSubview(button)
        
        self.gamesView.addConstraint(NSLayoutConstraint(item: button, attribute: .left, relatedBy: .equal, toItem: self.gamesView, attribute: .left, multiplier: 1, constant: 0))
        self.gamesView.addConstraint(NSLayoutConstraint(item: button, attribute: .right, relatedBy: .equal, toItem: self.gamesView, attribute: .right, multiplier: 1, constant: 0))
        self.gamesView.addConstraint(NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: self.gamesView, attribute: .height, multiplier: CGFloat(multiplyer), constant: 0))
        
        
        if tag == 0{
            self.gamesView.addConstraint(NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: self.gamesView, attribute: .top, multiplier: 1, constant: 0))
        }
        else{
            self.gamesView.addConstraint(NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: self.uiarray[tag-1], attribute: .bottom, multiplier: 1, constant: CGFloat(spacing)))
        }
        button.tag = tag
        button.addTarget(self, action:#selector(self.openGame(button:)), for: .touchUpInside)
        return button
    }
    
    
    
    private func prepareRequest(method: String, message: Dictionary<String, Any>){
        self.sendRequest(method: method, postDictionary: message)
    }
    
    
    private func postFunction(message: Dictionary<String,Any>){
        if message["response"] as? String == "NewGame"{
            self.createStartedGames2(jsonData: message)        // lägger upp en knapp för varje game
            //       self.removeTextFromInput(UIText: self.inputText)
        }
            
        else if message["response"] as? String == "NewRandomGame"{
            self.createStartedGames2(jsonData: message)        // lägger upp en knapp för varje game
        }
        else if message["response"] as? String == "GamesSent"{
            self.chessBrain.games = message["sql"]! as! Array<Dictionary<String, Any>>
            self.games = self.chessBrain.games
            self.createStartedGames()
        }
        else if message["response"] as? String == "User does not exist"{
            DispatchQueue.main.async {
                self.responseLabel.text = "User does not exist!"
            }
            self.updateGames()
        }
    }
    
    
    private func createStartedGames(){        // for login
        DispatchQueue.main.async {
            for i in 0 ..< self.uiarray.count {
                self.uiarray[i].removeFromSuperview()
            }
            self.uiarray = []
            for i in 0 ..< self.games.count {
                self.uiarray.append(self.createGameButton(game: self.games[i],tag:i, spacing: 4))
            }
        }
    }
    
    private func createStartedGames2(jsonData: Dictionary<String, Any>){       // for nre game and random game
        
        DispatchQueue.main.async {
            //  let jsonData = self.chessBrain.jsonParse(jsonData: data)
            for i in 0 ..< self.uiarray.count {
                self.uiarray[i].removeFromSuperview()
            }
            self.uiarray = []
            
            self.games = self.chessBrain.games
            self.games += self.chessBrain.dictionaryToArray(dic:jsonData)
            for i in 0 ..< self.games.count {
                self.uiarray.append(self.createGameButton(game: self.games[i],tag:i, spacing: 4))
            }
            self.chessBrain.games = self.games
            self.responseLabel.text = jsonData["response"] as? String
        }
    }
    
    
    /*   override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {     // remove keyboard if tocuh outside
     self.view.endEditing(true)
     }
     */
    private func removeTextFromInput(UIText: UITextField){
        UIText.text = ""
    }
    
    func openGame(button: UIButton){
        //   gameInDisplay = games[button.tag]
        self.gameToBeDisplayed = button.tag
        timer.invalidate()
        performSegue(withIdentifier: "showGame", sender: self.chessBrain.games[button.tag])
    }
    
    private func changeLoggedInLabel(){
        DispatchQueue.main.async {
            self.signedInAsLabel.text = self.chessBrain.username
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showGame"{
            
            if let destination = segue.destination as? ShowGameSceen{
                destination.passedData = self.games[gameToBeDisplayed]
                destination.chessBrain = self.chessBrain
            }
        }
        else if segue.identifier == "toSearchView"{
            if let destination = segue.destination as? SearchPlayer{
                destination.chessBrain = self.chessBrain
            }
        }
    }
    func updateGames(){
        let dic = self.chessBrain.prepareMessage(query: "getGamesState")
        print("Updating games...")
        self.sendRequest(method: "POST", postDictionary: dic)
    }
    
    /*    func textFieldDidBeginEditing(_ textField: UITextField) {
     textField.placeholder = ""
     }
     func textFieldDidEndEditing(_ textField: UITextField) {
     textField.placeholder = "Opponent username"
     }*/
    /*
     func keyboardWasShown(notification: NSNotification) {
     self.inputText.translatesAutoresizingMaskIntoConstraints = false
     /*
     self.inputText.addConstraint(NSLayoutConstraint(item: button, attribute: .left, relatedBy: .equal, toItem: self.gamesView, attribute: .left, multiplier: 1, constant: 0))
     self.inputText.addConstraint(NSLayoutConstraint(item: button, attribute: .right, relatedBy: .equal, toItem: self.gamesView, attribute: .right, multiplier: 1, constant: 0))
     self.inputText.addConstraint(NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: self.gamesView, attribute: .height, multiplier: CGFloat(multiplyer), constant: 0))
     
     
     if tag == 0{
     self.gamesView.addConstraint(NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: self.gamesView, attribute: .top, multiplier: 1, constant: 0))
     }
     else{
     self.gamesView.addConstraint(NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: self.uiarray[tag-1], attribute: .bottom, multiplier: 1, constant: CGFloat(spacing)))
     }
     */
     
     
     let info = notification.userInfo!
     let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
     
     UIView.animate(withDuration: 0.1, animations: { () -> Void in
     self.inputText.addConstraint(keyboardFrame.size.height + 20)
     
     })
     }*/
    
    func createNewGame(){
        let searchGame = self.chessBrain.prepareMessage(query: "newGame")  // self.chessBrain.createSendObject(query:"newGame",username:self.chessBrain.username,opponent: self.inputText.text!,token:self.chessBrain.token)
        self.prepareRequest(method: "POST", message: searchGame)
    }
}
