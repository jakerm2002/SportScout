//
//  LoginViewController.swift
//  SportScoutMedinaJake
//
//  Created by Jake Medina on 10/12/23.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorMessage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide password
        passwordTextField.isSecureTextEntry = true

//        Auth.auth().addStateDidChangeListener() {
//            (auth,user) in
//            if user != nil {
//                self.performSegue(withIdentifier: "loginSegue", sender: nil)
//                self.emailTextField.text = nil
//                self.passwordTextField.text = nil
//            }
//        }
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) {
            (authResult,error) in
                if let error = error as NSError? {
                    self.errorMessage.text = "Invalid email or password"
                } else {
                    self.errorMessage.text = ""
                    self.performSegue(withIdentifier: "loginSegue", sender: nil)
                }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    

}
