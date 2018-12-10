//
//  StateTransition.swift
//  StateTransition
//
//  Created by Nicholas Cross on 7/11/2016.
//  Copyright © 2018 Nicholas Cross. All rights reserved.
//
import Foundation

public protocol StateTransitionable: Hashable {
    associatedtype Action: Hashable
    associatedtype Context = Any
    
    static func defineTransitions(_ stateMachine: StateMachine<Action, Self, Context>.TransitionBuilder)
}

public extension StateTransitionable {
    func stateMachine() -> StateMachine<Action, Self, Context> {
        let builder = StateMachine<Action, Self, Context>.TransitionBuilder()
        Self.defineTransitions(builder)
        return StateMachine(initialState: self, transitions: builder.transitionsForState)
    }
    
    static func transitionManager() -> StateMachine<Action, Self, Context>.TransitionManager {
        return StateMachine<Action, Self, Context>.TransitionManager()
    }
}

public struct StateMachine<Action:Hashable, State:Hashable, Context> {
    
    public typealias StateTransitionHandler = (Action,State,State,Context?)->()
    public typealias StateTransitions = [Action:State]
    
    private var state: State
    private let transitionsForState: [State:StateTransitions]
    
    public var transitionHandler: StateTransitionHandler? = nil

    init(initialState:State, transitions: [State:StateTransitions]) {
        self.state = initialState
        self.transitionsForState = transitions
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
    
    public class TransitionManager {
        
        private var toStateHandlers: [State: StateTransitionHandler] = [:]
        private var fromStateHandlers: [State: StateTransitionHandler] = [:]
        
        public func handleTransition(toState: State, _ handler: @escaping StateTransitionHandler) {
            toStateHandlers[toState] = handler
        }
        
        public func handleTransition(fromState: State, _ handler: @escaping StateTransitionHandler) {
            fromStateHandlers[fromState] = handler
        }
        
        public func createHandler() -> StateTransitionHandler {
            return handler
        }
        
        private func handler(action: Action, fromState: State, toState: State, context: Context?) -> () {
            if let handler = toStateHandlers[toState] {
                handler(action, fromState, toState, context)
            }
            
            if let handler = fromStateHandlers[fromState] {
                handler(action, fromState, toState, context)
            }
        }
    }
}
