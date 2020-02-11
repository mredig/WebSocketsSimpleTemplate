import Crypto
import Vapor
import FluentSQLite

/// Creates new users and logs them in.
final class UserController {
	/// Logs a user in, returning a token for accessing protected endpoints.
	func login(_ req: Request) throws -> Future<UserToken> {
		return try req.content.decode(User.self).flatMap { decodedUser -> Future<UserToken> in
			User.query(on: req)
				.filter(\.username == decodedUser.username)
				.first().flatMap { fetchedUser in
					guard let existingUser = fetchedUser else {
						throw Abort(HTTPStatus.notFound)
					}
					let hasher = try req.make(BCryptDigest.self)
					if try hasher.verify(decodedUser.password, created: existingUser.password) {
						let token = try UserToken.create(userID: existingUser.requireID())
						return token.save(on: req)
					} else {
						throw Abort(HTTPStatus.unauthorized)
					}
			}
		}
	}

	/// Creates a new user.
	func create(_ req: Request) throws -> Future<UserResponse> {
		// decode request content
		return try req.content.decode(CreateUserRequest.self).flatMap { user -> Future<User> in
			// verify that passwords match (add strength check later)
			guard user.password == user.passwordVerify else {
				throw Abort(.badRequest, reason: "Password and verification must match.")
			}
			guard user.password.count > 3 else {
				throw Abort(.badRequest, reason: "Password must contain more characters.")
			}

			// hash user's password using BCrypt
			let hash = try BCrypt.hash(user.password)
			// save new user
			return User(id: nil, username: user.username, passwordHash: hash)
				.save(on: req)
		}.map { user in
			// map to public user response (omits password hash)
			return try UserResponse(id: user.requireID(), username: user.username)
		}
	}

	func profile(_ req: Request) throws -> UserResponse {
		// confirms token auth
		let user = try req.requireAuthenticated(User.self)

		// returns a user response
		return try UserResponse(id: user.requireID(), username: user.username)
	}
}

// MARK: Content

/// Data required to create a user.
struct CreateUserRequest: Content {
	let username: String
	let password: String
	let passwordVerify: String
}

/// Public representation of user data.
struct UserResponse: Content {
	/// User's unique identifier.
	/// Not optional since we only return users that exist in the DB.
	var id: Int
	var username: String
}
