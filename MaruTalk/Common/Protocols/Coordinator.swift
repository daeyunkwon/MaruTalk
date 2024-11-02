//
//  Coordinator.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/1/24.
//

import UIKit

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }
    var parentCoordinator: Coordinator? { get set }
    
    func start()
}

extension Coordinator {
    func removeCoordinator(child: Coordinator?) {
        childCoordinators.removeAll { $0 === child }
    }
}
