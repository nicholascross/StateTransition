//
//  StateTransition.swift
//  StateTransition
//
//  Created by Nicholas Cross on 7/11/2016.
//  Copyright © 2016 Nicholas Cross. All rights reserved.
//
import Foundation

//todo: remove this hack once compiler error is fixed
public struct StateWrapper<S> {
    var wrappedState: [S]
    
    init(_ state: S) {
        wrappedState = [state]
    }
    
    var state: S {
        get {
            return wrappedState[0]
        }
        set (state) {
            wrappedState[0] = state
        }
    }
}

public class StateMachine<Action:Equatable,State:Hashable> {
    
    public typealias StateTrigger = (Action,State,State,AnyObject?)->()
    public typealias StateTransition = (Action,State)
    
    private var stateTransitions: Dictionary<State,[(Action,State)]>
    
    private var state: StateWrapper<State>
    
    private var triggers: Dictionary<State,[StateTrigger]>
    
    public init(initialState:State) {
        self.state = StateWrapper(initialState)
        self.stateTransitions = [State : [StateTransition]]()
        self.triggers = [State : [StateTrigger]]()
    }
    
    public func addTransition(fromState:State, toState:State, when action:Action) {
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
    
    public func addTrigger(forState state:State, trigger:@escaping StateTrigger) {
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
    
    public func perform(action:Action, context: AnyObject?) {
        let oldState = state.state
        
        if let availableTransitions: [(Action, State)] = stateTransitions[oldState] {
            
            for t in availableTransitions {
                switch t {
                case (let a, let s) where a == action:
                    
                    state.state = s
                    
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
        return self.state.state == state
    }
}
