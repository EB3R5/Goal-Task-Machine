import SwiftUI
import RealmSwift

struct ContentView: View {
    @StateObject var realmManager = RealmManager()
    @State private var isLoggedIn = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    @State private var action: String = ""
    @State private var location: String = ""
    @State private var cadence: String = ""
    
    // Private variables for username and password
    private let username = "christianebers@gmail.com"
    private let password = "Lincoln6840"

    var body: some View {
        VStack {
            if isLoggedIn {
                if let actions = realmManager.fetchActions() {
                    List(actions) { action in
                        VStack(alignment: .leading) {
                            Text(action.action)
                                .font(.headline)
                            Text(action.desc)
                                .font(.subheadline)
                        }
                    }
                } else {
                    Text("No data available")
                }

                VStack {
                    TextField("Action", text: $action)
                    TextField("Location", text: $location)
                    TextField("Cadence", text: $cadence)
                    Button(action: {
                        let actionOntology = ActionOntology()
                        actionOntology.action = action
                        actionOntology.location = location
                        actionOntology.cadence = cadence

                        realmManager.addAction(actionOntology: actionOntology)
                    }) {
                        Text("Add ActionOntology")
                    }
                }
                .padding()
            } else {
                Text("Logging in...")
            }
        }
        .padding()
        .alert(isPresented: $showError) {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
        .onAppear {
            print("ContentView appeared, attempting to log in...")
            realmManager.login(username: username, password: password) { result in
                switch result {
                case .success:
                    isLoggedIn = true
                    print("Logged in successfully and data should be loading.")
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    showError = true
                    print("Login failed: \(error)")
                }
            }
        }
    }
}

extension ActionOntology: Identifiable {
    var id: ObjectId {
        return _id
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
