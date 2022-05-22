//
//  LoginViewController.swift
//  RapidChat
//
//  Created by William Chung on 5/3/22.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet var mainView: UIView! // Main View
    @IBOutlet weak var emailTextField: UITextField! // Text field for email
    @IBOutlet weak var passwordTextField: UITextField! // Text field for password
    @IBOutlet weak var errorLabel: UILabel! // Label to output error message
    
    private var infoCorrect: Bool = false // Bool variable to keep track on whether the login info is correct

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapDidRecognized(tap:)))
        tap.numberOfTapsRequired = 1
        
        mainView.addGestureRecognizer(tap)
    }
    
    @objc func tapDidRecognized(tap: UITapGestureRecognizer){
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    
    // Handle when the login button is pressed
    @IBAction func loginPressed(_ sender: UIButton) {
        
        // Populate variables to pass into authentification
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              !email.isEmpty,
              !password.isEmpty else{
            return
        }
        
        // Try to sign in user
        Auth.auth().signIn(withEmail: email, password: password, completion: { authResult, error in
            guard let result = authResult, error == nil else{
                self.errorLabel.text = "*Invalid email or password"
                self.errorLabel.textColor = UIColor.red
                return
            }
            
            self.infoCorrect = true
        })
        
    }

}
