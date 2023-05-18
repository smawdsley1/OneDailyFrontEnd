import SwiftUI

struct RegisterUserView: View {
    @State private var username: String = ""
    @State private var passwordHash: String = ""
    @State private var email: String = ""

    @State private var isRegistering = false
    @State private var registrationError: String?
    @State private var signedIn = false
    @State private var hasMatch = false
    
    private let userController = UserController()

    var body: some View {
        ZStack {


            VStack {
                TextField("Username", text: $username)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                SecureField("Password", text: $passwordHash)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Email", text: $email)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)

                //  fun button here that says registering if the user is currently registerign, otherwise it just allows the user to register
                Button(action: registerUser) {
                    Text(isRegistering ? "Registering..." : "Register")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                        .disabled(isRegistering)
                }
                .padding()

                if let error = registrationError {
                    Text("Error registering user: \(error)")
                        .foregroundColor(.red)
                        .padding()
                }
                NavigationLink("", destination: MainPageView(username: username), isActive: $signedIn)
            }
            .padding()
        }
    }

    // calls the usercontroller and registers the user
    private func registerUser() {
        self.isRegistering = true
        userController.registerUser(username: username, passwordHash: passwordHash, email: email) { result in
            switch result {
            case .success:
                print("User registered successfully")
                signedIn = true

            case .failure(let error):
                print("Error registering user: \(error)")
                if error == .usernameUnavailable {
                    self.registrationError = "Username or Email unavailable"
                } else {
                    self.registrationError = error.localizedDescription
                }
            }
            self.isRegistering = false
        }
    }
}
