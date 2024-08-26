//
//  ChatUser.swift
//  dapper
//
//  Created by Salvatore D'Armetta on 8/19/24.
//

import Foundation
import Firebase

struct ChatUser: Identifiable{
    
    var id: String{ uid }
    let uid, email: String
    let profileImageUrl: String
    init(data: [String: Any]){
        self.uid = data["uid"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
    }
}
