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
    private var previousSteps:Int = 0
    
    
    
    @Published var stepsTaken = 0 {
        willSet { objectWillChange.send() }
    }
    
    override init() {
        super.init()
        
        getTodaySteps()
    }
    
    func get6DayStepHistory() -> [String: Int]{
        var stepHistory = [String: Int]()
        
        for index in 1...6 {
            let dayMinus:Double = Double(-1 * index * 60 * 60 * 24)
          
            
            let fromDate = Date(timeIntervalSinceNow: dayMinus)
            let toDate = Date(timeIntervalSinceNow: dayMinus * -1)
            let formater = DateFormatter()
            
            formater.dateStyle = .short
            
            
            pedometer.queryPedometerData(from: fromDate, to: toDate, withHandler: { (pedometerData, error) in
                if let pData = pedometerData{
                    stepHistory[formater.string(from: toDate)] = pData.numberOfSteps.intValue
                }
            })
        }
        
        return stepHistory
    }
    
    func getTodaySteps(){
        
        let fromDate = Date(timeIntervalSinceNow: -1 * 60 * 60 * 24)
        pedometer.queryPedometerData(from: fromDate, to: Date(), withHandler: { (pedometerData, error) in
            if let pData = pedometerData{
                self.previousSteps = pData.numberOfSteps.intValue
                self.stepsTaken = self.previousSteps
            }
            
        })
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
        self.previousSteps = stepsTaken
        if CMPedometer.isStepCountingAvailable()  {
            pedometer.stopUpdates()
        }
    }
    
   //TODO
    // 1. Select from phone history today's steps taken
    
}
