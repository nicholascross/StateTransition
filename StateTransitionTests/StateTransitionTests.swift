import XCTest
@testable import StateTransition

private enum StateOfMatter: StateTransitionable {
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

private enum EnergyTransfer {
    case increase
    case decrease
}

class StateTransitionTests: XCTestCase {
    private var currentState: StateOfMatter!
    private var action: EnergyTransfer!
    private var stateMachine: StateMachine<EnergyTransfer, StateOfMatter>!

    override func setUp() {
        super.setUp()
        stateMachine = StateOfMatter.solid.stateMachine()
    }
    
    func testSingleTransition() {
        stateMachine.perform(action: .increase)
        XCTAssert(stateMachine.currentState == .liquid, "Expected to melt solid to liquid")
    }
    
    func testAllTransitions() {
        stateMachine.perform(action: .increase)
        stateMachine.perform(action: .increase)
        stateMachine.perform(action: .increase)
        XCTAssert(stateMachine.currentState == .plasma, "Expected to melt solid to plasma state")
        
        stateMachine.perform(action: .decrease)
        stateMachine.perform(action: .decrease)
        stateMachine.perform(action: .decrease)
        XCTAssert(stateMachine.currentState == .solid, "Expected to freeze plasma to solid state")
    }
    
    func testIgnoreInvalidTransitions() {
        stateMachine.perform(action: .increase)
        stateMachine.perform(action: .increase)
        stateMachine.perform(action: .increase)
        stateMachine.perform(action: .increase)
        stateMachine.perform(action: .increase)
        stateMachine.perform(action: .increase)
        XCTAssert(stateMachine.currentState == .plasma, "Expected to melt solid to plasma state")

        stateMachine.perform(action: .decrease)
        stateMachine.perform(action: .decrease)
        stateMachine.perform(action: .decrease)
        stateMachine.perform(action: .decrease)
        stateMachine.perform(action: .decrease)
        stateMachine.perform(action: .decrease)
        XCTAssert(stateMachine.currentState == .solid, "Expected to freeze plasma to solid state")
    }
}
