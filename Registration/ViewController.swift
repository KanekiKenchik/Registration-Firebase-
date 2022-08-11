//
//  ViewController.swift
//  Registration
//
//  Created by Афанасьев Александр Иванович on 27.06.2022.
//

import UIKit
import SnapKit
import FirebaseAuth

protocol TestDelegate: AnyObject {
    var nameID: [String] { get set }
    func saveName(name: String, password: String)
}

class TestClass: TestDelegate {
    
    var nameID: [String] = []
    
    func saveName(name: String, password: String) {
        nameID.append(name + " - " + password)
    }
    
}

class ViewController: UITableViewController {
    
    let label: UILabel = {
        let lbl = UILabel()
        lbl.text = "Welcome"
        lbl.textColor = .white
        lbl.font = UIFont(name: lbl.font.fontName, size: 50)
        lbl.textAlignment = .center
        return lbl
    }()
    
    let logOutBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("Log Out", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .red
        setUp()
        
    }
    
    func setUp() {
        
        view.addSubview(label)
        view.addSubview(logOutBtn)
        
        label.snp.makeConstraints { make in
            make.width.equalTo(200)
            make.height.equalTo(50)
            make.centerX.centerY.equalToSuperview()
        }
        
        logOutBtn.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
        }
        
        logOutBtn.addTarget(self, action: #selector(logOut), for: .touchUpInside)
        
    }
    
    @objc func logOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error)
        }
    }
    
}

