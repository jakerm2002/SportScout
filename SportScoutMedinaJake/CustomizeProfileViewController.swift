//
//  CustomizeProfileViewController.swift
//  SportScoutMedinaJake
//
//  Created by Jake Medina on 10/12/23.
//

import UIKit
import CoreData

let appDelegate = UIApplication.shared.delegate as! AppDelegate
let context = appDelegate.persistentContainer.viewContext

class CustomizeProfileViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var inchesField: UITextField!
    @IBOutlet weak var feetField: UITextField!
    @IBOutlet weak var weightField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    
    let tabBarSegueIdentifier = "TabBarSegue"
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        inchesField.delegate = self
        feetField.delegate = self
        weightField.delegate = self
        usernameField.delegate = self
        nameField.delegate = self
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
        if (nameField.text == "" || usernameField.text == "" || weightField.text == "" || feetField.text == "" || inchesField.text == "") {
            let controller = UIAlertController(
                title: "Missing info",
                message: "Please fill all fields before submitting.",
                preferredStyle: .alert
            )
            present(controller, animated: true)
        } else {
            let profile = NSEntityDescription.insertNewObject(forEntityName: "Profile", into: context)
            profile.setValue(nameField.text, forKey: "name")
            profile.setValue(usernameField.text, forKey: "username")
            profile.setValue(weightField.text, forKey: "weight")
            profile.setValue(inchesField.text, forKey: "inches")
            profile.setValue(feetField.text, forKey: "feet")
            saveContext()
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            profileImage.image = image
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == tabBarSegueIdentifier,
           let destination = segue.destination as? SSTabBarController
        {
            print("Completed segue")
        }
        
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

