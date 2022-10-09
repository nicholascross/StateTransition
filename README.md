# StateTransition
[![nicholascross](https://circleci.com/gh/nicholascross/StateTransition.svg?style=svg)](https://app.circleci.com/pipelines/github/nicholascross/StateTransition)
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
