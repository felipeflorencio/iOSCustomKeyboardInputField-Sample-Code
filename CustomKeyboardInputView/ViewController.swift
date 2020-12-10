//
//  ViewController.swift
//  CustomKeyboardInputView
//
//  Created by Felipe Florencio Garcia on 19/10/2020.
//

import UIKit

class ViewController: UIViewController, KeyboardInputAccessoryViewProtocol {
  
    // Create lazy view
    private lazy var keyboardView: KeyboardInputAccessoryView = {
        return KeyboardInputAccessoryView.view(controller: self)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    // MARK: - Custom keyboard input view
    override var inputAccessoryView: UIView? {
        return keyboardView.canBecomeFirstResponder ? keyboardView : nil
    }
    
    override var canBecomeFirstResponder: Bool {
        return keyboardView.canBecomeFirstResponder
    }
    
    // MARK: IBAction
    @IBAction func showKeyboard(_ sender: UIButton) {
        self.keyboardView.showKeyboard()
    }
    
    @IBAction func hideKeyboard(_ sender: UIButton) {
        self.keyboardView.dismissKeyboard()
    }
    
    // MARK: - Keyboard delegate
    func send(data type: String) {
        // Here we send the data from our keyboard
    }
    
    func scrollView() -> UIScrollView? {
        // We don't have any scroll view or table view, but if you have just pass the reference here :-)
        // For example would be: self.tableView
        return nil
    }
}

