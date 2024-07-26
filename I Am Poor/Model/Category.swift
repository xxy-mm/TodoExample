//
//  Category.swift
//  I Am Poor
//
//  Created by Darian Mitchell on 2024/7/25.
//

import Foundation
import RealmSwift

class Category: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var name: String
    @Persisted var todos: List<Todo>
    
    convenience init(name: String) {
        self.init()
        self.name = name
    }
}
