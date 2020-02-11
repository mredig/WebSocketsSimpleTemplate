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


public func wsRoutes(_ router: NIOWebSocketServer, connectionController: ConnectionController) throws {

	router.get("echo", String.parameter) { ws, req in
		let id = try req.parameters.next(String.self)
		connectionController.connections[id]?.close()
		connectionController.connections[id] = ws
		print("connected: \(id)")

		ws.onText { ws, text in
			print("\(id): \(text)")

			for (key, conn) in connectionController.connections {
				conn.send("\(id): \(text)")
			}
		}

		ws.onClose.always {
			connectionController.connections[id] = nil
			print("disconnected \(id)")
		}

		ws.onCloseCode { closeCode in
			print("disconnected (\(id)) with code: \(closeCode)")
		}

		ws.onError { ws, error in
			print("error: ", ws, error)
		}

		ws.onBinary { ws, data in
			print("binary: ", ws, data)
		}
	}

}
