//
//  StateTransitionTests.swift
//  StateTransitionTests
//
//  Created by Nicholas Cross on 7/11/2016.
//  Copyright © 2016 Nicholas Cross. All rights reserved.
//

import XCTest
@testable import StateTransition

class ReadmeExampleTests: XCTestCase {
 
    func testExample() {
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
        
        var stateMachine = StateMachine<EnergyTransfer, StateOfMatter, String>(initialState: .Solid)
        
        stateMachine.addTransition(fromState: .Solid, toState: .Liquid, when: .Increase)
        stateMachine.addTransition(fromState: .Liquid, toState: .Gas, when: .Increase)
        stateMachine.addTransition(fromState: .Gas, toState: .Plasma, when: .Increase)
        stateMachine.addTransition(fromState: .Plasma, toState: .Gas, when: .Decrease)
        stateMachine.addTransition(fromState: .Gas, toState: .Liquid, when: .Decrease)
        stateMachine.addTransition(fromState: .Liquid, toState: .Solid, when: .Decrease)
        
        stateMachine.addHandlerForTransition(toState: .Plasma) {
            action, fromState, toState, context in
            print("transitioned from \(fromState) to \(toState) as result of energy \(action) - \(context ?? "no context")")
        }
        
        stateMachine.perform(action: .Increase)
        stateMachine.perform(action: .Increase)
        stateMachine.perform(action: .Increase, withContext: "it is very hot")
        //prints: transitioned from Gas to Plasma as result of energy Increase - it is very hot    
    }
    
}
