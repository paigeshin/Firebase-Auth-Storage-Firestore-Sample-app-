//
//  FungiFinderApp.swift
//  FungiFinder
//
//  Created by Mohammad Azam on 11/3/20.
//

import SwiftUI
import Firebase

@main
struct FungiFinderApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            LoginView()
                .colorScheme(.light)
        }
    }
}
