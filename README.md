# StateTransition
A swift state machine supporting; states, transitions, actions and transition handling

```swift
        enum StateOfMatter {
            case Solid
            case Liquid
            case Gas
            case Plasma
        }
        
        enum EnergyTransfer {
            case Increase
            case Decrease
        }
        
        var stateMachine = StateMachine<EnergyTransfer, StateOfMatter, String>(initialState: .Solid)
        
        stateMachine.addTransition(fromState: .Solid, toState: .Liquid, when: .Increase)
        stateMachine.addTransition(fromState: .Liquid, toState: .Gas, when: .Increase)
        stateMachine.addTransition(fromState: .Gas, toState: .Plasma, when: .Increase)
        stateMachine.addTransition(fromState: .Plasma, toState: .Gas, when: .Decrease)
        stateMachine.addTransition(fromState: .Gas, toState: .Liquid, when: .Decrease)
        stateMachine.addTransition(fromState: .Liquid, toState: .Solid, when: .Decrease)
        
        func stateOfMatterChanged(energyTransfer: EnergyTransfer, fromState: StateOfMatter, toState: StateOfMatter, context:String?) {
            print("transitioned from \(fromState) to \(toState) as result of energy \(energyTransfer)")
            
            if let c = context {
                print("\(c)")
            }
        }
        
        stateMachine.addHandlerForTransition(toState: .Liquid, handler: stateOfMatterChanged)
        stateMachine.addHandlerForTransition(toState: .Gas, handler: stateOfMatterChanged)
        stateMachine.addHandlerForTransition(toState: .Plasma, handler: stateOfMatterChanged)
        
        stateMachine.addHandlerForTransition(toState: .Liquid) {
            _, fromState, _, _ in
            if fromState == .Solid {
                print("it melted.")
            }
        }
        
        stateMachine.perform(action: .Increase)
        //prints: transitioned from Solid to Liquid as result of energy Increase
        //prints: it melted.
        stateMachine.perform(action: .Increase)
        //prints: transitioned from Liquid to Gas as result of energy Increase
        stateMachine.perform(action: .Increase, withContext: "it is very hot")
        //prints: transitioned from Gas to Plasma as result of energy Increase
        //prints: it is very hot
```
