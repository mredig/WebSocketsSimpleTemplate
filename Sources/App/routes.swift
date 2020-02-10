import Crypto
import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
	// public routes
	let userController = UserController()
	router.post("register", use: userController.create)

	// basic / password auth protected routes
	let basic = router.grouped(User.basicAuthMiddleware(using: BCryptDigest()))
	basic.post("login", use: userController.login)

	// bearer / token auth protected routes
	let bearer = router.grouped(User.tokenAuthMiddleware())
	bearer.get("profile", use: userController.profile)

	// example using another controller
//	let todoController = TodoController()
//	bearer.post("todos", use: todoController.create)
}
