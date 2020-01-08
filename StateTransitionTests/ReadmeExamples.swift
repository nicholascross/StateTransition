//
//  StateTransitionTests.swift
//  StateTransitionTests
//
//  Created by Nicholas Cross on 7/11/2016.
//  Copyright © 2018 Nicholas Cross. All rights reserved.
//

import XCTest
import Combine
@testable import StateTransition

class ReadmeExampleTests: XCTestCase {
 
    func testExample() {
        enum StateOfMatter: StateTransitionable {
            typealias Action = EnergyTransfer
            typealias Context = String
            
            case Solid
            case Liquid
            case Gas
            case Plasma
            
            static func defineTransitions(_ stateMachine: StateMachine<EnergyTransfer, StateOfMatter, String>.TransitionBuilder) {
                stateMachine.addTransition(fromState: .Solid, toState: .Liquid, when: .Increase)
                stateMachine.addTransition(fromState: .Liquid, toState: .Gas, when: .Increase)
                stateMachine.addTransition(fromState: .Gas, toState: .Plasma, when: .Increase)
                stateMachine.addTransition(fromState: .Plasma, toState: .Gas, when: .Decrease)
                stateMachine.addTransition(fromState: .Gas, toState: .Liquid, when: .Decrease)
                stateMachine.addTransition(fromState: .Liquid, toState: .Solid, when: .Decrease)
            }
        }
        
        enum EnergyTransfer {
            case Increase
            case Decrease
        }

        func transitionHandler(action: EnergyTransfer, fromState: StateOfMatter, toState: StateOfMatter, context: String?)->() {
            print("transitioned from \(fromState) to \(toState) as result of energy \(action) - \(context ?? "no context")")
        }

        let actionSubject = PassthroughSubject<EnergyTransfer, Never>()
        let stateChanges = StateOfMatter.Solid.observe(actions: actionSubject.eraseToAnyPublisher())
        let cancellable = stateChanges.sink(receiveValue: transitionHandler)

        actionSubject.send(.Increase)
        //prints: transitioned from Solid to Liquid as result of energy Increase - no context
        actionSubject.send(.Increase)
        //prints: transitioned from Liquid to Gas as result of energy Increase - no context
//        actionSubject.send(action: .Increase, withContext: "it is very hot")
        //prints: transitioned from Gas to Plasma as result of energy Increase - it is very hot
    }
    
}
