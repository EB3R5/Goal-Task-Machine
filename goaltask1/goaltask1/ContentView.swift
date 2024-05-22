import SwiftUI
import RealmSwift
import Lottie

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
        NavigationStack {
            VStack {
                if isLoggedIn {
                    TabView {
                        LocationsView(realmManager: realmManager)
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

    var body: some View {
        VStack {
            if let locations = realmManager.fetchLocations() {
                let sortedLocations = locations.sorted() // Sort locations alphabetically
                List(sortedLocations, id: \.self) { location in
                    NavigationLink(
                        destination: ActionsView(realmManager: realmManager, location: location)
                    ) {
                        Text(location)
                    }
                }
            } else {
                Text("No data available")
            }
        }
        .navigationTitle("Locations")
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
    @State private var showConfetti = false // State variable to control confetti animation

    var body: some View {
        VStack {
            if let actionsResults = realmManager.fetchActions(for: location) {
                let actions = Array(actionsResults)
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
                                    .onChange(of: checklist[equipment] ?? false) { _ in
                                        checkAllItems(actions: actions)
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
                                .onChange(of: checklist[action.items] ?? false) { _ in
                                    checkAllItems(actions: actions)
                                }
                            }
                        }
                    }
                }
            } else {
                Text("No actions available for this location")
            }

            // Confetti animation view
            if showConfetti {
                LottieView(name: "confetti", loopMode: .playOnce)
                    .frame(width: 400, height: 400)
                    .background(Color.clear)
                    .onAppear {
                        print("Confetti animation is shown")
                    }
            }
        }
        .navigationTitle(location)
        .padding()
    }

    // Function to check if all items are checked
    func checkAllItems(actions: [ActionOntology]) {
        let allChecked = actions.allSatisfy { action in
            (action.equipment.allSatisfy { checklist[$0] ?? false }) &&
            (checklist[action.items] ?? false)
        }

        if allChecked {
            print("All items are checked!")
            showConfetti = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                showConfetti = false
            }
        }
    }
}

// LottieView for SwiftUI
struct LottieView: UIViewRepresentable {
    var name: String
    var loopMode: LottieLoopMode

    func makeUIView(context: Context) -> UIView {
        let animationView = LottieAnimationView()
        let animation = LottieAnimation.named(name)
        animationView.animation = animation
        animationView.loopMode = loopMode
        animationView.play()
        return animationView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // No update needed
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
