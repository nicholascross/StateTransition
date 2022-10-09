# StateTransition
![build status](https://travis-ci.org/nicholascross/StateTransition.svg?branch=master)
![code coverage](https://img.shields.io/codecov/c/github/nicholascross/StateTransition.svg)
[![carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) 
[![CocoaPods compatible](https://img.shields.io/cocoapods/v/StateTransition.svg)](https://cocoapods.org/pods/StateTransition) 
[![GitHub release](https://img.shields.io/github/release/nicholascross/StateTransition.svg)](https://github.com/nicholascross/StateTransition/releases) 
![Swift 5.1.x](https://img.shields.io/badge/Swift-5.0.x-orange.svg) 
![platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20OS%20X%20%7C%20watchOS%20%7C%20tvOS%20-lightgrey.svg)

A declaritive swift state machine.

## State machine definition

```swift
enum StateOfMatter: StateTransitionable {
    typealias Action = EnergyTransfer
    typealias Context = String

    case solid
    case liquid
    case gas
    case plasma

    var transitions: StateMachine<EnergyTransfer, StateOfMatter>.TransitionBuilder {
        when(.increase) {
            transition(from: .solid, to: .liquid)
            transition(from: .liquid, to: .gas)
            transition(from: .gas, to: .plasma)
        }
        when(.decrease) {
            transition(from: .plasma, to: .gas)
            transition(from: .gas, to: .liquid)
            transition(from: .liquid, to: .solid)
        }
    }
}

enum EnergyTransfer {
    case increase
    case decrease
}
```

## Example

```swift
    var stateMachine = StateOfMatter.solid.stateMachine()

    guard let transition = stateMachine.perform(action: .increase) else {
        // no transition occured
        return
    }
    
    print("transitioned from \(transition.1) to \(transition.2) as result of energy \(transition.0)")
    //prints: transitioned from solid to liquid as result of energy increase

    stateMachine.perform(action: .increase)
    print("current state is \(stateMachine.currentState)")
    //prints: current state is gas
```
