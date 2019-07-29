//
//  StateTransitionTests.swift
//  StateTransitionTests
//
//  Created by Nicholas Cross on 7/11/2016.
//  Copyright © 2018 Nicholas Cross. All rights reserved.
//

import XCTest
@testable import StateTransition

private enum StateOfMatter: StateTransitionable {
    typealias Action = EnergyTransfer
    
    case solid
    case liquid
    case gas
    case plasma
    
    static func defineTransitions(_ stateMachine: StateMachine<EnergyTransfer, StateOfMatter, Any>.TransitionBuilder) {
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
    
    private var stateMachine : StateMachine<EnergyTransfer, StateOfMatter, Any>!
    
    private var isFrozen = false
    private var frozenFrom: StateOfMatter!
    private var action: EnergyTransfer!
    
    override func setUp() {
        super.setUp()
        
        func transitionedToSolid(energyTransfer: EnergyTransfer, fromState: StateOfMatter, toState: StateOfMatter, context:Any) {
            isFrozen = true
            frozenFrom = fromState
            action = energyTransfer
        }
        
        stateMachine = StateOfMatter.solid.stateMachine()

        _ = stateMachine.handleTransition(to: .solid).sink(receiveValue: transitionedToSolid)
    }
    
    func testSingleTransition() {
        stateMachine.perform(action: .increase)
        XCTAssert(stateMachine.currentState == .liquid, "Expected to melt solid to liquid")
    }
    
    func testAllTransitions() {
        stateMachine.perform(action: .increase)
        stateMachine.perform(action: .increase)
        stateMachine.perform(action: .increase)
        XCTAssert(stateMachine.currentState == .plasma, "Expected to melt solid to plasma state")
        
        stateMachine.perform(action: .decrease)
        stateMachine.perform(action: .decrease)
        stateMachine.perform(action: .decrease)
        XCTAssert(stateMachine.currentState == .solid, "Expected to freeze plasma to solid state")
    }
    
    func testIgnoreInvalidTransitions() {
        stateMachine.perform(action: .increase)
        stateMachine.perform(action: .increase)
        stateMachine.perform(action: .increase)
        stateMachine.perform(action: .increase)
        stateMachine.perform(action: .increase)
        stateMachine.perform(action: .increase)
        XCTAssert(stateMachine.currentState == .plasma, "Expected to melt solid to plasma state")
        
        stateMachine.perform(action: .decrease)
        stateMachine.perform(action: .decrease)
        stateMachine.perform(action: .decrease)
        stateMachine.perform(action: .decrease)
        stateMachine.perform(action: .decrease)
        XCTAssert(stateMachine.currentState == .solid, "Expected to freeze plasma to solid state")
    }
    
    func testTransitionHandlerExecution() {
        stateMachine.perform(action: .increase)
        stateMachine.perform(action: .increase)
        stateMachine.perform(action: .increase)
        stateMachine.perform(action: .decrease)
        stateMachine.perform(action: .decrease)
        stateMachine.perform(action: .decrease, withContext: "It is cold.")
        
        XCTAssert(isFrozen, "Expected to be frozen")
        XCTAssert(frozenFrom == .liquid, "Expected to be frozen from liquid state")
        XCTAssert(action == .decrease, "Expected to be frozen by decreasing energy")
    }

}
