//
//  ContentView.swift
//  dapper
//
//  Created by Salvatore D'Armetta on 5/25/24.
//

import SwiftUI
import Firebase
import FirebaseAuth

class UserLogIn: ObservableObject{
    @Published var isLoggedIn = false
}

struct ContentView: View {
    
    @EnvironmentObject var userLogIn: UserLogIn
    @State var email = ""
    @State var password = ""
    
    var body: some View {
        
        if userLogIn.isLoggedIn == true{
            HomeView()
        }
        else{
            NavigationStack{
                VStack() {
                    Spacer()
                    Image(systemName: "person.fill")
                    Spacer()
                    VStack(spacing: 10){
                        
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .frame(height: 48)
                            .padding(EdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 6))
                            .cornerRadius(5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.red, lineWidth: 3.0)
                            )
                        
                        
                        SecureField("Password", text: $password)
                            .frame(height: 48)
                            .padding(EdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 6))
                            .cornerRadius(5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.red, lineWidth: 3.0)
                            )
                        
                        
                        Button(action: {
                            loginUser()
                        }, label: {
                            Text("Log In")
                        })
                        .padding(.horizontal, 100)
                        .padding(12)
                        .foregroundColor(.white)
                        .background(Color.red)
                        .clipShape(Capsule())
                        
                        
                    }
                    .padding(12)
                    
                    Text(self.loginStatusMessage)
                        .foregroundColor(.red)
                    
                    Spacer()
                    
                    NavigationLink("Create Account", destination: CreateAccountView())
                        .padding(12)
                        .padding(.horizontal, 65)
                        .foregroundColor(.red)
                        .background(Color.white)
                        .clipShape(Capsule())
                        .overlay{
                            Capsule(style: .continuous)
                                .stroke(Color.red, lineWidth: 5)
                        }
                    
                    Spacer()
                }
            }
        }
    }
    @State var loginStatusMessage = ""
    
    private func loginUser(){
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) {
            result, err in
            if let err = err {
                print("Failed to login user:", err)
                self.loginStatusMessage = "Failed to login user: \(err)"
                return
            }
            
            print("Successfully logged in as user: \(result?.user.uid ?? "")")
            
            self.loginStatusMessage = "Successfully logged in as user: \(result?.user.uid ?? "")"
            userLogIn.isLoggedIn = true
        }
    }

    
}

#Preview {
    ContentView()
}
