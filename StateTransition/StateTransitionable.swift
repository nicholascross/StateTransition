import Foundation
import Combine

public protocol StateTransitionable: Hashable {
    associatedtype Action: Hashable
    
    @TransitionBuilder var transitions: StateMachine<Action, Self>.TransitionBuilder { get }
}

public extension StateTransitionable {
    func stateMachine() -> StateMachine<Action, Self> {
        return StateMachine(initialState: self, transitions: transitions.transitionsForState)
    }

    func publishStateChanges(when actions: AnyPublisher<Action, Never>) -> AnyPublisher<StateMachine<Action, Self>.StateTransition, Never> {
        var stateMachine: StateMachine = self.stateMachine()
        return actions.compactMap { stateMachine.perform(action: $0) }.eraseToAnyPublisher()
    }
}
