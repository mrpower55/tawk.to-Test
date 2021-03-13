//
//  CoreDataFunctions.swift
//  tawk.to Test
//
//  Created by Mahmoud Shurrab on 13/03/2021.
//

import Foundation
import CoreData

class CoreDataFunctions {
    static let shared = CoreDataFunctions()
    
    private init() {}
    
    public func getAllUsers() -> [UserModel] {
        let managedContext = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<User>(entityName: "User")
        fetchRequest.resultType = .managedObjectResultType

        do {
            let users: [User] = try managedContext.fetch(fetchRequest)
            var cachedUsers: [UserModel] = []
            for user in users {
                cachedUsers.append(UserModel(id: (Int)(user.id), login: user.login, avatarurl: user.avatarurl, name: user.name, company: user.company, blog: user.blog, followers: (Int)(user.followers), following: (Int)(user.following)))
            }
            
            return cachedUsers
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return []
        }
    }
    
    public func getUser(_ id: Int) -> UserModel {
        let managedContext = persistentContainer.viewContext
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", "\(id)")
        
        do {
            let users: [User] = try managedContext.fetch(request)
            
            if let user = users.first {
                return UserModel(id: (Int)(user.id), login: user.login, avatarurl: user.avatarurl, name: user.name, company: user.company, blog: user.blog, followers: (Int)(user.followers), following: (Int)(user.following))
            } else {
                return UserModel(id: 0, login: "", avatarurl: "", name: "", company: "", blog: "", followers: 0, following: 0)
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return UserModel(id: 0, login: "", avatarurl: "", name: "", company: "", blog: "", followers: 0, following: 0)
        }
    }
    
    public func removeAllUsers() {
        let managedContext = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try managedContext.execute(deleteRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    public func saveNewUser(_ userDetails: UserModel) {
        let managedContext = persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "User", in: managedContext)!
        let user = NSManagedObject(entity: entity, insertInto: managedContext)
        
        user.setValue(userDetails.id, forKey: "id")
        user.setValue(userDetails.login, forKey: "login")
        user.setValue(userDetails.avatarurl, forKey: "avatarurl")
        user.setValue(userDetails.blog, forKey: "blog")
        user.setValue(userDetails.company, forKey: "company")
        user.setValue(userDetails.followers, forKey: "followers")
        user.setValue(userDetails.following, forKey: "following")
        user.setValue(userDetails.name, forKey: "name")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    public func updateUser(_ userDetails: UserModel) {
        let managedContext = persistentContainer.viewContext
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", "\(userDetails.id ?? 0)")
        
        do {
            let users: [User] = try managedContext.fetch(request)
            
            if let user = users.first {
                if user.id == userDetails.id ?? 0 {
                    user.id = (Int16)(userDetails.id ?? 0)
                    user.name = userDetails.name
                    user.avatarurl = userDetails.avatarurl
                    user.followers = (Int16)(userDetails.followers ?? 0)
                    user.following = (Int16)(userDetails.following ?? 0)
                    user.login = userDetails.login
                    user.blog = userDetails.blog
                    user.company = userDetails.company
                    
                    try managedContext.save()
                }
                
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    public func isUserNoted(_ id: Int) -> Bool {
        let managedContext = persistentContainer.viewContext
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        request.predicate = NSPredicate(format: "userid == %@", "\(id)")
        
        do {
            let notes: [Note] = try managedContext.fetch(request)
            
            if let note = notes.first {
                return note.userid == id ? true : false
            } else {
                return false
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return false
        }
    }
    
    public func saveUserNote(_ id: Int, _ noteString: String) {
        let managedContext = persistentContainer.viewContext
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        request.predicate = NSPredicate(format: "userid == %@", "\(id)")
        
        do {
            let notes: [Note] = try managedContext.fetch(request)
            
            if let note = notes.first {
                if note.userid == id {
                    note.note = noteString
                    try managedContext.save()
                }
            } else {
                saveNewUserNote(id, noteString)
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    public func saveNewUserNote(_ id: Int, _ noteString: String) {
        let managedContext = persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Note", in: managedContext)!
        let note = NSManagedObject(entity: entity, insertInto: managedContext)
        
        note.setValue(id, forKey: "userid")
        note.setValue(noteString, forKey: "note")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    public func getUserNote(_ id: Int) -> Note {
        let managedContext = persistentContainer.viewContext
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        request.predicate = NSPredicate(format: "userid == %@", "\(id)")
        
        do {
            let notes: [Note] = try managedContext.fetch(request)
            
            if let note = notes.first {
                return note
            } else {
                return Note()
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return Note()
        }
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "tawk_to_Test")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
    
