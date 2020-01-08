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

private enum StateOfMatter: StateTransitionable {
    typealias Action = EnergyTransfer
    
    case solid
    case liquid
    case gas
    case plasma
    
    static func defineTransitions(_ stateMachine: StateMachine<EnergyTransfer, StateOfMatter, String>.TransitionBuilder) {
        stateMachine.addTransition(fromState: .solid, toState: .liquid, when: .increase)
        stateMachine.addTransition(fromState: .liquid, toState: .gas, when: .increase)
        stateMachine.addTransition(fromState: .gas, toState: .plasma, when: .increase)
        stateMachine.addTransition(fromState: .plasma, toState: .gas, when: .decrease)
        stateMachine.addTransition(fromState: .gas, toState: .liquid, when: .decrease)
        stateMachine.addTransition(fromState: .liquid, toState: .solid, when: .decrease)
    }
}

private enum EnergyTransfer {
    case increase
    case decrease
}

class StateTransitionTests: XCTestCase {
    private var stateChanged: XCTestExpectation!
    private var currentState: StateOfMatter!
    private var action: EnergyTransfer!
    private var context: String? = nil
    private var cancellable: AnyCancellable!
    private var actionSubject: PassthroughSubject<EnergyTransfer, Never>!

    override func setUp() {
        super.setUp()
        stateChanged = XCTestExpectation()
        actionSubject = PassthroughSubject<EnergyTransfer, Never>()
        cancellable = StateOfMatter.solid.observe(actions: actionSubject.eraseToAnyPublisher()).sink(receiveValue: transitioned)
    }
    
    func testSingleTransition() {
        actionSubject.send(.increase)
        wait(for: [stateChanged], timeout: 0.2)
        XCTAssert(currentState == .liquid, "Expected to melt solid to liquid")
    }
    
    func testAllTransitions() {
        actionSubject.send(.increase)
        actionSubject.send(.increase)
        actionSubject.send(.increase)
        XCTAssert(currentState == .plasma, "Expected to melt solid to plasma state")
        
        actionSubject.send(.decrease)
        actionSubject.send(.decrease)
        actionSubject.send(.decrease)
        XCTAssert(currentState == .solid, "Expected to freeze plasma to solid state")
    }
    
    func testIgnoreInvalidTransitions() {
        actionSubject.send(.increase)
        actionSubject.send(.increase)
        actionSubject.send(.increase)
        actionSubject.send(.increase)
        actionSubject.send(.increase)
        actionSubject.send(.increase)
        wait(for: [stateChanged], timeout: 0.2)
        XCTAssert(currentState == .plasma, "Expected to melt solid to plasma state")

        stateChanged = XCTestExpectation()
        actionSubject.send(.decrease)
        actionSubject.send(.decrease)
        actionSubject.send(.decrease)
        actionSubject.send(.decrease)
        actionSubject.send(.decrease)
        wait(for: [stateChanged], timeout: 0.2)
        XCTAssert(currentState == .solid, "Expected to freeze plasma to solid state")
    }

    func testObservationWithContext() {
        let actionInContextSubject = PassthroughSubject<(EnergyTransfer, String?), Never>()
        cancellable = StateOfMatter.solid.observe(actionsInContext: actionInContextSubject.eraseToAnyPublisher()).sink(receiveValue: transitioned)

        actionInContextSubject.send((.increase, nil))
        actionInContextSubject.send((.increase, nil))
        actionInContextSubject.send((.increase, nil))
        actionInContextSubject.send((.decrease, nil))
        actionInContextSubject.send((.decrease, nil))
        actionInContextSubject.send((.decrease, "Its cold"))

        wait(for: [stateChanged], timeout: 0.2)
        XCTAssert(currentState == .solid, "Expected to be frozen from liquid state")
        XCTAssert(action == .decrease, "Expected to be frozen by decreasing energy")
        XCTAssertEqual(self.context, "Its cold")
    }

    fileprivate func transitioned(energyTransfer: EnergyTransfer, fromState: StateOfMatter, toState: StateOfMatter, context:String?) {
        self.currentState = toState
        self.action = energyTransfer
        self.context = context
        self.stateChanged.fulfill()
    }
}
