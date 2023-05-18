import Foundation
import SwiftUI

struct EditAccountView: View {
    @State private var currentUser: UpdateUser?
    @State private var errorMessage = ""
    @State private var showAlert = false

    private let userController = UserController()
    var username: String

    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var bio: String = ""

    var body: some View {
        VStack {
            if let user = currentUser {
                Form {
                    Section {
                        HStack {
                            Text("Username:")
                            Spacer()
                            Text(user.Username ?? "")
                        }
                        HStack {
                            Text("Email:")
                            Spacer()
                            TextField("Email", text: $email)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        HStack {
                            Text("First Name:")
                            Spacer()
                            TextField("First Name", text: $firstName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        HStack {
                            Text("Last Name:")
                            Spacer()
                            TextField("Last Name", text: $lastName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        HStack {
                            Text("Bio:")
                            Spacer()
                            TextField("Bio", text: $bio)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                }
                
                // goes to select interests
                NavigationLink(destination: SelectInterestsView(viewModel: UserInterestsViewModel(username: username, interestService: InterestService()))) {
                    Text("Select Interests")
                }
                .padding(.top)
                .padding(.bottom, 10)
                
                // updates the user upon click
                Button("Update User") {
                    let updatedUser = UpdateUser(
                        UserId: user.UserId,
                        FirstName: firstName.isEmpty ? user.FirstName : firstName,
                        LastName: lastName.isEmpty ? user.LastName : lastName,
                        Username: user.Username,
                        Email: email.isEmpty ? user.Email : email,
                        DateOfBirth: user.DateOfBirth,
                        Bio: bio.isEmpty ? user.Bio : bio,
                        ProfilePicture: user.ProfilePicture
                    )
                    userController.updateUser(updateUser: updatedUser) { result in
                        switch result {
                        case .success:
                            errorMessage = "User updated successfully"
                        case .failure(let error):
                            errorMessage = "Didn't work: \(error.localizedDescription)"
                        }
                        showAlert = true
                    }
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Update"),
                        message: Text(errorMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }

            } else {
                Text("Loading user data...")
                    .onAppear {
                        userController.fetchUser(username: username) { result in
                            switch result {
                            case .success(let fetchedUser):
                                currentUser = fetchedUser
                                firstName = fetchedUser.FirstName ?? ""
                                lastName = fetchedUser.LastName ?? ""
                                email = fetchedUser.Email ?? ""
                                bio = fetchedUser.Bio ?? ""
                            case .failure(let error):
                                errorMessage = error.localizedDescription
                                showAlert = true
                            }
                        }
                    }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
    }
}
