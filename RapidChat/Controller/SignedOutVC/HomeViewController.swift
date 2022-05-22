//
//  ViewController.swift
//  RapidChat
//
//  Created by William Chung on 5/2/22.
//

import UIKit
import FirebaseAuth

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //validateAuth()
    }
    
    // Prepare for unwind segue from logging out action
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {

    }
    
    // If user is signed in, then we can go straight to viewing messages
//    private func validateAuth(){
//        if Auth.auth().currentUser != nil{
//            let vc = ChatsTableViewController()
//            vc.modalPresentationStyle = .fullScreen
//            present(vc, animated: false)
//        }
//    }
}

