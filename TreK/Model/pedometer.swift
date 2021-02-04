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
    
    @Published var stepHistory: [Double] = [] {
        willSet { objectWillChange.send() }
    }
    
   
    
    @Published var stepsTaken = 0 {
        willSet { objectWillChange.send() }
    }
    
    override init() {
        super.init()
        
        getTodaySteps()
        
        
    }
    
    func getStepHistory()  {
        
       
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        
        
        var fromDate = today()
        var toDate = today()
        print (fromDate)
        
        for index in (2...4).reversed() {
            //let dayMinus:Double = Double(-1 * index * 60 * 60 * 24)
          
            
            //let fromDate = Date(timeIntervalSinceNow: dayMinus)
            //let toDate = Date(timeIntervalSinceNow: dayMinus * -1)
            //let formater = DateFormatter()
            
            //formater.dateStyle = .short
            
            print(index)
            
            
            fromDate.changeDays(by: (-1*index))
            print (fromDate)
            toDate.changeDays(by: (-1*index)+1)
            print (toDate)
            
            pedometer.queryPedometerData(from: fromDate, to: toDate, withHandler: { (pedometerData, error) in
                if let pData = pedometerData{
                    
                    let key = formatter.string(from: pData.startDate)
                    print("Key : \(key)")
                    
                    DispatchQueue.main.async {
                        self.stepHistory.append(pData.numberOfSteps.doubleValue)
                    }
                    
                    
                }
            })
            
            
            //reset date to today
            fromDate = today()
            toDate = today()

        }
        
        
    }
    
    func getTodaySteps(){
        
        
        let fromDate:Date = today()
        pedometer.queryPedometerData(from: fromDate, to: Date(), withHandler: { (pedometerData, error) in
            if let pData = pedometerData{
                self.previousSteps = pData.numberOfSteps.intValue
                self.stepsTaken = self.previousSteps
            }
            
        })
    }
    
    func today()->Date{
        var  todayAtMidnight: Date
        
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        //mm/dd/yyyy
        let todayString = formatter.string(from: now)

        
        //formatter.dateFormat = "mm/dd/yyyy"
        todayAtMidnight = formatter.date(from: todayString)!
        
        return todayAtMidnight
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
    
   
    
}

extension Date {
    mutating func changeDays(by days: Int) {
           self = Calendar.current.date(byAdding: .day, value: days, to: self)!
       }
}
