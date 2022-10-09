import Foundation
import Combine

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
