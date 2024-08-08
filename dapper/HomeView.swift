//
//  HomeView.swift
//  dapper
//
//  Created by Salvatore D'Armetta on 7/27/24.
//

import SwiftUI
import SDWebImageSwiftUI

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

class HomeViewModel: ObservableObject{
    
    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    
    init(){
        fetchCurrentUser()
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
    
    @EnvironmentObject var userLogIn: UserLogIn
    
    @ObservedObject private var vm = HomeViewModel()
    
    var body: some View {
        NavigationView{
        
            VStack{
                Text("Current User ID: \(vm.chatUser?.uid ?? "")")
                
                customNavBar
                messagesView
            }
            .overlay(newMessageButton, alignment: .bottom)
            .navigationBarHidden(true)
        }
    }
    
    private var customNavBar: some View{
        HStack(spacing: 16){
            
            WebImage(url: URL(string: vm.chatUser?.profileImageUrl ?? ""))
                .font(.system(size: 34, weight: .heavy))
            
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
            ForEach(0..<10, id: \.self){num in
                VStack{
                    HStack(spacing: 16){
                        Image(systemName: "person.fill")
                            .font(.system(size: 32))
                            .padding(8)
                            .overlay(RoundedRectangle(cornerRadius: 44)
                                .stroke(Color(.label), lineWidth: 1))
                        VStack(alignment: .leading){
                            Text("Username")
                                .font(.system(size: 16, weight: .bold))
                            Text("Message sent to user")
                                .font(.system(size: 14))
                                .foregroundStyle(Color(.lightGray))
                        }
                        Spacer()
                        
                        Text("22d")
                            .font(.system(size: 14, weight: .semibold))
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
                Text("Dap")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
            }
            .foregroundStyle(.white)
            .padding(.vertical)
            .background(Color.red)
            .clipShape(Circle())
            .padding(.horizontal)
            .shadow(radius: 15)
            
        })
        .fullScreenCover(isPresented: $shouldShowNewMessageScreen, content: {
            CreateNewMessageView()
        })
    }
    
}

#Preview {
    HomeView()
}
