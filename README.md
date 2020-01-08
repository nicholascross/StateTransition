# StateTransition
![build status](https://travis-ci.org/nicholascross/StateTransition.svg?branch=master)
![code coverage](https://img.shields.io/codecov/c/github/nicholascross/StateTransition.svg)
[![carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) 
[![CocoaPods compatible](https://img.shields.io/cocoapods/v/StateTransition.svg)](https://cocoapods.org/pods/StateTransition) 
[![GitHub release](https://img.shields.io/github/release/nicholascross/StateTransition.svg)](https://github.com/nicholascross/StateTransition/releases) 
![Swift 5.1.x](https://img.shields.io/badge/Swift-5.0.x-orange.svg) 
![platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20OS%20X%20%7C%20watchOS%20%7C%20tvOS%20-lightgrey.svg)

A swift state machine supporting; states, transitions, actions and transition handling via Combine.

## State machine definition

```swift
enum StateOfMatter: StateTransitionable {
    typealias Action = EnergyTransfer
    typealias Context = String

    case solid
    case liquid
    case gas
    case plasma

    static func defineTransitions(_ stateMachine: StateMachine<EnergyTransfer, StateOfMatter>.TransitionBuilder) {
        stateMachine.addTransition(fromState: .solid, toState: .liquid, when: .increase)
        stateMachine.addTransition(fromState: .liquid, toState: .gas, when: .increase)
        stateMachine.addTransition(fromState: .gas, toState: .plasma, when: .increase)
        stateMachine.addTransition(fromState: .plasma, toState: .gas, when: .decrease)
        stateMachine.addTransition(fromState: .gas, toState: .liquid, when: .decrease)
        stateMachine.addTransition(fromState: .liquid, toState: .solid, when: .decrease)
    }
}

enum EnergyTransfer {
    case increase
    case decrease
}
```

## Example with Combine

```swift
func transitionHandler(action: EnergyTransfer, fromState: StateOfMatter, toState: StateOfMatter)->() {
    print("transitioned from \(fromState) to \(toState) as result of energy \(action)")
}

let actionSubject = PassthroughSubject<EnergyTransfer, Never>()
let stateChanges = StateOfMatter.solid.publishStateChanges(when: actionSubject.eraseToAnyPublisher())
let cancellable = stateChanges.sink(receiveValue: transitionHandler)

actionSubject.send(.increase)
//prints: transitioned from solid to liquid as result of energy increase
actionSubject.send(.increase)
//prints: transitioned from liquid to gas as result of energy increase
```

## Example without Combine

```swift
var stateMachine = StateOfMatter.solid.stateMachine()

guard let transition = stateMachine.perform(action: .increase) else {
    return
}
print("transitioned from \(transition.1) to \(transition.2) as result of energy \(transition.0)")
//prints: transitioned from solid to liquid as result of energy increase

stateMachine.perform(action: .increase)
print("current state is \(stateMachine.currentState)")
//prints: current state is gas
```
