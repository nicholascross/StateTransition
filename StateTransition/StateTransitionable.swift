import Foundation

public protocol StateTransitionable: Hashable {
    typealias Transitions = StateMachine<Action, Self>.TransitionBuilder
    associatedtype Action: Hashable

    @TransitionBuilder
    var transitions: Transitions { get }
}

public extension StateTransitionable {
    func stateMachine() -> StateMachine<Action, Self> {
        return StateMachine(initialState: self, transitions: transitions.transitionsForState)
    }
}
