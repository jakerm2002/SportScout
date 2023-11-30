//
//  CustomizeProfileViewController.swift
//  SportScoutMedinaJake
//
//  Created by Jake Medina on 10/12/23.
//

import UIKit
import FirebaseAuth
import FirebaseStorage

let appDelegate = UIApplication.shared.delegate as! AppDelegate
let context = appDelegate.persistentContainer.viewContext

protocol addSportText {
    func addSportText(newSport: String)
}

class CustomizeProfileViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, addSportText {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var inchesField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var feetField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var weightField: UITextField!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var bioField: UITextField!
    @IBOutlet weak var sportsText: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    var username = ""
    var imageURL = ""

    var customizeProfileToTabBarControllerSegueIdentifier = "CustomizeProfileToTabBarControllerSegueIdentifier"
    var chooseSportsSegueIdentifier = "chooseSportsSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.profileImage!.layer.cornerRadius = self.profileImage!.frame.size.height / 2
        self.profileImage.contentMode = .scaleAspectFill
        
        // Do any additional setup after loading the view.
        nameField.delegate = self
        usernameField.delegate = self
        weightField.delegate = self
        feetField.delegate = self
        inchesField.delegate = self
        locationField.delegate = self
        bioField.delegate = self
        
        usernameField.text = username
        sportsText.text = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let docRef = db.collection("users").document(String(uid))
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                self.nameField.text = String(describing: document.get("fullName")!)
                self.usernameField.text = String(describing: document.get("username")!)
                self.weightField.text = String(describing: document.get("weight")!)
                self.feetField.text = String(describing: document.get("feet")!)
                self.inchesField.text = String(describing: document.get("inches")!)
                self.locationField.text = String(describing: document.get("location")!)
                self.sportsText.text = String(describing: document.get("sports")!)
                self.bioField.text = String(describing: document.get("bio")!)
                let imageURL = String(describing: document.get("url")!)
                
                let fileRef = storage.reference(withPath: imageURL)
                fileRef.getData(maxSize: 1024 * 1024) { data, err in
                    if err == nil && data != nil {
                        self.profileImage.image = UIImage(data: data!)
                    }
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    // Called when 'return' key pressed
    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Called when the user clicks on the view outside of the UITextField

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        if (textField == inchesField || textField == feetField || textField == weightField) {
            return allowedCharacters.isSuperset(of: characterSet)
        }
        return characterSet.isSuperset(of: characterSet)
    }
    
    @IBAction func addPhotoButtonPressed(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        if (nameField.text == ""  || usernameField.text == ""  || weightField.text == "" || feetField.text == "" || inchesField.text == "" || locationField.text == "" || sportsText.text == "" || bioField.text == "") {
            print("CustomizeProfile error: please fill out all fields.")
            self.errorLabel.text = "Fill out all fields."
        } else {
            storeImageinStorage()
            storeUserInfo(fullName: nameField.text!, username: usernameField.text!, weight: weightField.text!, feet: feetField.text!, inches: inchesField.text!, location: locationField.text!, sports: sportsText.text!, bio: bioField.text!, url: imageURL)
            performSegue(withIdentifier: "CustomizeProfileToTabBarControllerSegueIdentifier", sender: nil)
        }
    }
    
    private func storeUserInfo(fullName: String, username: String, weight: String, feet: String, inches: String, location: String, sports: String, bio: String, url: String) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let userData = ["username": username,"fullName": fullName, "weight": weight, "feet": feet, "inches": inches, "location": location, "sports": sports, "bio": bio, "url": url]
        db.collection("users").document(uid).setData(userData)
        print("user data stored")
    }
    
    private func storeImageinStorage() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let ref = Storage.storage().reference()
        let path = "userImages/\(UUID().uuidString).jpg"
        self.imageURL = path
        let fileRef = ref.child(path)
        guard let imageData = profileImage.image?.jpegData(compressionQuality: 0.8) else {return}
        fileRef.putData(imageData, metadata: nil) { metadata, err in
            if let err = err {
                print("Failed to store image")
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            profileImage.image = image
        }
        picker.dismiss(animated: true, completion: nil)

    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func addSportText(newSport: String) {
        sportsText.text = newSport
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == chooseSportsSegueIdentifier,
           let nextVC = segue.destination as? CustomizeSportViewController
        {
            nextVC.delegate = self
        }
    }
}

