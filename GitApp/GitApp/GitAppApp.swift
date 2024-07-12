//
//  GitAppApp.swift
//  GitApp
//
//  Created by Suraj Kumar on 11/07/24.
//

import SwiftUI

@main
struct GitAppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            HomeView(context: persistenceController.container.viewContext)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
