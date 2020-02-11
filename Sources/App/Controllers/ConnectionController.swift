//
//  ConnectionController.swift
//  App
//
//  Created by Michael Redig on 2/10/20.
//

import Foundation
import Vapor

public class ConnectionController {
	public var connections = [String: WebSocket]()
}
