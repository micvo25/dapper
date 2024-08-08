//
//  CreateAccountView.swift
//  dapper
//
//  Created by Salvatore D'Armetta on 7/26/24.
//

import SwiftUI

struct CreateAccountView: View {
    
    @EnvironmentObject var userLogIn: UserLogIn
    @State var email = ""
    @State var password = ""
    @State var reviewPassword = ""
    @State var showingAlert = false
    
    var body: some View {
        NavigationStack{
            VStack(spacing: 100){
                Spacer()
                Image(systemName: "person.fill")
                VStack{
                    
                    Group{
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
                            .textContentType(.newPassword)
                        
                        SecureField("Re-Enter Password", text: $reviewPassword)
                            .frame(height: 48)
                            .padding(EdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 6))
                            .cornerRadius(5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.red, lineWidth: 3.0)
                            )
                            .textContentType(.newPassword)
                    }
                    .padding(12)
                    .background()
                    
                    Button(action: {
                        if password == reviewPassword{
                            createNewAccount()
                        }
                        else{
                            showingAlert.toggle()
                        }
                    }, label: {
                        Text("Create Account")
                    })
                        .padding(.horizontal, 100)
                        .padding(12)
                        .foregroundColor(.white)
                        .background(Color.red)
                        .clipShape(Capsule())
                        .alert(isPresented: $showingAlert){
                            Alert(title: Text("Incorrect Password"), message: Text("The password you entered is incorrect. Please try again."))
                        }
                    
                }
                Text(self.loginStatusMessage)
                    .foregroundColor(.red)
                Spacer()
                Spacer()
            }
        }
        
    }
    
    @State var loginStatusMessage = ""
    
    private func createNewAccount(){
        FirebaseManager.shared.auth.createUser(withEmail: email, password:  password){
            result, err in
            if let err = err {
                print("Failed to create user:", err)
                self.loginStatusMessage = "Failed to create user: \(err)"
                return
            }
            
            print("Successfully created user: \(result?.user.uid ?? "")")
            
            self.loginStatusMessage = "Successfully created user: \(result?.user.uid ?? "")"
            
            self.getEmptyProfileImageUrl()
        }
    }
    
//    private func persistImageToStorage(){
//        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
//        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
//        guard let imageData = Image("blank-profile-picture").jpegData(withCompressionQuality: 0.5, actions: <#T##UIGraphicsImageRenderer.DrawingActions#>)
//        
//    }
    
    private func getEmptyProfileImageUrl(){
        let ref = FirebaseManager.shared.storage.reference(withPath: "blank-profile-picture.png")
        ref.downloadURL { url, error in
            if let error = error{
                print("Failed to retrieve downloadURL: \(error)")
                return
            }
            
            guard let url = url else { return }
            self.storeUserInformation(imageProfileUrl: url)
        }
    }
    
    private func storeUserInformation(imageProfileUrl: URL){
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        let userData = ["email": self.email, "uid":uid, "profileImageUrl": imageProfileUrl.absoluteString]
        FirebaseManager.shared.firestore.collection("users")
            .document(uid).setData(userData){ err in
                if let err = err {
                    print(err)
                    self.loginStatusMessage = "\(err)"
                    return
                }
                
                print("Success")
                userLogIn.isLoggedIn = true
            }
    }
    
}

#Preview {
    CreateAccountView()
}
