//
//  ContentView.swift
//  TreK
//
//  Created by Arjun Maganti on 12/29/20.
//

import SwiftUI
import CoreMotion
import SwiftUICharts
import NotificationBannerSwift

struct ContentView: View {
    
    @State private var isPaused = false
    @State private var pauseButtonText = "Pause"
    @State private var currentGoal: Double = 0
    @State private var barChartData: [Double] = [63, 60, 79]
    
    @State private var barChartDataTest = [("2018 Q4",63150), ("2019 Q1",50900), ("2019 Q2",77550), ("2019 Q3",79600), ("2019 Q4",92550)]
    
    @ObservedObject var pedometer = Pedometer()
    @ObservedObject var beaconManager = BeaconManager()
    
    
    
    var body: some View {
        
       
        
        ZStack{
           (Color(red: 255, green: 255, blue: 255 ))
            .ignoresSafeArea()
            //Image("\(beaconManager.selectedBeacon.backgroundImage)")
             //   .resizable()
             //   .ignoresSafeArea()
             //   .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
           
            
            VStack {
                    
                VStack{
                    HStack (spacing: 0) {
                        Text("Tre")
                            .font(.system(size: 50))
                            .padding(.trailing, 0.0)
                            .foregroundColor(Color.black)
                        
                        Text("K")
                            .font(.system(size: 50))
                            .foregroundColor(Color(red: 210, green: 0, blue: 0, opacity: 1.0))
                            .padding(.trailing,0.0)
                       
                    }
                    .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: 80, alignment: .center)
                    HStack{
                        Image(systemName: "location.fill")
                            .font(.system(size: 15.0))
                            .foregroundColor(beaconManager.selectedBeacon.isActive ? .green: .gray)
                        Text("\(beaconManager.selectedBeacon.name)")
                            .font(.system(size:15))
                            .foregroundColor(.black)
                       
                    }
                }
                .frame(width: 500, height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, alignment: .top)
                
                
                
                VStack {
                    HStack{
                        Text("\(pedometer.stepsTaken)")
                            .font(.system(size: 40))
                            .foregroundColor(Color.black)
                            .frame(width: 200.0)
                
                        Text("\(Int(currentGoal))")
                            .font(.system(size: 40))
                            .foregroundColor(Color.black)
                            .frame(width: 200.0)
                
                    }
            
                    
                    HStack{
                        Text("Steps")
                            .font(.system(size: 20))
                            .frame(width: 200.0)
                            .foregroundColor(Color.black)
                        
                        Text("Goal(steps/day)")
                            .font(.system(size: 20))
                            .frame(width: 200)
                            .foregroundColor(Color.black)
                
                    }
                    
                }
                .padding(20)
                
                Divider()
                VStack{
                    HStack (spacing: 20) {
                        VStack{
                            Button(
                                action: {
                                if(isPaused){
                                    isPaused = false
                                    pauseButtonText = "Pause"
                                    pedometer.startCountingSteps()
                                    
                                    let banner = NotificationBanner(title: "TreK Notification", subtitle: "Pedometer is active!", style: .success)
                                    banner.show(bannerPosition: .bottom)
                                    banner.show()
                                }
                                else{
                                    isPaused = true
                                    pauseButtonText = "Play"
                                    pedometer.stopCountingSteps()
                                    
                                    let banner = NotificationBanner(title: "TreK Notification", subtitle: "Pedometer is paused!", style: .danger)
                                    banner.show(bannerPosition: .bottom)
                                    banner.show()
                                }
                            }) {
                                Image(systemName: "\(pauseButtonText.lowercased())")
                                    .font(.title)
                              
                                Text("\(pauseButtonText)")
                                    .font(.system(size: 20))
                                   
                                    
                            }
                            .frame(width: 120.0, height: 40)
                            .padding(5)
                            .background(Color.white)
                            .foregroundColor(Color.black)
                            .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/)
                            .cornerRadius(3)
                        }
                        .frame(height:100, alignment: .center)
                        
                        VStack{
                            Slider(value: $currentGoal,
                                   in: 5000...30000,
                                   step: 1000
                            )
                            .accentColor(.red)
                         
                                
                                
                            Text("Slide to set Goal")
                                .foregroundColor(Color.black)
                        }
                        .frame(width: 180, height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, alignment: .center)
                        
                        
                       
                        
                    }
                }
                Divider()
                VStack{
                    
                 
               
                    
                    let chartStyle = ChartStyle(
                            backgroundColor: Color.white,
                            accentColor: Colors.OrangeStart,
                            secondGradientColor: Colors.OrangeEnd,
                            textColor: Color.black,
                            legendTextColor: Color.black,
                            dropShadowColor: Color.gray
                            
                    )
                     
                    BarChartView(data: ChartData(values:pedometer.stepHistory),
                                 title: "Past 7 Days Daily Steps",
                                 style: chartStyle,
                                 form: ChartForm.extraLarge,
                                 dropShadow: false,
                                 valueSpecifier: "%.0f")
                    
                 
                }
                
               
            
            }
            .frame(minWidth:0, maxWidth: .infinity, minHeight:0, maxHeight: .infinity, alignment: .top)
            
        }
        .onAppear{
            pedometer.startCountingSteps()
            pedometer.getStepHistory()
            currentGoal = 10000
            
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                print("Moving back to the foreground!")
            
            pedometer.getStepHistory()
            pedometer.getTodaySteps()
            
            
        }
     
        
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
