//
//  CreateNewMessageView.swift
//  dapper
//
//  Created by Salvatore D'Armetta on 8/6/24.
//

import SwiftUI
import SDWebImageSwiftUI

class CreateNewMessageViewModel: ObservableObject {
    
    @Published var users = [ChatUser]()
    
    init(){
        fetchAllUsers()
    }
    
    private func fetchAllUsers(){
        FirebaseManager.shared.firestore.collection("users").getDocuments{ documentsSnapshot, error in
            if let error = error{
                print("Failed to fetch users: \(error)")
                return
            }
            
            documentsSnapshot?.documents.forEach({ snapshot in
                let data = snapshot.data()
                self.users.append(.init(data: data))
            })
            
        }
    }
}

struct CreateNewMessageView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var vm = CreateNewMessageViewModel()
    
    var body: some View {
        NavigationStack{
            ScrollView{
                ForEach(vm.users){user in
                    HStack{
                        WebImage(url: URL(string: user.profileImageUrl))
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .clipped()
                            .clipShape(Circle())
                            .overlay(RoundedRectangle(cornerRadius: 50)
                                .stroke(Color(.label), lineWidth: 2))
                        Text("\(user.email)")
                        Spacer()
                    }.padding(.horizontal)
                    Divider()
                        .padding(.vertical, 8)
                }
            }.navigationTitle("New Message")
                .toolbar{
                    ToolbarItemGroup(placement: .topBarLeading) {
                        Button{
                            dismiss()
                        }label: {
                            Text("Cancel")
                        }
                    }
                }
        }
    }
}

#Preview {
    CreateNewMessageView()
}
