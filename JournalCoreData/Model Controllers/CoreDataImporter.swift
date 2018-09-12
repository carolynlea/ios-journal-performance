//
//  CoreDataImporter.swift
//  JournalCoreData
//
//  Created by Andrew R Madsen on 9/10/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataImporter {
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func sync(entries: [EntryRepresentation], completion: @escaping (Error?) -> Void = { _ in }) {
        
        print("begin syncing")
        
        let localEntries = getEntriesFromLocalStore(entries: entries, context: self.context)
        
        self.context.perform {
            
            for entryRep in entries {
                guard let identifier = entryRep.identifier else { continue }
                
                let entry = localEntries[identifier]
                if let entry = entry, entry != entryRep {
                    self.update(entry: entry, with: entryRep)
                } else if entry == nil {
                    _ = Entry(entryRepresentation: entryRep, context: self.context)
                }
            }
            
            completion(nil)
        }
        print("finished syncing")
    }
    
    private func getEntriesFromLocalStore(entries: [EntryRepresentation], context: NSManagedObjectContext) -> [String : Entry]
    {
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        let identifiers: [String] = entries.compactMap { $0.identifier }
        
        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiers)
        
        var result: [String : Entry] = [:]
        
        do
        {
            let fetchedEntries = try context.fetch(fetchRequest)
            
            for entry in fetchedEntries
            {
                result[entry.identifier!] = entry
            }
        }
        catch
        {
            NSLog("Error fetching entries: \(error)")
        }
        
        return result
    }
    
    private func update(entry: Entry, with entryRep: EntryRepresentation) {
        entry.title = entryRep.title
        entry.bodyText = entryRep.bodyText
        entry.mood = entryRep.mood
        entry.timestamp = entryRep.timestamp
        entry.identifier = entryRep.identifier
    }
    

    
    let context: NSManagedObjectContext
    
}
