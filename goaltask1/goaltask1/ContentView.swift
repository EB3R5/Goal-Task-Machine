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
                    TabView {
                        LocationsView(realmManager: realmManager, selectedLocation: $selectedLocation)
                            .tabItem {
                                Label("Locations", systemImage: "location")
                            }
                        ConditionsView(realmManager: realmManager)
                            .tabItem {
                                Label("Conditions", systemImage: "text.badge.checkmark")
                            }
                        DoneView(realmManager: realmManager)
                            .tabItem {
                                Label("Done", systemImage: "checkmark.circle")
                            }
                        ToDoView(realmManager: realmManager)
                            .tabItem {
                                Label("To Do", systemImage: "list.bullet")
                            }
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
                print("LandingPageView appeared, attempting to log in...")
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

struct LocationsView: View {
    @ObservedObject var realmManager: RealmManager
    @Binding var selectedLocation: String?

    var body: some View {
        VStack {
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
        }
    }
}

struct ConditionsView: View {
    @ObservedObject var realmManager: RealmManager

    var body: some View {
        VStack {
            if let actions = realmManager.fetchActions() {
                List {
                    ForEach(actions) { action in
                        if !action.condition.isEmpty {
                            Section(header: Text(action.action).font(.headline)) {
                                Text(action.desc).font(.subheadline)
                                Text("Condition: \(action.condition)").font(.subheadline)
                                if !action.equipment.isEmpty {
                                    Text("Equipment:").bold()
                                    ForEach(action.equipment, id: \.self) { equipment in
                                        Text(equipment)
                                    }
                                }
                                if !action.items.isEmpty {
                                    Text("Items:").bold()
                                    Text(action.items)
                                }
                            }
                        }
                    }
                }
            } else {
                Text("No actions available")
            }
        }
        .padding()
    }
}

struct DoneView: View {
    @ObservedObject var realmManager: RealmManager
    @State private var checklist = [String: Bool]() // To track the state of each checklist item

    var body: some View {
        VStack {
            if let actions = realmManager.fetchActions() {
                List {
                    ForEach(actions) { action in
                        Section(header: Text(action.action).font(.headline)) {
                            Text(action.desc).font(.subheadline)
                            if !action.equipment.isEmpty {
                                Text("Equipment:").bold()
                                ForEach(action.equipment, id: \.self) { equipment in
                                    Toggle(isOn: Binding(
                                        get: { checklist[equipment] ?? false },
                                        set: { checklist[equipment] = $0 }
                                    )) {
                                        Text(equipment)
                                    }
                                }
                            }
                            if !action.items.isEmpty {
                                Text("Items:").bold()
                                Toggle(isOn: Binding(
                                    get: { checklist[action.items] ?? false },
                                    set: { checklist[action.items] = $0 }
                                )) {
                                    Text(action.items)
                                }
                            }
                        }
                    }
                }
            } else {
                Text("No actions available")
            }
        }
        .padding()
    }
}

struct ToDoView: View {
    @ObservedObject var realmManager: RealmManager

    var body: some View {
        VStack {
            if let actions = realmManager.fetchActions() {
                List {
                    ForEach(actions) { action in
                        Section(header: Text(action.action).font(.headline)) {
                            Text(action.desc).font(.subheadline)
                            if !action.equipment.isEmpty {
                                Text("Equipment:").bold()
                                ForEach(action.equipment, id: \.self) { equipment in
                                    Text(equipment)
                                }
                            }
                            if !action.items.isEmpty {
                                Text("Items:").bold()
                                Text(action.items)
                            }
                        }
                    }
                }
            } else {
                Text("No actions available")
            }
        }
        .padding()
    }
}

struct ActionsView: View {
    @ObservedObject var realmManager: RealmManager
    var location: String

    @State private var checklist = [String: Bool]() // To track the state of each checklist item

    var body: some View {
        VStack {
            if let actions = realmManager.fetchActions(for: location) {
                List {
                    ForEach(actions) { action in
                        Section(header: Text(action.action).font(.headline)) {
                            Text(action.desc).font(.subheadline)
                            // Display equipment as checklist items
                            if !action.equipment.isEmpty {
                                Text("Equipment:")
                                    .font(.subheadline)
                                    .bold()
                                ForEach(action.equipment, id: \.self) { equipment in
                                    Toggle(isOn: Binding(
                                        get: { checklist[equipment] ?? false },
                                        set: { checklist[equipment] = $0 }
                                    )) {
                                        Text(equipment)
                                    }
                                }
                            }
                            // Display items as checklist items
                            if !action.items.isEmpty {
                                Text("Items:")
                                    .font(.subheadline)
                                    .bold()
                                Toggle(isOn: Binding(
                                    get: { checklist[action.items] ?? false },
                                    set: { checklist[action.items] = $0 }
                                )) {
                                    Text(action.items)
                                }
                            }
                        }
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
