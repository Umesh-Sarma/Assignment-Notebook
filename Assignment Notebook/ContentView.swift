//
//  ContentView.swift
//  Assignment Notebook
//
//  Created by Umesh Sarma on 4/3/24.
//
//Umesh's comment

import SwiftUI

struct Assignment: Identifiable, Codable {
    var id = UUID()
    var course: String
    var description: String
    var dueDate: Date
}


class AssignmentStore: ObservableObject {
    @Published var assignments: [Assignment] {
        didSet {
            saveAssignments()
        }
    }
    
        init() {
        self.assignments = UserDefaults.standard.data(forKey: "assignments")
            .flatMap { try? JSONDecoder().decode([Assignment].self, from: $0) } ?? []
    }
    
    func addAssignment(_ assignment: Assignment) {
    assignments.append(assignment)
        }
    
    func deleteAssignment(at offsets: IndexSet) {
        assignments.remove(atOffsets: offsets)
        }
    
    func moveAssignment(from source: IndexSet, to destination: Int) {
        assignments.move(fromOffsets: source, toOffset: destination)
        }
    
   
func saveAssignments() {
        if let encoded = try? JSONEncoder().encode(assignments) {
            UserDefaults.standard.set(encoded, forKey: "assignments")
        }
    }
}


struct ContentView: View {
    @StateObject private var store = AssignmentStore()
    @State private var showingAddAssignment = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(store.assignments) { assignment in
                    VStack(alignment: .leading) {
                        Text(assignment.course)
                            .font(.headline)
                            .foregroundColor(.blue)
                        Text(assignment.description)
                            .font(.body)
                        Text("Due: \(assignment.dueDate, formatter: DateFormatter.shortDate)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                
                .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
                }
                .onDelete(perform: store.deleteAssignment)
                .onMove(perform: store.moveAssignment)
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitle("Assignments")
            .navigationBarItems(leading: EditButton(), trailing: Button(action: {
                showingAddAssignment = true
            }) {
                
                Image(systemName: "plus")
            })
            
            .sheet(isPresented: $showingAddAssignment) {
                AddAssignmentView(store: store)
                
            }
            
        }
    }
}

struct AddAssignmentView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var store: AssignmentStore
    @State private var course = ""
    @State private var description = ""
    @State private var dueDate = Date()
    
    
    
    
    var body: some View {
        NavigationView {
            
            Form {
                Section(header: Text("Assignment Details")) {
                    TextField("Course", text: $course)
                    TextField("Description", text: $description)
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                }
            }
            .navigationBarTitle("New Assignment")
            .navigationBarItems(trailing: Button("Save") {
                let newAssignment = Assignment(course: course, description: description, dueDate: dueDate)
                store.addAssignment(newAssignment)
                presentationMode.wrappedValue.dismiss()
            })
        }
        
    }
}


    extension DateFormatter {
        static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
        }  ()
}

    struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
