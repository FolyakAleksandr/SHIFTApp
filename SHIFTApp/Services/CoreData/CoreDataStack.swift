import CoreData

final class CoreDataStack {
    static let shared = CoreDataStack()

    let persistentContainer: NSPersistentContainer
    var backgroundContext: NSManagedObjectContext {
        persistentContainer.newBackgroundContext()
    }

    private init() {
        persistentContainer = NSPersistentContainer(name: "SHIFTApp")
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("❌ Failed to load store: \(error)")
            }
        }
    }
}
