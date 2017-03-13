//
//  SearchPlayer.swift
//  TicTacToe
//
//  Created by Christoffer Tronje on 2017-03-11.
//  Copyright © 2017 Karl Petersson. All rights reserved.
//

import UIKit

class SearchPlayer: UIViewController,UITextFieldDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.opponentLabel.delegate = self
        self.opponentLabel.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBOutlet weak var messageToUserLabel: UILabel!
    @IBOutlet weak var opponentLabel: UITextField!
    
    var chessBrain = ChessBrain()
    var backToMainView = ""
    
    @IBAction func startGameButton(_ sender: UIButton) {
        
        if opponentLabel.text!.lowercased() == self.chessBrain.username.lowercased(){
            messageToUserLabel.text = "Can't start game with yourself"
        }
        else if self.opponentLabel.text! == ""{
            messageToUserLabel.text = "Empty field!"
        }
        else{
            self.chessBrain.opponent = self.opponentLabel.text!
            backToMainView = "searchPlayer"
            performSegue(withIdentifier: "toViewController", sender: self)
        }
    }
    
    @IBAction func backToMainView(_ sender: UIButton) {
        backToMainView = "login"
        performSegue(withIdentifier: "toViewController", sender: self)
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toViewController"{
            if let destination = segue.destination as? ViewController{
                chessBrain.comingFromDestination(comingFrom: self.backToMainView)
                destination.chessBrain = self.chessBrain
            }
        }
        
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        opponentLabel.placeholder = ""
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        opponentLabel.placeholder = "Opponent username"
    }
    
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {     // remove keyboard if tocuh outside
        self.view.endEditing(true)
    }
    
    
}
