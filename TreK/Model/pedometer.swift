//
//  pedometer.swift
//  TreK
//
//  Created by Arjun Maganti on 12/31/20.
//

import Foundation
import CoreMotion
import Combine

class Pedometer: NSObject, ObservableObject {
    
    private let pedometer = CMPedometer ()
    private var previousSteps = 0
    
    @Published var stepsTaken = 0 {
        willSet { objectWillChange.send() }
    }
    
    override init() {
        super.init()
    }
    
    func startCountingSteps() {
        if CMPedometer.isStepCountingAvailable()  {
            pedometer.startUpdates(from: Date()) {
                  [self] pedometerData, error in
                  guard let pedometerData = pedometerData, error == nil else { return }

                  DispatchQueue.main.async {
                    stepsTaken = pedometerData.numberOfSteps.intValue + previousSteps
                  }
            }
        }
    }
    
    func stopCountingSteps() {
        previousSteps = stepsTaken
        if CMPedometer.isStepCountingAvailable()  {
            pedometer.stopUpdates()
        }
    }
    
   
    
}
