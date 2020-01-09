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

    enum StateOfMatter: StateTransitionable {
        typealias Action = EnergyTransfer
        typealias Context = String

        case solid
        case liquid
        case gas
        case plasma

        static func defineTransitions(_ stateMachine: StateMachine<EnergyTransfer, StateOfMatter>.TransitionBuilder) {
            stateMachine.addTransition(fromState: .solid, toState: .liquid, when: .increase)
            stateMachine.addTransition(fromState: .liquid, toState: .gas, when: .increase)
            stateMachine.addTransition(fromState: .gas, toState: .plasma, when: .increase)
            stateMachine.addTransition(fromState: .plasma, toState: .gas, when: .decrease)
            stateMachine.addTransition(fromState: .gas, toState: .liquid, when: .decrease)
            stateMachine.addTransition(fromState: .liquid, toState: .solid, when: .decrease)
        }
    }

    enum EnergyTransfer {
        case increase
        case decrease
    }

    func testExample() {
        var stateMachine = StateOfMatter.solid.stateMachine()

        guard let transition = stateMachine.perform(action: .increase) else {
            return
        }
        print("transitioned from \(transition.1) to \(transition.2) as result of energy \(transition.0)")
        //prints: transitioned from solid to liquid as result of energy increase

        stateMachine.perform(action: .increase)
        print("current state is \(stateMachine.currentState)")
        //prints: current state is gas
    }

    func testExampleCombine() {
        func transitionHandler(action: EnergyTransfer, fromState: StateOfMatter, toState: StateOfMatter)->() {
            print("transitioned from \(fromState) to \(toState) as result of energy \(action)")
        }

        let energyTransfer = PassthroughSubject<EnergyTransfer, Never>()
        let stateChanges = StateOfMatter.solid.publishStateChanges(when: energyTransfer.eraseToAnyPublisher())
        let cancellable = stateChanges.sink(receiveValue: transitionHandler)

        energyTransfer.send(.increase)
        //prints: transitioned from solid to liquid as result of energy increase

        energyTransfer.send(.increase)
        //prints: transitioned from liquid to gas as result of energy increase
    }
    
}
