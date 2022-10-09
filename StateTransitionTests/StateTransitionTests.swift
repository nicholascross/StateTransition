import XCTest
import Combine
@testable import StateTransition

private enum StateOfMatter: StateTransitionable {
    typealias Action = EnergyTransfer
    
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

private enum EnergyTransfer {
    case increase
    case decrease
}

class StateTransitionTests: XCTestCase {
    private var stateChanged: XCTestExpectation!
    private var currentState: StateOfMatter!
    private var action: EnergyTransfer!
    private var cancellable: AnyCancellable!
    private var actionSubject: PassthroughSubject<EnergyTransfer, Never>!

    override func setUp() {
        super.setUp()
        stateChanged = XCTestExpectation()
        actionSubject = PassthroughSubject<EnergyTransfer, Never>()
        cancellable = StateOfMatter.solid.publishStateChanges(when: actionSubject.eraseToAnyPublisher()).sink(receiveValue: transitioned)
    }
    
    func testSingleTransition() {
        actionSubject.send(.increase)
        wait(for: [stateChanged], timeout: 0.2)
        XCTAssert(currentState == .liquid, "Expected to melt solid to liquid")
    }
    
    func testAllTransitions() {
        actionSubject.send(.increase)
        actionSubject.send(.increase)
        actionSubject.send(.increase)
        XCTAssert(currentState == .plasma, "Expected to melt solid to plasma state")
        
        actionSubject.send(.decrease)
        actionSubject.send(.decrease)
        actionSubject.send(.decrease)
        XCTAssert(currentState == .solid, "Expected to freeze plasma to solid state")
    }
    
    func testIgnoreInvalidTransitions() {
        actionSubject.send(.increase)
        actionSubject.send(.increase)
        actionSubject.send(.increase)
        actionSubject.send(.increase)
        actionSubject.send(.increase)
        actionSubject.send(.increase)
        wait(for: [stateChanged], timeout: 0.2)
        XCTAssert(currentState == .plasma, "Expected to melt solid to plasma state")

        stateChanged = XCTestExpectation()
        actionSubject.send(.decrease)
        actionSubject.send(.decrease)
        actionSubject.send(.decrease)
        actionSubject.send(.decrease)
        actionSubject.send(.decrease)
        wait(for: [stateChanged], timeout: 0.2)
        XCTAssert(currentState == .solid, "Expected to freeze plasma to solid state")
    }

    fileprivate func transitioned(energyTransfer: EnergyTransfer, fromState: StateOfMatter, toState: StateOfMatter) {
        self.currentState = toState
        self.action = energyTransfer
        self.stateChanged.fulfill()
    }
}
