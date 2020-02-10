import Authentication
import FluentSQLite
import Vapor

/// A registered user, capable of owning todo items.
final class User: SQLiteModel {
	/// User's unique identifier.
	/// Can be `nil` if the user has not been saved yet.
	var id: Int?
	var username: String
	var passwordHash: String
	
	/// Creates a new `User`.
	init(id: Int? = nil, username: String, passwordHash: String) {
		self.id = id
		self.passwordHash = passwordHash
		self.username = username
	}
}

/// Allows users to be verified by basic / password auth middleware.
extension User: PasswordAuthenticatable {
	/// See `PasswordAuthenticatable`.
	static var usernameKey: WritableKeyPath<User, String> {
		return \.username
	}
	
	/// See `PasswordAuthenticatable`.
	static var passwordKey: WritableKeyPath<User, String> {
		return \.passwordHash
	}
}

/// Allows users to be verified by bearer / token auth middleware.
extension User: TokenAuthenticatable {
	/// See `TokenAuthenticatable`.
	typealias TokenType = UserToken
}

/// Allows `User` to be used as a Fluent migration.
extension User: Migration {
	/// See `Migration`.
	static func prepare(on conn: SQLiteConnection) -> Future<Void> {
		return SQLiteDatabase.create(User.self, on: conn) { builder in
			builder.field(for: \.id, isIdentifier: true)
			builder.field(for: \.username)
			builder.field(for: \.passwordHash)
			builder.unique(on: \.username)
		}
	}
}

/// Allows `User` to be encoded to and decoded from HTTP messages.
extension User: Content { }

/// Allows `User` to be used as a dynamic parameter in route definitions.
extension User: Parameter { }
