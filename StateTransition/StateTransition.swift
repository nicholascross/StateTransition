//
//  StateTransition.swift
//  StateTransition
//
//  Created by Nicholas Cross on 7/11/2016.
//  Copyright © 2016 Nicholas Cross. All rights reserved.
//
import Foundation

public struct StateMachine<Action:Hashable,State:Hashable, Context> {
    
    public typealias StateTrigger = (Action,State,State,Context?)->()
    public typealias StateTransitions = [Action:State]
    
    private var stateTransitionsForState: [State:StateTransitions]
    
    private var state: State
    
    private var triggers: [State:[StateTrigger]]
    
    public init(initialState:State) {
        self.state = initialState
        self.stateTransitionsForState = [State : StateTransitions]()
        self.triggers = [State : [StateTrigger]]()
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
    
    public mutating func addTrigger(forState state:State, trigger:@escaping StateTrigger) {
        if var triggersForState = self.triggers[state] {
            triggersForState.append( trigger )
            triggers[state] = triggersForState
        }
        else {
            var triggersForState = [StateTrigger]()
            triggersForState.append( trigger )
            triggers[state] = triggersForState
        }
    }
    
    public mutating func perform(action:Action, withContext context: Context? = nil) {
        let oldState = state
        
        if let availableTransitions = stateTransitionsForState[oldState], let s = availableTransitions[action] {
            state = s
                    
            if let stateTriggers = self.triggers[s] {
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
