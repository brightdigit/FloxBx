//
//  File.swift
//  
//
//  Created by Leo Dion on 5/12/21.
//

import Fluent

struct CreateUserMigration: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
      return database.schema(User.schema)
            .id()
        .field(User.FieldKeys.email, .string, .required)
        .field(User.FieldKeys.password, .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(User.schema).delete()
    }
}
