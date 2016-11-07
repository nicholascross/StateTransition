//
//  StateTransition.swift
//  StateTransition
//
//  Created by Nicholas Cross on 7/11/2016.
//  Copyright © 2016 Nicholas Cross. All rights reserved.
//
import Foundation

public struct StateMachine<Action:Equatable,State:Hashable, Context> {
    
    public typealias StateTrigger = (Action,State,State,Context?)->()
    public typealias StateTransition = (Action,State)
    
    private var stateTransitions: Dictionary<State,[(Action,State)]>
    
    private var state: State
    
    private var triggers: Dictionary<State,[StateTrigger]>
    
    public init(initialState:State) {
        self.state = initialState
        self.stateTransitions = [State : [StateTransition]]()
        self.triggers = [State : [StateTrigger]]()
    }
    
    public mutating func addTransition(fromState:State, toState:State, when action:Action) {
        if var availableTransitions: [(Action, State)] = self.stateTransitions[fromState] {
            availableTransitions.append( (action,toState) )
            stateTransitions[fromState] = availableTransitions
        }
        else {
            var availableTransitions: [(Action, State)] = Array<(Action, State)>()
            availableTransitions.append( (action,toState) )
            stateTransitions[fromState] = availableTransitions
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
        
        if let availableTransitions: [(Action, State)] = stateTransitions[oldState] {
            
            for t in availableTransitions {
                switch t {
                case (let a, let s) where a == action:
                    
                    state = s
                    
                    if let stateTriggers = self.triggers[s] {
                        for trigger in stateTriggers {
                            trigger(a, oldState, s, context)
                        }
                    }
                    
                default:
                    break
                }
            }
        }
    }
    
    public func isState(state:State) -> Bool {
        return self.state == state
    }
}
