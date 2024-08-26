//
//  HomeView.swift
//  dapper
//
//  Created by Salvatore D'Armetta on 7/27/24.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase

class HomeViewModel: ObservableObject{
    
    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    
    init(){
        fetchCurrentUser()
        
        fetchRecentMessages()
    }
    
    @Published var recentMessages = [RecentMessage]()
    
    private func fetchRecentMessages(){
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        FirebaseManager.shared.firestore
            .collection("recent_messages")
            .document(uid)
            .collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener { querySnapshot, error in
                if let error = error{
                    self.errorMessage = "Failed to listen for recent messages: \(error)"
                    print(error)
                    return
                }
                
                querySnapshot?.documentChanges.forEach({ change in
                    let docId = change.document.documentID
                    
                    if let index = self.recentMessages.firstIndex(where: { rm in
                        return rm.documentId == docId
                    }){
                        self.recentMessages.remove(at: index)
                    }
                    
                    self.recentMessages.insert(.init(documentId: docId, data: change.document.data()), at: 0)
                })
            }
    }
    
    private func fetchCurrentUser(){
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            self.errorMessage = "Could not find firebase UID"
            return
        }
        
        
        self.errorMessage = "\(uid)"
        FirebaseManager.shared.firestore.collection("users").document(uid).getDocument{ snapshot, error in
            if let error = error{
                print("Failed to fetch current user:", error)
                return
            }
            
            guard let data = snapshot?.data() else { return }
            print(data)
            
            self.chatUser = .init(data: data)
        }
    }
    
}


struct HomeView: View {
    
    @State var shouldShowLogOutOptions = false
    @State var shouldNavigateToChatLogView = false
    @State var chatUser: ChatUser?

    @EnvironmentObject var userLogIn: UserLogIn
    
    @ObservedObject private var vm = HomeViewModel()
    
    var body: some View {
        NavigationStack{
        
            VStack{
                customNavBar
                messagesView
            }
            .navigationDestination(isPresented: $shouldNavigateToChatLogView, destination: {
                ChatLogView(chatUser: self.chatUser)
            })
            .overlay(newMessageButton, alignment: .bottom)
            .navigationBarHidden(true)
        }
    }
    
    private var customNavBar: some View{
        HStack(spacing: 16){
            
            WebImage(url: URL(string: vm.chatUser?.profileImageUrl ?? ""))
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .overlay(RoundedRectangle(cornerRadius: 44)
                    .stroke(Color(.label), lineWidth: 1))
            
            VStack(alignment: .leading, spacing: 4){
                let email = vm.chatUser?.email.replacingOccurrences(of: "@gmail.com", with: "") ?? ""
                
                Text(email)
                    .font(.system(size: 24, weight: .bold))
                
                HStack{
                    Circle()
                        .foregroundStyle(.green)
                        .frame(width: 14, height: 14)
                    Text("online")
                        .font(.system(size: 12))
                        .foregroundStyle(Color(.lightGray))
                }
            }
            
            Spacer()
            Button{
                shouldShowLogOutOptions.toggle()
            } label: {
                Image(systemName: "gear")
                    .font(.system(size: 24, weight: .bold))
            }
            
        }
        .padding()
        .actionSheet(isPresented: $shouldShowLogOutOptions){
            .init(title: Text("Settings"), message: Text("What do you want to do?"), buttons: [
                .destructive(Text("Sign Out"), action: {
                    print("handle sign out")
                    userLogIn.isLoggedIn = false
                    try? FirebaseManager.shared.auth.signOut()
                }),
                .cancel()
                ])
        }
    }
    
    private var messagesView: some View{
        ScrollView{
            ForEach(vm.recentMessages){ recentMessage in
                VStack{
                    NavigationLink {
                        Text("Destination")
                    } label: {
                        HStack(spacing: 16){
                            WebImage(url: URL(string: recentMessage.profileImageUrl))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 64, height: 64)
                                .clipped()
                                .clipShape(Circle())
                                .overlay(RoundedRectangle(cornerRadius: 44)
                                    .stroke(Color(.label), lineWidth: 1))
                            VStack(alignment: .leading, spacing: 8){
                                Text(recentMessage.email)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(Color(.label))
                                Text("DAP")
                                    .font(.system(size: 14))
                                    .foregroundStyle(Color(.lightGray))
                                    .multilineTextAlignment(.leading)
                            }
                            Spacer()
                            
                            Text("22d")
                                .font(.system(size: 14, weight: .semibold))
                        }
                    }
                    Divider()
                        .padding(.vertical, 8)
                }.padding(.horizontal)
            }.padding(.bottom, 50)
        }
    }
    
    @State var shouldShowNewMessageScreen = false
    
    private var newMessageButton: some View{
        Button(action: {
            shouldShowNewMessageScreen.toggle()
        }, label: {
            HStack{
                Spacer()
                Image("Dap2")
                    .resizable()
                    .frame(width: 64, height: 64)
                    .clipShape(Circle())
                    .overlay(Circle()
                        .stroke(Color.black, lineWidth: 2))
                    .shadow(radius: 15)
                Spacer()
            }
        })
        .fullScreenCover(isPresented: $shouldShowNewMessageScreen, content: {
            CreateNewMessageView(didSelectNewUser: { user in
                print(user.email)
                self.shouldNavigateToChatLogView.toggle()
                self.chatUser = user
            })
        })
    }
    
    }
#Preview {
    ContentView()
        .environmentObject(UserLogIn())
}
