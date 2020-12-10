//
//  ViewController.swift
//  CustomKeyboardInputView
//
//  Created by Felipe Florencio Garcia on 19/10/2020.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    // MARK: - Custom keyboard input view
    override var inputAccessoryView: UIView? {
        return <Here will come our custom input view>
    }
    
    override var canBecomeFirstResponder: Bool {
        return <Here we will tell if this screen can or can't become first responder>
    }
}

