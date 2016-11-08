//
//  StateTransition.swift
//  StateTransition
//
//  Created by Nicholas Cross on 7/11/2016.
//  Copyright © 2016 Nicholas Cross. All rights reserved.
//
import Foundation

public struct StateMachine<Action:Hashable,State:Hashable, Context> {
    
    public typealias StateTransitionHandler = (Action,State,State,Context?)->()
    public typealias StateTransitions = [Action:State]
    
    private var stateTransitionsForState: [State:StateTransitions]
    
    private var state: State
    
    private var transitionHandlers: [State:[StateTransitionHandler]]
    
    public init(initialState:State) {
        self.state = initialState
        self.stateTransitionsForState = [State : StateTransitions]()
        self.transitionHandlers = [State : [StateTransitionHandler]]()
    }
    
    public mutating func addTransition(fromState:State, toState:State, when action:Action) {
        if var availableTransitions = self.stateTransitionsForState[fromState] {
            availableTransitions[action] = toState
            stateTransitionsForState[fromState] = availableTransitions
        }
        else {
            var availableTransitions = StateTransitions()
            availableTransitions[action] = toState
            stateTransitionsForState[fromState] = availableTransitions
        }
    }
    
    public mutating func removeTransition(fromState:State, when action:Action) {
        if var availableTransitions = self.stateTransitionsForState[fromState] {
            availableTransitions[action] = nil
            stateTransitionsForState[fromState] = availableTransitions
        }
    }
    
    public mutating func addHandlerForTransition(toState state:State, handler:@escaping StateTransitionHandler) {
        if var handlersForState = self.transitionHandlers[state] {
            handlersForState.append( handler )
            self.transitionHandlers[state] = handlersForState
        }
        else {
            var handlersForState = [StateTransitionHandler]()
            handlersForState.append( handler )
            self.transitionHandlers[state] = handlersForState
        }
    }
    
    public mutating func removeAllHandlersForTransition(toState state:State) {
        self.transitionHandlers[state] = nil
    }
    
    public mutating func perform(action:Action, withContext context: Context? = nil) {
        let oldState = state
        
        if let availableTransitions = stateTransitionsForState[oldState], let s = availableTransitions[action] {
            state = s
                    
            if let stateTriggers = self.transitionHandlers[s] {
                for trigger in stateTriggers {
                    trigger(action, oldState, s, context)
                }
            }
        }
    }
    
    public var currentState: State {
        return state
    }
}
