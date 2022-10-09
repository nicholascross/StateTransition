import Foundation

@resultBuilder
public struct TransitionBuilder {
    public static func buildBlock<Action: Hashable, State: Hashable>(_ components: When<Action, State>...) -> StateMachine<Action, State>.TransitionBuilder {
        let builder = StateMachine<Action, State>.TransitionBuilder()
        components.forEach { when in
            when.transitions.forEach { transition in
                builder.addTransition(fromState: transition.from, toState: transition.to, when: when.action)
            }
        }
        return builder
    }
}

@resultBuilder
public enum WhenBuilder {
    public static func buildBlock<State: Hashable>(_ components: Transition<State>...) -> [Transition<State>] {
        components
    }
}

public struct When<Action: Hashable, State: Hashable> {
    let action: Action

    @WhenBuilder
    let transitions: [Transition<State>]
}

public struct Transition<State: Hashable> {
    let from: State
    let to: State
}

extension StateTransitionable {
    func when(_ action: Action, @WhenBuilder _ transitions: () -> [Transition<Self>]) -> When<Action, Self> {
        When(action: action, transitions: transitions)
    }

    func transition(from: Self, to: Self) -> Transition<Self> {
        Transition(from: from, to: to)
    }
}
