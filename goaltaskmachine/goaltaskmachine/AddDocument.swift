import SwiftUI
import RealmSwift

struct AddDocumentView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var location = ""
    @State private var action = ""
    @State private var description = ""
    @State private var timestamp = Date()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Details")) {
                    TextField("Location", text: $location)
                    TextField("Action", text: $action)
                    TextField("Details", text: $description)
                    DatePicker("Timestamp", selection: $timestamp, displayedComponents: .date)
                }
            }
            .navigationTitle("Add Action")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let newAction = ActionOntology()
                        newAction.location = location
                        newAction.action = action
                        newAction.desc = description
                        newAction.time = "\(timestamp)"

                        RealmManager.shared.addDocument(data: newAction)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct AddDocumentView_Previews: PreviewProvider {
    static var previews: some View {
        AddDocumentView()
    }
}
