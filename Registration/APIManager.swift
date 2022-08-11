//
//  APIManager.swift
//  Registration
//
//  Created by Афанасьев Александр Иванович on 04.07.2022.
//

import Foundation
import UIKit
import Firebase
import FirebaseStorage
import FirebaseDatabase

class APIManager {
    
    static let shard = APIManager()
    
    private func configureFB() -> Firestore {
        
        var db: Firestore!
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        return db
        
    }
    
    func getPost(collection: String, docName: String, completion: @escaping (User?) -> Void) {
        
        let db = configureFB()
        db.collection(collection).document(docName).getDocument { (document, error) in
            
            guard error == nil else { completion(nil); return }
            let doc = User(username: document?.get("username") as! String, password: document?.get("password") as! String)
            completion(doc)
            
        }
        
    }
    
    
    
}
