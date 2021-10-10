//
//  RegisterViewController.swift
//  Flash Chat iOS13


import UIKit
import Firebase

class RegisterViewController: UIViewController {

    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var errorDetails: UILabel!
    
    @IBAction func registerPressed(_ sender: UIButton) {
        
        if let email = emailTextfield.text, let password = passwordTextfield.text {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    print(e.localizedDescription)
                    self.errorDetails.text = e.localizedDescription
                } else {
                    //Navigate to Register to Chat
                    self.errorDetails.text = ""
                    self.performSegue(withIdentifier: K.registerSegue, sender: self)
                }
                
            }
        }
        
        
    }
    
}
