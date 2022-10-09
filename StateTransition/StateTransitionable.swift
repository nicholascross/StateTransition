import Foundation

public protocol StateTransitionable: Hashable {
    associatedtype Action: Hashable
    
    @TransitionBuilder
    var transitions: StateMachine<Action, Self>.TransitionBuilder { get }
}

public extension StateTransitionable {
    func stateMachine() -> StateMachine<Action, Self> {
        return StateMachine(initialState: self, transitions: transitions.transitionsForState)
    }
}
