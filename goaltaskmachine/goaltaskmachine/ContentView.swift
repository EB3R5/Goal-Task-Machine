import SwiftUI
import RealmSwift

struct ContentView: View {
    @State private var locations: [String] = []
    @State private var data: [ActionOntology] = []
    @State private var selectedLocation: String?
    @State private var showingAddDocumentView = false
    @State private var isLoading = true

    var body: some View {
        NavigationView {
            if isLoading {
                ProgressView("Loading...")
                    .onAppear {
                        RealmManager.shared.login(email: "christianebers1", password: "Lincoln6840!") { result in
                            switch result {
                            case .failure(let error):
                                print("Failed to login: \(error.localizedDescription)")
                            case .success:
                                fetchLocations()
                                isLoading = false
                            }
                        }
                    }
            } else {
                VStack {
                    List(locations, id: \.self) { location in
                        Button(action: {
                            fetchData(for: location)
                        }) {
                            Text(location)
                        }
                    }
                    .navigationTitle("Locations")

                    if let selectedLocation = selectedLocation {
                        List(data, id: \.self) { document in
                            VStack(alignment: .leading) {
                                Text("Location: \(document.location ?? "")")
                                Text("Action: \(document.action ?? "")")
                                Text("Details: \(document.description ?? "")")
                                Text("Timestamp: \(document.time ?? "")")
                            }
                        }
                        .navigationTitle(selectedLocation)
                    }

                    Button(action: { showingAddDocumentView.toggle() }) {
                        Text("Add Document")
                    }
                    .padding()
                    .sheet(isPresented: $showingAddDocumentView) {
                        AddDocumentView()
                    }
                }
            }
        }
    }

    private func fetchLocations() {
        print("Fetching locations")
        RealmManager.shared.fetchUniqueLocations { locations in
            DispatchQueue.main.async {
                print("Fetched locations: \(locations)")
                self.locations = locations
            }
        }
    }

    private func fetchData(for location: String) {
        selectedLocation = location
        print("Fetching data for location: \(location)")
        RealmManager.shared.fetchDataByLocation(location: location) { data in
            DispatchQueue.main.async {
                print("Fetched data for location: \(data)")
                self.data = data
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
