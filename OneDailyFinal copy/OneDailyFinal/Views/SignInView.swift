import SwiftUI

struct SignInView: View {
    @State private var username: String = ""
    @State private var password: String = ""

    @State private var isSigningIn = false
    @State private var signInError: String?
    @State private var signedIn: Bool? = false

    private let userController = UserController()

    var body: some View {
        NavigationView {
            VStack {
                TextField("Username", text: $username)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                SecureField("Password", text: $password)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button(action: signInUser) {
                    Text(isSigningIn ? "Signing In..." : "Sign In")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .disabled(isSigningIn)
                }
                .padding()
                // error message for signInErrors
                .alert(isPresented: Binding<Bool>(get: { signInError != nil }, set: { _ in })) {
                    Alert(
                        title: signInError != nil ? Text("Sign In Failed") : Text("Sign In Successful"),
                        message: signInError != nil ? Text(signInError!) : Text("You have successfully signed in."),
                        dismissButton: .default(Text("OK")) {
                            signInError = nil
                        }
                    )
                }
// link to main, only works if user is signed it
                NavigationLink("", destination: MainPageView(username: username), tag: true, selection: $signedIn)
                // link to sign up
                NavigationLink("Sign up", destination : RegisterUserView())
            }
            .padding()
        }
    }

    // calls user controller to sign in
    private func signInUser() {
        self.isSigningIn = true
        userController.signInUser(username: username, password: password) { result in
            switch result {
            case .success:
                print("User signed in successfully")
                DispatchQueue.main.async {
                    signedIn = true
                }
            case .failure(let error):
                print("Error signing in: \(error)")
                self.signInError = error.localizedDescription
            }
            self.isSigningIn = false
        }
    }
}

