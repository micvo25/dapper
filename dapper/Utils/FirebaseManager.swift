//
//  FirebaseManager.swift
//  dapper
//
//  Created by Salvatore D'Armetta on 8/3/24.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseStorage

class FirebaseManager: NSObject {
    
    let auth: Auth
    let firestore: Firestore
    let storage: Storage
    
    static let shared = FirebaseManager()
    
    override init(){
        FirebaseApp.configure()
        
        self.auth = Auth.auth()
        self.firestore = Firestore.firestore()
        self.storage = Storage.storage()
        
        super.init()
    }
    
    
}
