//
//  ChatLogView.swift
//  dapper
//
//  Created by Salvatore D'Armetta on 8/10/24.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI

struct FirebaseConstants{
    static let fromId =  "fromId"
    static let toId =  "toId"
    static let text =  "text"
    static let timestamp = "timestamp"
    static let profileImageUrl = "profileImageUrl"
    static let email = "email"
}

class ChatLogViewModel: ObservableObject{
    
    @Published var chatText = "DAP"
    @Published var errorMessage = ""
    
    @Published var chatMessages = [ChatMessage]()
    
    @Published var count = 0
    
    let chatUser: ChatUser?
    
    init(chatUser: ChatUser?){
        self.chatUser = chatUser
        
        fetchDapImage()
        fetchMessages()
    }
    
    private func fetchMessages(){
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toId = chatUser?.uid else { return }
        
        FirebaseManager.shared.firestore
            .collection("messages")
            .document(fromId)
            .collection(toId)
            .order(by: "timestamp")
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to listen for messages: \(error)"
                    print(error)
                    return
                }
                
                querySnapshot?.documentChanges.forEach({ change in
                    if change.type == .added{
                        let data = change.document.data()
                        self.chatMessages.append(.init(documentId: change.document.documentID, data: data))
                    }
                })
                
                DispatchQueue.main.async{
                    self.count += 1
                }
            }
    }
    
    private func fetchDapImage(){
        let ref = FirebaseManager.shared.storage.reference(withPath: "dapImage.PNG")
        ref.downloadURL { url, error in
            if let error = error{
                print("Failed to retrieve downloadURL: \(error)")
                return
            }
            
            guard let url = url else { return }
            self.chatText = url.absoluteString
            print(self.chatText)
        }
    }
    
    func handleSend(){
        
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toId = chatUser?.uid else { return }
        
        let document = FirebaseManager.shared.firestore.collection("messages").document(fromId).collection(toId).document()
        
        let messageData = [FirebaseConstants.fromId: fromId, FirebaseConstants.toId: toId, FirebaseConstants.text: self.chatText, FirebaseConstants.timestamp: Timestamp()] as [String: Any]
        
        document.setData(messageData) {error in
            if let error = error{
                self.errorMessage = "Failed to save message into Firestore: \(error)"
                return
            }
            
            print("Successfully saved current user sending message")
            
            self.persistRecentMessage()
            
            self.count += 1
        }
        
        let recipientMessageDocument = FirebaseManager.shared.firestore.collection("messages").document(toId).collection(fromId).document()
        
        recipientMessageDocument.setData(messageData) {error in
            if let error = error{
                self.errorMessage = "Failed to save recipient message into Firestore: \(error)"
                return
            }
            
            print("Recipient saved message as well")
        }
    }
    
    private func persistRecentMessage(){
        guard let chatUser = chatUser else { return }
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toId = self.chatUser?.uid else { return }
        
        let document = FirebaseManager.shared.firestore
            .collection("recent_messages")
            .document(uid)
            .collection("messages")
            .document(toId)
        
        let data = [
            FirebaseConstants.timestamp:Timestamp(),
            FirebaseConstants.text:self.chatText,
            FirebaseConstants.fromId:uid,
            FirebaseConstants.toId: toId,
            FirebaseConstants.profileImageUrl: chatUser.profileImageUrl,
            FirebaseConstants.email: chatUser.email
        ] as [String : Any]
        
        document.setData(data){ error in
            if let error = error{
                self.errorMessage = "Failed to save recent message: \(error)"
                print("Failed to save recent message: \(error)")
                return
            }
        }
        
        let recipientMessageDocument = FirebaseManager.shared.firestore
            .collection("recent_messages")
            .document(toId)
            .collection("messages")
            .document(uid)
        
        recipientMessageDocument.setData(data){error in
            if let error = error{
                self.errorMessage = "Failed to save recent message to recipient: \(error)"
                print("Failed to save recent message to recipient: \(error)")
                return
            }
        }
        
    }
    
}



struct ChatLogView: View {
    
    let chatUser: ChatUser?
    
    let animation: Animation = Animation.easeInOut(duration: 0.2)
    @State var scale = 0.0
    
    init(chatUser: ChatUser?){
        self.chatUser = chatUser
        self.vm = .init(chatUser: chatUser)
    }
    
    
    @ObservedObject var vm: ChatLogViewModel
    
    var body: some View {
            VStack{
                scrollMessagesView
                
                chatBottomButton
            }
            .navigationTitle(chatUser?.email ?? "")
            .navigationBarTitleDisplayMode(.inline)
        
    }

    
    static let emptyScrollToString = "Empty"
    
    private var scrollMessagesView: some View{
        GeometryReader{geo in
            ScrollView{
                ScrollViewReader{ ScrollViewProxy in
                    VStack{
                        ForEach(vm.chatMessages) { message in
                            MessageView(message: message)
                        }
                        HStack{ Spacer() }
                            .id(Self.emptyScrollToString)
                    }
                    .onReceive(vm.$count) { _ in
                        withAnimation(.easeOut(duration: 0.5)){
                            ScrollViewProxy.scrollTo(Self.emptyScrollToString, anchor: .bottom)
                        }
                    }
                }
            }
            .background(Color(UIColor(white: 0.95, alpha: 1)))
            .overlay(dapperAnimation)
        }
    }
    
    private var dapperAnimation: some View{
        GeometryReader{geo in
                VStack{
                    Image("Dap")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.5, height: geo.size.height * 0.5)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .scaleEffect(scale)
                }
            }
        }
    
    private var chatBottomButton: some View{
    
        HStack{
                Button(action: {
                    vm.handleSend()
                    withAnimation(animation){
                        scale = 1.0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { // 1 sec delay
                        withAnimation(animation){
                            scale = 0.6
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // 1 sec delay
                        withAnimation(animation){
                            scale = 0.0
                        }
                    }
                    
                }, label: {
                    Image("Dap2")
                        .resizable()
                        .frame(width: 64, height: 64)
                        .clipShape(Circle())
                        .overlay(Circle()
                            .stroke(Color.black, lineWidth: 2))
                })
                .frame(width: 50, height: 50)
            }
            .padding()
    }
}

struct MessageView: View {
    
    let message: ChatMessage
    
    var body: some View {
        VStack{
            if message.fromId == FirebaseManager.shared.auth.currentUser?.uid{
                HStack{
                    Spacer()
                    HStack{
                        WebImage(url: URL(string: message.text))
                    }
                    .padding()
                }
            }
            else{
                HStack{
                    HStack{
                        WebImage(url: URL(string: message.text))
                    }
                    .padding()
                    Spacer()
                }
                
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

#Preview {
    NavigationStack{
        ChatLogView(chatUser: .init(data: ["uid": "REAL USER ID", "email":"waterfall1@gmail.com"]))
    }
}
