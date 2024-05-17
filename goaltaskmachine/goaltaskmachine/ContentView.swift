import SwiftUI
import MongoSwiftSync

struct ContentView: View {
    @State private var locations: [String] = []
    @State private var data: [BSONDocument] = []
    @State private var selectedLocation: String?

    var body: some View {
        NavigationView {
            VStack {
                List(locations, id: \.self) { location in
                    Button(action: {
                        fetchData(for: location)
                    }) {
                        Text(location)
                    }
                }
                .navigationBarTitle("Locations")

                if let selectedLocation = selectedLocation {
                    List(data, id: \.self) { document in
                        VStack(alignment: .leading) {
                            Text(document["location"]?.stringValue ?? "")
                            Text(document["action"]?.stringValue ?? "")
                            Text(document["details"]?.stringValue ?? "")
                            Text(document["timestamp"]?.stringValue ?? "")
                        }
                    }
                    .navigationBarTitle(selectedLocation)
                }

                Button(action: showAddDocumentWindow) {
                    Text("Add Document")
                }
                .padding()
            }
            .onAppear {
                fetchLocations()
            }
        }
    }

    private func fetchLocations() {
        MongoDBManager.shared.fetchUniqueLocations { locations in
            DispatchQueue.main.async {
                self.locations = locations
            }
        }
    }

    private func fetchData(for location: String) {
        selectedLocation = location
        MongoDBManager.shared.fetchDataByLocation(location: location) { data in
            DispatchQueue.main.async {
                self.data = data
            }
        }
    }

    private func showAddDocumentWindow() {
        // Implement your document addition logic here
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
