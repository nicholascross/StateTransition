import XCTest
@testable import StateTransition

class ReadmeExampleTests: XCTestCase {

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

    func testExample() {
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
    }
}
