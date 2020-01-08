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
    
    static func defineTransitions(_ stateMachine: StateMachine<Action, Self>.TransitionBuilder)
}

public extension StateTransitionable {
    func stateMachine() -> StateMachine<Action, Self> {
        let builder = StateMachine<Action, Self>.TransitionBuilder()
        Self.defineTransitions(builder)
        return StateMachine(initialState: self, transitions: builder.transitionsForState)
    }

    func publishStateChanges(when actions: AnyPublisher<Action, Never>) -> AnyPublisher<StateMachine<Action, Self>.StateTransition, Never> {
        var stateMachine: StateMachine = self.stateMachine()

        // Even though stateMachine is a value type when the value
        // is mutated it is changed in place which means it is possible to
        // mutate the value in an escaping closure; this seems to be
        // completely valid but is not necessarily expected (by myself)
        return actions.compactMap { stateMachine.perform(action: $0) }.eraseToAnyPublisher()
    }
}

public struct StateMachine<Action:Hashable, State:Hashable> {
    public typealias StateTransition = (Action,State,State)
    public typealias StateTransitions = [Action:State]
    
    private var state: State
    private let transitionsForState: [State:StateTransitions]

    private let didTransition: PassthroughSubject<StateTransition, Never> = .init()

    init(initialState:State, transitions: [State:StateTransitions]) {
        self.state = initialState
        self.transitionsForState = transitions
    }

    @discardableResult public mutating func perform(action:Action) -> StateTransition? {
        let oldState = state
        
        if let availableTransitions = transitionsForState[oldState], let s = availableTransitions[action] {
            state = s
            return (action, oldState, s)
        }

        return nil
    }

    func handleTransition() -> AnyPublisher<StateTransition, Never> {
        return self.didTransition.eraseToAnyPublisher()
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
}
