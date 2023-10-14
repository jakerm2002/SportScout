//
//  SignupViewController.swift
//  SportScoutMedinaJake
//
//  Created by Jake Medina on 10/12/23.
//

import UIKit
import FirebaseAuth

class SignupViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var errorMessage: UILabel!
    
    var SignupToCustomizeProfileSegueIdentifier = "SignupToCustomizeProfileSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Hide password
        passwordTextField.isSecureTextEntry = true
        confirmPasswordTextField.isSecureTextEntry = true
        
        
        //Check fields before segue
        if usernameTextField == nil || fullNameTextField == nil || emailTextField == nil || passwordTextField == nil {
            errorMessage.text = "One or more fields are missing"
        } else if passwordTextField != confirmPasswordTextField {
            errorMessage.text = "Passwords do not match"
        } else {
            errorMessage.text = ""
            self.performSegue(withIdentifier: self.SignupToCustomizeProfileSegueIdentifier, sender: nil)
            self.usernameTextField.text = nil
            self.fullNameTextField.text = nil
            self.emailTextField.text = nil
            self.passwordTextField.text = nil
            self.confirmPasswordTextField.text = nil
        }
        
//        Auth.auth().addStateDidChangeListener() {
//            (auth,user) in
//            if user != nil {
//                self.performSegue(withIdentifier: self.SignupToCustomizeProfileSegueIdentifier, sender: nil)
//                self.emailTextField.text = nil
//                self.passwordTextField.text = nil
//            }
//        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func signupButtonPressed(_ sender: Any) {
        // Firebase user creation
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) {
            (authResult,error) in
                if let error = error as NSError? {
                    self.errorMessage.text = "\(error.localizedDescription)"
                } else {
                    self.errorMessage.text = ""
                    self.performSegue(withIdentifier: self.SignupToCustomizeProfileSegueIdentifier, sender: nil)
                }
        }
        
//        if passwordTextField != confirmPasswordTextField {
//            self.errorMessage.text = "Passwords do not match"
//        }
        
    }
    

}
