//
//  Todo.swift
//  I Am Poor
//
//  Created by Darian Mitchell on 2024/7/25.
//

import Foundation
import RealmSwift

class Todo: EmbeddedObject {
    @Persisted var title: String
    @Persisted var done = false
    
    convenience init(title: String) {
        self.init()
        self.title = title
    }
}
