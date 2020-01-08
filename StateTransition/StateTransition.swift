//
//  StateTransition.swift
//  StateTransition
//
//  Created by Nicholas Cross on 7/11/2016.
//  Copyright © 2018 Nicholas Cross. All rights reserved.
//
import Foundation
import Combine

public protocol StateTransitionable: Hashable {
    associatedtype Action: Hashable
    associatedtype Context = Any
    
    static func defineTransitions(_ stateMachine: StateMachine<Action, Self, Context>.TransitionBuilder)
}

public extension StateTransitionable {
    private func stateMachine() -> StateMachine<Action, Self, Context> {
        let builder = StateMachine<Action, Self, Context>.TransitionBuilder()
        Self.defineTransitions(builder)
        return StateMachine(initialState: self, transitions: builder.transitionsForState)
    }

    func observe(actions: AnyPublisher<Action, Never>) -> AnyPublisher<(Action,Self,Self,Context?), Never> {
        return observe(actionsInContext: actions.map { ($0, nil as Context?) }.eraseToAnyPublisher())
    }

    func observe(actionsInContext actions: AnyPublisher<(Action, Context?), Never>) -> AnyPublisher<(Action,Self,Self,Context?), Never> {
        var stateMachine: StateMachine = self.stateMachine()

        // Even though stateMachine is a value type when the value
        // is mutated it is changed in place which means it is possible to
        // mutate the value in an escaping closure; this seems to be
        // completely valid but is not necessarily expected (by myself)
        return actions.compactMap { stateMachine.perform(action: $0.0, withContext: $0.1) }.eraseToAnyPublisher()
    }

}

public struct StateMachine<Action:Hashable, State:Hashable, Context> {
    public typealias StateTransition = (Action,State,State,Context?)
    public typealias StateTransitions = [Action:State]
    
    private var state: State
    private let transitionsForState: [State:StateTransitions]

    private let didTransition: PassthroughSubject<StateTransition, Never> = .init()

    init(initialState:State, transitions: [State:StateTransitions]) {
        self.state = initialState
        self.transitionsForState = transitions
    }

    mutating func perform(action:Action, withContext context: Context? = nil) -> StateTransition? {
        let oldState = state
        
        if let availableTransitions = transitionsForState[oldState], let s = availableTransitions[action] {
            state = s
            return (action, oldState, s, context)
        }

        return nil
    }

    func handleTransition() -> AnyPublisher<StateTransition, Never> {
        return self.didTransition.eraseToAnyPublisher()
    }

    var currentState: State {
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
}
