//
//  ChatMessage.swift
//  dapper
//
//  Created by Salvatore D'Armetta on 8/19/24.
//

import Foundation
import Firebase

struct ChatMessage: Identifiable{
    
    var id: String { documentId }
    
    let documentId: String
    
    let fromId, toId, text: String
    
    init(documentId: String, data: [String:Any]){
        self.documentId = documentId
        self.fromId = data[FirebaseConstants.fromId] as? String ?? ""
        self.toId = data[FirebaseConstants.toId] as? String ?? ""
        self.text = data[FirebaseConstants.text] as? String ?? ""
    }
}
