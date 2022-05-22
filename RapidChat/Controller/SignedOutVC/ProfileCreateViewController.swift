//
//  ProfileCreateViewController.swift
//  RapidChat
//
//  Created by William Chung on 4/28/22.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class ProfileCreateViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    var username: String = ""
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var profilePic: UIImageView! // Outlet for profile pic
    @IBOutlet weak var nameLabel: UILabel!  // Outlet to display newly created user's name
    @IBOutlet weak var userNameField: UITextField! // Outlet for text field for username
    @IBOutlet weak var continueButton: UIButton! // Outlet for button to continue to main messages
    
    
    var imageSelected: Bool = false
    var success: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // Retreive the user's name
        nameLabel.text = username
        
        // Initially disable the continue button
        continueButton.isEnabled = false
        
        // Handles tapping the profile picture
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didChangeProfilePic))
        profilePic.addGestureRecognizer(gesture)
        
        // Handles tapping the main view
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapDidRecognized(tap:)))
        tap.numberOfTapsRequired = 1
        mainView.addGestureRecognizer(tap)
    }
    
    // Function presents action sheet when image is pressed
    @objc func didChangeProfilePic(){
        presentPhotoActionSheet()
    }
    
    // Function clears any keyboards
    @objc func tapDidRecognized(tap: UITapGestureRecognizer){
        userNameField.resignFirstResponder()
        if let text = userNameField.text{
            if !text.isEmpty{
                continueButton.isEnabled = true
            }
        }
    }
    
    // Action handler for when button is pressed
    @IBAction func continuePressed(_ sender: UIButton) {
        if let text = userNameField.text, !text.isEmpty{
            
            // This block of code is to just update username in database
            let email: String! = Auth.auth().currentUser?.email
            let updateReference = FirestoreManager.shared.db.collection("users").document(email)
            updateReference.getDocument { (document, err) in
                if let err = err {
                    print(err.localizedDescription)
                }
                else {
                    document?.reference.updateData(["username": text])
                }
            }
            
            // Check to see if we selected an image as well
            if imageSelected{
                guard let image = profilePic.image,
                      let data = image.pngData() else {
                            return
                }
                let filename = profilePictureFileName(em: email)
                
                // Store actual image in storage
                StorageManager.shared.uploadProfilePicture(with: data, fileName: filename, completion: {result in
                    switch result{
                    case .success(let downloadURL):
                        UserDefaults.standard.set(downloadURL, forKey: "profile-pic-url")
                    case .failure(let error):
                        print("\(error)")
                    }
                })
                
                // Store photoURL into firestore
                updateReference.getDocument { (document, err) in
                    if let err = err {
                        print(err.localizedDescription)
                    }
                    else {
                        document?.reference.updateData([
                            "photoURL": filename
                            ])
                    }
                }
            }
            success = true
        }
        else{
            return
        }
    }
    
    // Function to output a proper imageURL given a user email
    func profilePictureFileName(em: String) -> String {
        var safeEmail = em.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        return "\(safeEmail)-profile-pic.png"
    }
    
    // Provide action sheet
    func presentPhotoActionSheet(){
        let actionSheet = UIAlertController(title: "Profile Picture", message: "Select photo from library or take a picture", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Select from Camera", style: .default, handler: { [weak self] _ in self?.presentCamera()}))
        actionSheet.addAction(UIAlertAction(title: "Select from Photos", style: .default, handler: { [weak self] _ in self?.presentPhotos()}))
        
        present(actionSheet, animated: true)
    }
    
    // Function to pull out camera
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    // Function to pull out photo gallery
    func presentPhotos(){
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    // Function to choose an Image and configure it to profile layout
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else{
            return
        }
        
        profilePic.image = selectedImage
        profilePic.layer.masksToBounds = true
        profilePic.layer.cornerRadius = profilePic.frame.height / 2
        profilePic.layer.borderWidth = 2
        profilePic.layer.borderColor = UIColor.lightGray.cgColor
        
        imageSelected = true
    }
    
    // Handles dismissing the picker Controller
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    // Overriding segue function in case our user was not created successfully
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if success == false{
            return false
        }
        
        return true
    }
}

// Separating for text field delegate
extension ProfileCreateViewController: UITextFieldDelegate{
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.hasText{
            continueButton.isEnabled = true
        }
        else{
            continueButton.isEnabled = false
        }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        let name = textField == userNameField ? text : userNameField.text!
        
        if !name.isEmpty{
            continueButton.isEnabled = true
        }
        else{
            continueButton.isEnabled = false
        }
        
        return true
    }
    
    // Function to handle when return button is pressed on keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == userNameField{
            continuePressed(continueButton)
        }
        
        return true
    }
}

