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
    func stateMachine() -> StateMachine<Action, Self, Context> {
        let builder = StateMachine<Action, Self, Context>.TransitionBuilder()
        Self.defineTransitions(builder)
        return StateMachine(initialState: self, transitions: builder.transitionsForState)
    }
}

public struct StateMachine<Action:Hashable, State:Hashable, Context> {
    public typealias StateTransition = (Action,State,State,Context?)
    public typealias StateTransitions = [Action:State]
    
    private var state: State
    private let transitionsForState: [State:StateTransitions]

    private let willTransition: PassthroughSubject<StateTransition, Never> = .init()
    private let didTransition: PassthroughSubject<StateTransition, Never> = .init()

    init(initialState:State, transitions: [State:StateTransitions]) {
        self.state = initialState
        self.transitionsForState = transitions
    }
    
    public mutating func perform(action:Action, withContext context: Context? = nil) {
        let oldState = state
        
        if let availableTransitions = transitionsForState[oldState], let s = availableTransitions[action] {
            willTransition.send((action, oldState, s, context))
            state = s
            didTransition.send((action, oldState, s, context))
        }
    }

    public func prepareForTransition() -> AnyPublisher<StateTransition, Never> {
        return self.willTransition.eraseToAnyPublisher()
    }

    public func prepareForTransition(from state: State) -> AnyPublisher<StateTransition, Never> {
        return self.willTransition.filter { state == $0.1 }.eraseToAnyPublisher()
    }

    public func handleTransition() -> AnyPublisher<StateTransition, Never> {
        return self.didTransition.eraseToAnyPublisher()
    }

    public func handleTransition(to state: State) -> AnyPublisher<StateTransition, Never> {
        return self.didTransition.filter { state == $0.2 }.eraseToAnyPublisher()
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
