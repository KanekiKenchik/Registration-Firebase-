//
//  ViewController.swift
//  Registration
//
//  Created by Афанасьев Александр Иванович on 27.06.2022.
//

import UIKit
import SnapKit
import FirebaseAuth
import FirebaseDatabase

class CustomButton: UIButton {

    var color: UIColor = .black
    let touchDownAlpha: CGFloat = 0.3
    weak var timer: Timer?
    let timerStep: TimeInterval = 0.01
    let animateTime: TimeInterval = 1
    lazy var alphaStep: CGFloat = {
        return (1 - touchDownAlpha) / CGFloat(animateTime / timerStep)
    }()

    func setup() {
        backgroundColor = .systemBlue
        layer.backgroundColor = color.cgColor

        layer.cornerRadius = 6
        clipsToBounds = true
    }
    
    convenience init(color: UIColor? = nil, title: String? = nil) {
        self.init(type: .custom)

        if let color = color {
            self.color = color
        }

        if let title = title {
            setTitle(title, for: .normal)
        }

        setup()
    }
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                touchDown()
            } else {
                cancelTracking(with: nil)
                touchUp()
            }
        }
    }

    func stopTimer() {
        timer?.invalidate()
    }

    deinit {
        stopTimer()
    }
    
    func touchDown() {
        stopTimer()
        layer.backgroundColor = color.withAlphaComponent(touchDownAlpha).cgColor
    }

    func touchUp() {
        timer = Timer.scheduledTimer(timeInterval: timerStep,
                                     target: self,
                                     selector: #selector(animation),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    @objc func animation() {
        guard let backgroundAlpha = layer.backgroundColor?.alpha else {
            stopTimer()

            return
        }

        let newAlpha = backgroundAlpha + alphaStep

        if newAlpha < 1 {
            layer.backgroundColor = color.withAlphaComponent(newAlpha).cgColor
        } else {
            layer.backgroundColor = color.cgColor

            stopTimer()
        }
    }
    
}

class AuthViewController: UIViewController {
    
    var signUp = false {
        willSet {
            if newValue {
                label.text = "Registration"
                nameField.isHidden = false
                questRegLabel.text = "Already have an account?"
                registrationButton.setTitle("Sign In", for: .normal)
                submitButton.setTitle("Register", for: .normal)
            } else {
                label.text = "Log In"
                nameField.isHidden = true
                questRegLabel.text = "Don't have an account?"
                registrationButton.setTitle("Sign Up", for: .normal)
                submitButton.setTitle("Log In", for: .normal)
            }
        }
    }
    
    let label: UILabel = {
        let lbl = UILabel()
        lbl.text = "Sign In"
        lbl.font = UIFont(name: lbl.font.fontName, size: 30)
        lbl.textAlignment = .center
        return lbl
    }()
    
    let questRegLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Don't have an account?"
        return lbl
    }()
    
    let registrationButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Sign Up", for: .normal)
        btn.setTitleColor(.systemBlue, for: .normal)
        return btn
    }()
    
    let nameField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Name"
        tf.borderStyle = .roundedRect
        tf.isHidden = true
        return tf
    }()
    
    let usernameField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.borderStyle = .roundedRect
        return tf
    }()
    
    let passwordField: UITextField = {
        let pastf = UITextField()
        pastf.placeholder = "Password"
        pastf.textContentType = .password
        pastf.isSecureTextEntry = true
        pastf.borderStyle = .roundedRect
        return pastf
    }()
    
    let submitButton: CustomButton = {
        let btn = CustomButton(color: .systemBlue, title: "Log In")
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
    }

    func setupViews() {
        
        view.backgroundColor = .secondarySystemBackground
        
        view.addSubview(nameField)
        view.addSubview(usernameField)
        view.addSubview(passwordField)
        view.addSubview(submitButton)
        view.addSubview(questRegLabel)
        view.addSubview(registrationButton)
        view.addSubview(label)
        
        
        label.snp.makeConstraints { make in
            make.width.equalTo(200)
            make.height.equalTo(50)
            make.centerX.equalToSuperview()
        }
        
        nameField.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(30)
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalTo(35)
            make.centerX.equalToSuperview()
        }

        usernameField.snp.makeConstraints { make in
            make.top.equalTo(nameField.snp.bottom).offset(8)
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalTo(35)
            make.centerX.equalToSuperview()
        }
        
        passwordField.snp.makeConstraints { make in
            make.top.equalTo(usernameField.snp.bottom).offset(8)
            make.width.equalToSuperview().multipliedBy(0.9)
            make.centerX.centerY.equalToSuperview()
        }

        submitButton.snp.makeConstraints { make in
            make.top.equalTo(passwordField.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
        }
        
        questRegLabel.snp.makeConstraints { make in
            make.top.equalTo(submitButton.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
        }
        
        registrationButton.snp.makeConstraints { make in
            make.top.equalTo(questRegLabel.snp.bottom)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
        }
        
        registrationButton.addTarget(self, action: #selector(addNewEntry), for: .touchUpInside)
        submitButton.addTarget(self, action: #selector(createNewUser), for: .touchDown)
        
    }
    
    @objc func createNewUser() {
        let name = nameField.text!
        let email = usernameField.text!
        let password = passwordField.text!
        
        if signUp {
            if !name.isEmpty && !email.isEmpty && !password.isEmpty {
                Auth.auth().createUser(withEmail: email, password: password) { result, error in
                    
                    if error == nil {
                        if let result = result {
                            print(result.user.uid)
                            let ref = Database.database().reference().child("users")
                            ref.child(result.user.uid).updateChildValues(["name": name, "email": email, "password": password])
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                    
                }
            } else {
                showAlert()
            }
            
        } else {
            if !email.isEmpty && !password.isEmpty {
                Auth.auth().signIn(withEmail: email, password: password) { result, error in
                    
                    if error == nil {
                        self.dismiss(animated: true, completion: nil)
                    }
                    
                }
            } else {
                showAlert()
            }
            
        }
    }
    
    @objc func addNewEntry() {
        signUp = !signUp
    }

    func showAlert() {
        let alert = UIAlertController(title: "Error", message: "Fill in all the fields", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}

