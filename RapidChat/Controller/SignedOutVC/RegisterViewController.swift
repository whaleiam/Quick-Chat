//
//  RegisterViewController.swift
//  RapidChat
//
//  Created by William Chung on 5/3/22.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet var mainView: UIView! // Main View
    @IBOutlet weak var emailTextField: UITextField! // Text field for email
    @IBOutlet weak var passwordTextField: UITextField! // Text field for password
    @IBOutlet weak var nameTextField: UITextField! // Text field for full name
    @IBOutlet weak var verifyTextField: UITextField! // Text field to verify password
    @IBOutlet weak var errorSignUp: UILabel! // Label to show messages for incorrect inputs
    @IBOutlet weak var matchingError: UILabel! // Label to show that passwords are not matching
    @IBOutlet weak var register: UIButton! // Register button outlet
    
    private var userCreated: Bool = false // Boolean value to track whether user was successfully created
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Add a tap gesture on the main view to dismiss keyboards
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapDidRecognized(tap:)))
        tap.numberOfTapsRequired = 1
        mainView.addGestureRecognizer(tap)
    }
    
    // Selector function for the tap gesture on the main view
    @objc func tapDidRecognized(tap: UITapGestureRecognizer){
        emailTextField.resignFirstResponder()
        nameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        verifyTextField.resignFirstResponder()
    }
    
    // Action function for when the register button is pressed
    @IBAction func registerPressed(_ sender: UIButton) {
        matchingError.text = ""
        errorSignUp.text = ""
        
        // If block to see if each text field is not null
        if let email = emailTextField.text,
           let fullName = nameTextField.text,
           let password = passwordTextField.text,
           let verify = verifyTextField.text{
            
            // Look to see if the passwords match
            if verify == password {
                Auth.auth().createUser(withEmail: email, password: password, completion: { authResult, error in
                    if let x = error {
                        let err = x as NSError
                        
                        if err.code == AuthErrorCode.emailAlreadyInUse.rawValue{
                            self.errorSignUp.text = "*That email is already in use!"
                            self.errorSignUp.textColor = UIColor.red
                            self.clear()
                        }else{
                            self.errorSignUp.text = "*There was an issue with registration!"
                            self.errorSignUp.textColor = UIColor.red
                            self.clear()
                        }
                        return
                    }
                    
                    // Call the add user function to add user into firestore
                    FirestoreManager.shared.addUser(with: User(fullName: fullName, email: email))
                    
                    self.userCreated = true
                })
            }
            else{
                matchingError.text = "*Passwords do not match!"
                clearPasswords()
            }
        }
    }

    
    // Helper function to clear out the password text fields
    func clearPasswords(){
        passwordTextField.text = ""
        verifyTextField.text = ""
    }
    
    // Helper function to clear out all text fields
    func clear(){
        emailTextField.text = ""
        nameTextField.text = ""
        passwordTextField.text = ""
        verifyTextField.text = ""
    }
    
    // Function to handle when return button is pressed on keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            nameTextField.becomeFirstResponder()
        }
        else if textField == nameTextField{
            passwordTextField.becomeFirstResponder()
        }
        else if textField == passwordTextField{
            verifyTextField.becomeFirstResponder()
        }
        else{
            resignFirstResponder()
            registerPressed(register)
        }
        
        return true
    }
    
    // Overriding segue function in case our user was not created successfully
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if userCreated == false{
            return false
        }
        
        return true
    }
    
    // Make it easier for us to just pass value through segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ProfileCreateViewController{
            let vc = segue.destination as? ProfileCreateViewController
            vc?.username = nameTextField.text!
        }
    }
}
