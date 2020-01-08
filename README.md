# StateTransition
![build status](https://travis-ci.org/nicholascross/StateTransition.svg?branch=master)
![code coverage](https://img.shields.io/codecov/c/github/nicholascross/StateTransition.svg)
[![carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) 
[![CocoaPods compatible](https://img.shields.io/cocoapods/v/StateTransition.svg)](https://cocoapods.org/pods/StateTransition) 
[![GitHub release](https://img.shields.io/github/release/nicholascross/StateTransition.svg)](https://github.com/nicholascross/StateTransition/releases) 
![Swift 5.1.x](https://img.shields.io/badge/Swift-5.0.x-orange.svg) 
![platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20OS%20X%20%7C%20watchOS%20%7C%20tvOS%20-lightgrey.svg)

A swift state machine supporting; states, transitions, actions and transition handling via Combine.

```swift
enum StateOfMatter: StateTransitionable {
    typealias Action = EnergyTransfer
    typealias Context = String
    
    case Solid
    case Liquid
    case Gas
    case Plasma
    
    static func defineTransitions(_ stateMachine: StateMachine<EnergyTransfer, StateOfMatter>.TransitionBuilder) {
        stateMachine.addTransition(fromState: .Solid, toState: .Liquid, when: .Increase)
        stateMachine.addTransition(fromState: .Liquid, toState: .Gas, when: .Increase)
        stateMachine.addTransition(fromState: .Gas, toState: .Plasma, when: .Increase)
        stateMachine.addTransition(fromState: .Plasma, toState: .Gas, when: .Decrease)
        stateMachine.addTransition(fromState: .Gas, toState: .Liquid, when: .Decrease)
        stateMachine.addTransition(fromState: .Liquid, toState: .Solid, when: .Decrease)
    }
}

enum EnergyTransfer {
    case Increase
    case Decrease
}

func transitionHandler(action: EnergyTransfer, fromState: StateOfMatter, toState: StateOfMatter)->() {
    print("transitioned from \(fromState) to \(toState) as result of energy \(action)")
}

let actionSubject = PassthroughSubject<EnergyTransfer, Never>()
let stateChanges = StateOfMatter.Solid.publishStateChanges(when: actionSubject.eraseToAnyPublisher())
let cancellable = stateChanges.sink(receiveValue: transitionHandler)

actionSubject.send(.Increase)
//prints: transitioned from Solid to Liquid as result of energy Increase
actionSubject.send(.Increase)
//prints: transitioned from Liquid to Gas as result of energy Increase
```
