//
//  LoginScreen.swift
//  MultiPeerTest
//
//  Created by Christoffer Tronje on 2017-02-13.
//  Copyright © 2017 ChristofferTronje. All rights reserved.
//

import UIKit

class LoginScreen: UIViewController, UITextFieldDelegate  {
    
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var usernameRegistered: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet var UIButtons: [UIButton]!
    
    var chessBrain = ChessBrain()
    var games:Array<Dictionary<String, Any>> = [[String:Any]]()
    var username = ""
    var password = ""
    var token = ""
    var onGoingProcess = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.usernameTextField.delegate = self
        self.passwordTextField.delegate = self
        
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signingInButton(_ sender: UIButton) {        // log in button
        
        print(usernameTextField.text != "")
        print(passwordTextField.text != "")
        print(!onGoingProcess)
        
        if usernameTextField.text != "" && passwordTextField.text != "" && !onGoingProcess{
            onGoingProcess = true
            let dic = [
                "query": "login",
                "username": usernameTextField.text!,
                "password": passwordTextField.text!
            ]
            self.sendRequest(message: dic)
        }
        else{
            self.usernameRegistered.text = "Empty fields!"
        }
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromLoginToMainView"{
            
            if let destination = segue.destination as? ViewController{
                chessBrain.games = games
                chessBrain.comingFromDestination(comingFrom: "login")
                chessBrain.username = self.username
                destination.chessBrain = chessBrain
            }
        }
    }
    
    
    @IBAction func registerButton(_ sender: UIButton) {     // register a user button
        
        if usernameTextField.text != "" && passwordTextField.text != "" && !onGoingProcess{
            onGoingProcess = true
            let dic = [
                "query": "register",
                "username": usernameTextField.text!,
                "password": passwordTextField.text!
            ]
            self.sendRequest(message: dic)
        }
        else{
            self.usernameRegistered.text = "Empty fields!"
        }
    }
    
    
    
    func sendRequest(message: Dictionary<String,String>) {
        
        let server = self.chessBrain.buildingServerMessage(IP: IP, method: "POST", message: message)
        
        let task = URLSession.shared.dataTask(with: server) { data, response, error in
            guard let _ = data, error == nil else {
                print("något gick fel")
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                
            }
                
            else if message["query"] == "login"{
                DispatchQueue.main.async {
                    let jsonData = self.chessBrain.jsonParse(jsonData: data!)
                    
                    if jsonData["response"] as? String == "Login successful"{
                        self.games = self.chessBrain.dictionaryToArray(dic:jsonData)
                        self.username = self.usernameTextField.text!
                        self.chessBrain.token = jsonData["token"] as! String
                        print("Token from login: \(self.chessBrain.token)")
                        self.performSegue(withIdentifier: "fromLoginToMainView",sender:Any?.self)
                    }
                    else{
                        self.usernameRegistered.text = jsonData["response"] as? String
                    }
                }
            }
                
            else if message["query"] == "register"{
                let res = self.chessBrain.jsonParse(jsonData: data!)
                DispatchQueue.main.async {
                    if(res["response"] as? String == "User already exists"){
                        self.usernameRegistered.text = "User already exists!"
                    }
                    else {
                        self.chessBrain.token = res["token"] as! String
                        print("Token from register: \(self.chessBrain.token)")
                        self.usernameRegistered.text = "\(self.usernameTextField.text!) is registered!"
                        self.username = self.usernameTextField.text!
                        self.usernameTextField.text = ""
                        self.performSegue(withIdentifier: "fromLoginToMainView",sender:Any?.self)
                    }
                }
            }
            self.onGoingProcess = false
            
        }
        task.resume()
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {     // remove keyboard if tocuh outside
        self.view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.placeholder = ""
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 0{
            textField.placeholder = "Username"
        }
        else if textField.tag == 1{
            textField.placeholder = "Password"
        }
    }
    
}
