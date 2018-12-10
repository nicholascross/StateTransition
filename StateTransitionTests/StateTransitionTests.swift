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
    
    case Solid
    case Liquid
    case Gas
    case Plasma
    
    static func defineTransitions(_ stateMachine: StateMachine<EnergyTransfer, StateOfMatter, Any>.TransitionBuilder) {
        stateMachine.addTransition(fromState: .Solid, toState: .Liquid, when: .Increase)
        stateMachine.addTransition(fromState: .Liquid, toState: .Gas, when: .Increase)
        stateMachine.addTransition(fromState: .Gas, toState: .Plasma, when: .Increase)
        stateMachine.addTransition(fromState: .Plasma, toState: .Gas, when: .Decrease)
        stateMachine.addTransition(fromState: .Gas, toState: .Liquid, when: .Decrease)
        stateMachine.addTransition(fromState: .Liquid, toState: .Solid, when: .Decrease)
    }
}

private enum EnergyTransfer {
    case Increase
    case Decrease
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
        
        stateMachine = StateOfMatter.Solid.stateMachine()
        
        let transitionManager = StateOfMatter.transitionManager()
        transitionManager.handleTransition(toState: .Solid, transitionedToSolid)
        stateMachine.transitionHandler = transitionManager.createHandler()
    }
    
    func testSingleTransition() {
        stateMachine.perform(action: .Increase)
        XCTAssert(stateMachine.currentState == .Liquid, "Expected to melt solid to liquid")
    }
    
    func testAllTransitions() {
        stateMachine.perform(action: .Increase)
        stateMachine.perform(action: .Increase)
        stateMachine.perform(action: .Increase)
        XCTAssert(stateMachine.currentState == .Plasma, "Expected to melt solid to plasma state")
        
        stateMachine.perform(action: .Decrease)
        stateMachine.perform(action: .Decrease)
        stateMachine.perform(action: .Decrease)
        XCTAssert(stateMachine.currentState == .Solid, "Expected to freeze plasma to solid state")
    }
    
    func testIgnoreInvalidTransitions() {
        stateMachine.perform(action: .Increase)
        stateMachine.perform(action: .Increase)
        stateMachine.perform(action: .Increase)
        stateMachine.perform(action: .Increase)
        stateMachine.perform(action: .Increase)
        stateMachine.perform(action: .Increase)
        XCTAssert(stateMachine.currentState == .Plasma, "Expected to melt solid to plasma state")
        
        stateMachine.perform(action: .Decrease)
        stateMachine.perform(action: .Decrease)
        stateMachine.perform(action: .Decrease)
        stateMachine.perform(action: .Decrease)
        stateMachine.perform(action: .Decrease)
        XCTAssert(stateMachine.currentState == .Solid, "Expected to freeze plasma to solid state")
    }
    
    func testTransitionHandlerExecution() {
        stateMachine.perform(action: .Increase)
        stateMachine.perform(action: .Increase)
        stateMachine.perform(action: .Increase)
        stateMachine.perform(action: .Decrease)
        stateMachine.perform(action: .Decrease)
        stateMachine.perform(action: .Decrease, withContext: "It is cold.")
        
        XCTAssert(isFrozen, "Expected to be frozen")
        XCTAssert(frozenFrom == .Liquid, "Expected to be frozen from liquid state")
        XCTAssert(action == .Decrease, "Expected to be frozen by decreasing energy")
    }

}
