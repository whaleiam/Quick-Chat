//
//  ChatViewController.swift
//  RapidChat
//
//  Created by William Chung on 5/3/22.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

//, UIPickerViewDelegate, UIPickerViewDataSource

class ChatViewController: UIViewController, UITextFieldDelegate{
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var messageCount: UILabel!
    
    let db = Firestore.firestore()
    
    var messages: [Message] = [
        Message(sender: "me", body: "Hello!"),
        Message(sender: "me", body: "Fuck you!"),
        Message(sender: "me", body: "You're Gay!"),
        Message(sender: "me", body: "Cunts!"),
    ]
    
    // Array to hold numerical values for picker
    let seconds = [5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
    // Initialize picker view
    var pickerView = UIPickerView()
    
    // Seconds variable that other user has to send message by
    var timeLimit: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "message")
        
        // Picker View related code
        pickerView.dataSource = self
        pickerView.delegate = self

        // Delegate for text field
        messageTextField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)

    }
    
    // Delegate function for when the text field changes
    @objc func textFieldDidChange(textField : UITextField){
        let count = messageTextField.text!.count
        
        // If we go less than 10 characters, text changes to red
        if(65 - count) <= 10{
            messageCount.textColor = UIColor.red
        }
        else{
            messageCount.textColor = UIColor.white
        }
        
        // Update count label text
        messageCount.text = "\(65-count)"
      }
    
    // Event handler to handle when user tries to send a message
    @IBAction func sendPressed(_ sender: UIButton) {
        // We need a valid time limit
//        if timeLimit == 0 {
//            showAlert()
//            return
//        }
        
        // The message itself must be more than 2 characters long
        if messageTextField.text!.count >= 2{
            if let messageBody = messageTextField.text,
            let messageSender = Auth.auth().currentUser?.email {
                db.collection("messages").addDocument(data: ["sender": messageSender, "body": messageBody], completion: {error in
                    if let e = error{
                        print("\(e)")
                    }else{
                        print("Successfully saved data")
                    }
                })
            }
        }
    }

    @IBAction func secondsSelect(_ sender: UIButton) {
        
    }
    
    // Function to handle the action alert for when no time limit is chosen
    func showAlert(){
        let alert = UIAlertController(title: "Invalid Time Limit", message: "Please choose a valid time limit", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: {action in}))
    }
}
    

extension ChatViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    // Protocols for UI Picker View
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return seconds.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(seconds[row])"
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        timeLimit = seconds[row]
        pickerView.resignFirstResponder()
    }
    // End protocols for UI Picker View
}

extension ChatViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "message", for: indexPath) as! MessageCell
        cell.label.text = messages[indexPath.row].body
        return cell
    }
}

