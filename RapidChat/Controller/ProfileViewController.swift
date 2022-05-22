//
//  ProfileViewController.swift
//  RapidChat
//
//  Created by William Chung on 5/3/22.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    
    
    private var imageSelected: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadName()
        loadPic()
        
        // Handles gestures for profile pic (same code as profile create view controller)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didChangeProfilePic))
        profilePic.addGestureRecognizer(gesture)
        
    }
    
    // Function presents action sheet when image is pressed
    @objc func didChangeProfilePic(){
        presentPhotoActionSheet()
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
    
    // Provide action sheet
    func presentPhotoActionSheet(){
        let actionSheet = UIAlertController(title: "Profile Picture", message: "Select photo from library or take a picture", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Select from Camera", style: .default, handler: { [weak self] _ in self?.presentCamera()}))
        actionSheet.addAction(UIAlertAction(title: "Select from Photos", style: .default, handler: { [weak self] _ in self?.presentPhotos()}))
        
        present(actionSheet, animated: true)
    }
    
    // Function to handle the segue back to home controller once user is logged out
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
        
        do {
            try firebaseAuth.signOut()
            self.performSegue(withIdentifier: "unwindToHomeViewController", sender: self)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
      
    }
    
    // Function to show the name on profile view
    func loadName(){
        let email: String! = Auth.auth().currentUser?.email
        let reference = FirestoreManager.shared.db.collection("user").document(email)
        var name: String = ""
        reference.getDocument { (document, error) in
            if let e = error{
                print("\(e)")
            }
            else{
                name = document?.reference.value(forKey: "name") as! String
            }
        }
        
        nameLabel.text = name
    }
    
    
    // Function to load the picture
    func loadPic() {
        let email: String! = Auth.auth().currentUser?.email
        let refDoc = FirestoreManager.shared.db.collection("user").document(email)
        var path: String = ""
        refDoc.getDocument { (document, err) in
            if let err = err {
                print(err.localizedDescription)
            }
            else {
                let pngLink = document?.reference.value(forKey: "photoURL") as? String
                path = "images/\(pngLink!)"
            }
        }
        
        print("\(path)")
        
        // Get the photo from the storage using the email path
        StorageManager.shared.downloadURL(for: path, completion: { result in
            switch result {
            case .success(let url):
                URLSession.shared.dataTask(with: url, completionHandler: {data, _, error in
                    guard let data = data, error == nil else{
                        return
                    }
                    DispatchQueue.main.async {
                        self.profilePic.image = UIImage(data: data)
                        
                        // Formatting the image
                        self.profilePic.layer.masksToBounds = true
                        self.profilePic.layer.cornerRadius = self.profilePic.frame.height / 2
                        self.profilePic.layer.borderWidth = 2
                        self.profilePic.layer.borderColor = UIColor.lightGray.cgColor
                    }
                })
            case .failure(let error):
                print("Failed to get download url: \(error)")
            }
        })
    }
}
