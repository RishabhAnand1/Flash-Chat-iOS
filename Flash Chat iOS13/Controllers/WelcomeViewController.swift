//
//  WelcomeViewController.swift
//  Flash Chat iOS13


import UIKit
//import CLTypingLabel // if using Typing pod

class WelcomeViewController: UIViewController {

    @IBOutlet weak var titleLabel:  UILabel? //if using the pod -> CLTypingLabel!
    
    //Hiding the navigation bar just befor view loads
    override func viewWillAppear(_ animated: Bool) {
        //This super... is important
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    //Revealing the navigation bar just after view disapperars
    override func viewWillDisappear(_ animated: Bool) {
        //This super... is important
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel!.text = ""
        
        //Here we used a for loop for animating our FlashChat logo while lodeup
        var characterIndex = 0.0
        let titleText = K.appName
        
            for letter in titleText {
                Timer.scheduledTimer(withTimeInterval: 0.1 * characterIndex, repeats: false) { (timer) in
                    self.titleLabel!.text?.append(letter)
                }
                characterIndex += 1.2
            }
    }
        
}

