//
//  CustomizeProfileViewController.swift
//  SportScoutMedinaJake
//
//  Created by Jake Medina on 10/12/23.
//

import UIKit
import CoreData
import FirebaseAuth

let appDelegate = UIApplication.shared.delegate as! AppDelegate
let context = appDelegate.persistentContainer.viewContext

class CustomizeProfileViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var inchesField: UITextField!
    @IBOutlet weak var feetField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var weightField: UITextField!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    let tabBarSegueIdentifier = "TabBarSegue"
    
    var username:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        inchesField.delegate = self
        feetField.delegate = self
        weightField.delegate = self
        nameField.delegate = self
        usernameLabel.text = username
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
        if (textField == inchesField || textField == feetField) {
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
        if (nameField.text == ""  || weightField.text == "" || feetField.text == "" || inchesField.text == "") {
            print("error")
            self.errorLabel.text = "Fill out all fields."
        } else {
            let profile = NSEntityDescription.insertNewObject(forEntityName: "Profile", into: context)
            profile.setValue(nameField.text, forKey: "fullName")
            profile.setValue(usernameLabel.text, forKey: "username")
            profile.setValue(weightField.text, forKey: "weight")
            profile.setValue(inchesField.text, forKey: "inches")
            profile.setValue(feetField.text, forKey: "feet")
            saveContext()
            storeUserInfo(fullName: nameField.text!, username: usernameLabel.text!, weight: weightField.text!, inches: inchesField.text!, feet: feetField.text!)
//            self.performSegue(withIdentifier: self.tabBarSegueIdentifier, sender: nil)
        }
    }
    
    private func storeUserInfo(fullName: String, username: String, weight: String, inches: String, feet: String) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let userData = ["uid": uid, "fullName": fullName, "username": username, "weight": weight, "inches": inches, "feet":feet]
        db.collection("users").document(uid).setData(userData)
        print("user data stored")
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            profileImage.image = image
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}

