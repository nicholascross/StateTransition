//
//  StateTransition.swift
//  StateTransition
//
//  Created by Nicholas Cross on 7/11/2016.
//  Copyright © 2016 Nicholas Cross. All rights reserved.
//
import Foundation

public protocol StateTransitionable: Hashable {
    associatedtype Action: Hashable
    associatedtype Context = Any
}

public extension StateTransitionable {
    
    func createStateMachine(_ buildTransitions: (StateMachine<Action, Self, Context>.TransitionBuilder)->Void) -> StateMachine<Action, Self, Context> {
        let builder = StateMachine<Action, Self, Context>.TransitionBuilder()
        buildTransitions(builder)
        return StateMachine(initialState: self, transitions: builder.transitionsForState, handler: builder.handler)
    }
}

public struct StateMachine<Action:Hashable, State:Hashable, Context> {
    
    public typealias StateTransitionHandler = (Action,State,State,Context?)->()
    public typealias StateTransitions = [Action:State]
    
    private var state: State
    
    private let transitionsForState: [State:StateTransitions]
    private let transitionHandler: StateTransitionHandler?

    init(initialState:State, transitions: [State:StateTransitions], handler: StateTransitionHandler?) {
        self.state = initialState
        self.transitionsForState = transitions
        self.transitionHandler = handler
    }
    
    public mutating func perform(action:Action, withContext context: Context? = nil) {
        let oldState = state
        
        if let availableTransitions = transitionsForState[oldState], let s = availableTransitions[action] {
            state = s
            transitionHandler?(action, oldState, s, context)
        }
    }
    
    public var currentState: State {
        return state
    }
    
    public class TransitionBuilder {
        var transitionsForState: [State:StateTransitions] = [:]
        
        public var handler: StateTransitionHandler? = nil
        
        public func addTransition(fromState:State, toState:State, when action:Action) {
            if var availableTransitions = self.transitionsForState[fromState] {
                availableTransitions[action] = toState
                transitionsForState[fromState] = availableTransitions
            }
            else {
                var availableTransitions = StateTransitions()
                availableTransitions[action] = toState
                transitionsForState[fromState] = availableTransitions
            }
        }
    }
}
