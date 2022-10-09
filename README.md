# StateTransition
[![nicholascross](https://circleci.com/gh/nicholascross/StateTransition.svg?style=svg)](https://app.circleci.com/pipelines/github/nicholascross/StateTransition)
[![GitHub release](https://img.shields.io/github/release/nicholascross/StateTransition.svg)](https://github.com/nicholascross/StateTransition/releases) 
![Swift 5.1.x](https://img.shields.io/badge/Swift-5-orange.svg) 
![platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20macOS%20%7C%20watchOS%20%7C%20tvOS%20-lightgrey.svg)

A declaritive swift state machine.

## Example state machine definition

```swift
enum StateOfMatter: StateTransitionable {
    typealias Action = EnergyTransfer

    case solid
    case liquid
    case gas
    case plasma

    var transitions: Transitions {
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

## Example state machine usage

```swift
    var stateMachine = StateOfMatter.solid.stateMachine()

    guard let transition = stateMachine.perform(action: .increase) else {
        // no transition occured
        return
    }
    
    print("transitioned from \(transition.from) to \(transition.to) as result of energy \(transition.action)")
    //prints: transitioned from solid to liquid as result of energy increase

    stateMachine.perform(action: .increase)
    print("current state is \(stateMachine.currentState)")
    //prints: current state is gas
```

## Example of state observation

```swift
    class Example {
        var stateMachine = StateOfMatter.solid.stateMachine() {
            didSet {
                print("current state is \(stateMachine.currentState)")
            }
        }
    }

    let example = Example()
    example.stateMachine.perform(action: .increase)
    // prints: current state is liquid
    example.stateMachine.perform(action: .increase)
    // prints: current state is gas
``` 
