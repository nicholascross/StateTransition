import Foundation

public struct StateMachine<Action: Hashable, State: Hashable> {
    public typealias StateTransition = (action: Action, from: State, to: State)
    public typealias StateTransitions = [Action: State]

    private var state: State
    private let transitionsForState: [State: StateTransitions]

    init(initialState: State, transitions: [State: StateTransitions]) {
        state = initialState
        transitionsForState = transitions
    }

    @discardableResult public mutating func perform(action: Action) -> StateTransition? {
        let priorState = state

        if let availableTransitions = transitionsForState[priorState], let nextState = availableTransitions[action] {
            state = nextState
            return (action, priorState, nextState)
        }

        return nil
    }

    public var currentState: State {
        return state
    }

    public class TransitionBuilder {
        var transitionsForState: [State: StateTransitions] = [:]

        public func addTransition(fromState: State, toState: State, when action: Action) {
            if var availableTransitions = transitionsForState[fromState] {
                availableTransitions[action] = toState
                transitionsForState[fromState] = availableTransitions
            } else {
                var availableTransitions = StateTransitions()
                availableTransitions[action] = toState
                transitionsForState[fromState] = availableTransitions
            }
        }
    }
}
