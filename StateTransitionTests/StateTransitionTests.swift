//
//  StateTransitionTests.swift
//  StateTransitionTests
//
//  Created by Nicholas Cross on 7/11/2016.
//  Copyright © 2016 Nicholas Cross. All rights reserved.
//

import XCTest
@testable import StateTransition

enum StateOfMatter {
    case Solid
    case Liquid
    case Gas
    case Plasma
}

enum EnergyTransfer {
    case Increase
    case Decrease
}

class StateTransitionTests: XCTestCase {
    
    var stateMachine : StateMachine<EnergyTransfer, StateOfMatter>!
    
    override func setUp() {
        super.setUp()
        stateMachine = StateMachine<EnergyTransfer, StateOfMatter>(initialState: .Solid)
        
        stateMachine.addTransition(fromState: .Solid, toState: .Liquid, when: .Increase)
        stateMachine.addTransition(fromState: .Liquid, toState: .Gas, when: .Increase)
        stateMachine.addTransition(fromState: .Gas, toState: .Plasma, when: .Increase)
        
        stateMachine.addTransition(fromState: .Plasma, toState: .Gas, when: .Decrease)
        stateMachine.addTransition(fromState: .Gas, toState: .Liquid, when: .Decrease)
        stateMachine.addTransition(fromState: .Liquid, toState: .Solid, when: .Decrease)
    }
    
    func testSingleTransition() {
        stateMachine.perform(action: .Increase)
        XCTAssert(stateMachine.isState(state: .Liquid), "Expected to melt solid to liquid")
    }
    
    func testAllTransitions() {
        stateMachine.perform(action: .Increase)
        stateMachine.perform(action: .Increase)
        stateMachine.perform(action: .Increase)
        XCTAssert(stateMachine.isState(state: .Plasma), "Expected to melt solid to plasma state")
        
        stateMachine.perform(action: .Decrease)
        stateMachine.perform(action: .Decrease)
        stateMachine.perform(action: .Decrease)
        XCTAssert(stateMachine.isState(state: .Solid), "Expected to freeze plasma to solid state")
    }
    
    func testIgnoreInvalidTransitions() {
        stateMachine.perform(action: .Increase)
        stateMachine.perform(action: .Increase)
        stateMachine.perform(action: .Increase)
        stateMachine.perform(action: .Increase)
        stateMachine.perform(action: .Increase)
        stateMachine.perform(action: .Increase)
        XCTAssert(stateMachine.isState(state: .Plasma), "Expected to melt solid to plasma state")
        
        stateMachine.perform(action: .Decrease)
        stateMachine.perform(action: .Decrease)
        stateMachine.perform(action: .Decrease)
        stateMachine.perform(action: .Decrease)
        stateMachine.perform(action: .Decrease)
        XCTAssert(stateMachine.isState(state: .Solid), "Expected to freeze plasma to solid state")
    }
    
    func testTriggerExecution() {
        var isFrozen = false
        var frozenFrom: StateOfMatter!
        var action: EnergyTransfer!
        
        stateMachine.addTrigger(forState: .Solid, trigger: {
            energyTransfer, oldMatterState, currentMatterState, _ in
            isFrozen = true
            frozenFrom = oldMatterState
            action = energyTransfer
        })
        
        stateMachine.perform(action: .Increase)
        stateMachine.perform(action: .Increase)
        stateMachine.perform(action: .Increase)
        stateMachine.perform(action: .Decrease)
        stateMachine.perform(action: .Decrease)
        stateMachine.perform(action: .Decrease)
        
        XCTAssert(isFrozen, "Expected to be frozen")
        XCTAssert(frozenFrom == .Liquid, "Expected to be frozen from liquid state")
        XCTAssert(action == .Decrease, "Expected to be frozen by decreasing energy")
    }
}
