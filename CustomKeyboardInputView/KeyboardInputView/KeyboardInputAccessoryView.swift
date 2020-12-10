//
//  KeyboardInputAccessoryView.swift
//  CustomKeyboardInputView
//
//  Created by Felipe Florencio Garcia on 19/10/2020.
//

import UIKit

protocol KeyboardInputAccessoryViewProtocol where Self: UIViewController {
    
    func send(data type: String)
    
    // Keyboard automatically adjusts your scroll view inset
    func scrollView() -> UIScrollView?
}

internal struct InputContainerViewConstants {
    static let maxInputMessageContainerViewHeight: CGFloat = 220.0
    static let containerInsetsDefault = UIEdgeInsets(top: 10, left: 8, bottom: 8, right: 30)
}

class KeyboardInputAccessoryView: UIView {
    
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var inputHeightConstraint: NSLayoutConstraint!

    private weak var delegate: KeyboardInputAccessoryViewProtocol?
    private weak var hostViewController: KeyboardInputAccessoryViewProtocol?
    private var firstResponder: Bool = false
    private var inputMessageTextViewHeight: CGFloat = 0.0

    class func view(controller: KeyboardInputAccessoryViewProtocol) -> KeyboardInputAccessoryView {
        guard let view = Bundle.main.loadNibNamed(String(describing: KeyboardInputAccessoryView.self), owner: nil, options: nil)?.first as? KeyboardInputAccessoryView else { fatalError() }
        view.delegate = controller
        view.inputTextView.delegate = view
        view.hostViewController = controller
        
        setupUI(view: view)
        return view
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // Control the automatic expansion of the text view
    // as also control the maximum size that can grow
    override var intrinsicContentSize: CGSize {
        let size = textViewSize(height: &inputMessageTextViewHeight,
                                maxInputHeight: InputContainerViewConstants.maxInputMessageContainerViewHeight,
                                textView: inputTextView)
        self.inputHeightConstraint.constant = size.height
        return size
    }
    
    override var canBecomeFirstResponder: Bool {
        return firstResponder
    }
    
    class private func setupUI(view: KeyboardInputAccessoryView) {
        view.inputTextView.font = UIFont.systemFont(ofSize: 16)
        view.inputTextView.isScrollEnabled = false
        view.inputTextView.layer.cornerRadius = 18
        view.inputTextView.textContainerInset = InputContainerViewConstants.containerInsetsDefault

    }
    
    // MARK: - Actions Buttons
    @IBAction func send(_ sender: UIButton) {
        delegate?.send(data: self.inputTextView.text)
        dismissKeyboard()
    }
    
    @IBAction func dismiss(_ sender: UIButton) {
        dismissKeyboard()
    }
    
    // MARK: - Public functions
    func showKeyboard() {
        setupKeyboardNotification()
        
        DispatchQueue.main.async {
            
            self.firstResponder = true
            self.delegate?.becomeFirstResponder()
            self.inputTextView.becomeFirstResponder()
        }
    }
    
    func dismissKeyboard() {
        
        self.inputTextView.text = nil // we clean our keyboard
        firstResponder = false
        self.inputTextView.resignFirstResponder()
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Private
    private func textViewSize(height: inout CGFloat,
                              maxInputHeight: CGFloat,
                              textView: UITextView) -> CGSize {
        let textSize = textView.sizeThatFits(CGSize(width: textView.bounds.width,
                                                    height: CGFloat.greatestFiniteMagnitude))
        
        if textSize.height >= maxInputHeight {
            height = maxInputHeight
            textView.isScrollEnabled = true
        } else {
            textView.isScrollEnabled = false
            height = textSize.height
        }
        return CGSize(width: self.bounds.width, height: height)
    }
    
    private func setupKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Keyboard avoid
    @objc private func keyboardWillShow(notification: NSNotification) {
        sendButton.isEnabled = !(self.inputTextView.text == nil || self.inputTextView.text == "")
        
        if let scrollView = self.hostViewController?.scrollView(), let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let size = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            scrollView.contentInset = size
            scrollView.scrollIndicatorInsets = size
            scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentSize.height), animated: true) // Scrolls to end
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        self.hostViewController?.scrollView()?.contentInset = .zero
        self.hostViewController?.scrollView()?.scrollIndicatorInsets = .zero
    }
}

extension KeyboardInputAccessoryView: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        placeholderLabel.isHidden = !textView.text.isEmpty
        sendButton.isEnabled = !(textView.text == nil || textView.text == "")
    }
}
