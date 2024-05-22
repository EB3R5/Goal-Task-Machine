import SwiftUI
import RealmSwift

struct ContentView: View {
    @StateObject var realmManager = RealmManager()
    @State private var isLoggedIn = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var selectedLocation: String?

    // Private variables for username and password
    private let username = "christianebers@gmail.com"
    private let password = "Lincoln6840"

    var body: some View {
        NavigationView {
            VStack {
                if isLoggedIn {
                    if let locations = realmManager.fetchLocations() {
                        let sortedLocations = locations.sorted() // Sort locations alphabetically
                        List(sortedLocations, id: \.self) { location in
                            NavigationLink(
                                destination: ActionsView(realmManager: realmManager, location: location),
                                tag: location,
                                selection: $selectedLocation
                            ) {
                                Text(location)
                            }
                        }
                    } else {
                        Text("No data available")
                    }
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
}

struct ActionsView: View {
    @ObservedObject var realmManager: RealmManager
    var location: String

    var body: some View {
        VStack {
            if let actions = realmManager.fetchActions(for: location) {
                List {
                    ForEach(actions) { action in
                        VStack(alignment: .leading) {
                            Text(action.action)
                                .font(.headline)
                            Text(action.desc)
                                .font(.subheadline)
                            // Display equipment and items
                            if !action.equipment.isEmpty {
                                Text("Equipment:")
                                    .font(.subheadline)
                                    .bold()
                                ForEach(action.equipment, id: \.self) { equipment in
                                    Text("- \(equipment)")
                                }
                            }
                            if !action.items.isEmpty {
                                Text("Items:")
                                    .font(.subheadline)
                                    .bold()
                                Text(action.items)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
            } else {
                Text("No actions available for this location")
            }
        }
        .navigationTitle(location)
        .padding()
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
