//
//  BeaconManager.swift
//  pedometer
//
//  Created by Arjun Maganti on 12/27/20.
//

import Foundation
import CoreLocation
import Combine


struct Sensor: Hashable, Codable, Identifiable {
    var id: Int
    var uuid: String
    var name: String
    var icon: String
    var iconColor: String
    var backgroundImage: String
    var status: Bool
    var distance: Double
}

class BeaconManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    private let locationManager = CLLocationManager()
    private var locationSensors: [Sensor] = []
    private var calibratedDistance = 3.0
    private var defaultNotification = "Get set go..."
    private var moveNotified: Bool = false
    private var alertManager = Alerts()
  

    
    @Published private (set) var locationPermissionGranted = false
    
   
    @Published var selectedBeacon = Sensor(id:20020,
                                uuid: "cbc59d2a-ca70-44cc-99c2-ca85447ad000",
                                name:"Unknown",
                                icon:"heart",
                                iconColor:"gray",
                                backgroundImage: "bkg",
                                status: false,
                                distance: 30 ) {
        willSet { objectWillChange.send() }
    }
    
    let objectWillChange = PassthroughSubject<Void, Never>()
    
   
    
    @Published var notification = "" {
        willSet { objectWillChange.send() }
    }
    

    
    
    

    override init() {
        super.init()
        locationManager.delegate = self
  
        alertManager.requestNotifications()
        requestLocationPermission()
        
        
        notification = defaultNotification
        loadSensors()

        startHourlyCheckTimer()
        
       
     
      }
    
    func startHourlyCheckTimer(){
        _ = Timer.scheduledTimer(timeInterval: 15.0,
                                         target: self,
                                         selector: #selector(dingDong),
                                         userInfo: nil, repeats: true)
       
    
    }
    
    @objc func dingDong(){
        print("timer fire: \(selectedBeacon.status)")
        if(selectedBeacon.status){
            moveNotified = true
            notification = "Break Time! Go ahead take a strech and go for a walk"
            
            alertManager.showAlert(title: "TreK",subtitle: notification)
        }
        else{
            notification = defaultNotification
        }
    }
    
    func loadSensors(){
        
        locationSensors.append(Sensor(id:20201,
                                      uuid: "cbc59d2a-ca70-44cc-99c2-ca85447ad4de",
                                      name:"Living Room",
                                      icon:"tv",
                                      iconColor:"gray",
                                      backgroundImage: "lr",
                                      status: false,
                                      distance: 30 ))
        locationSensors.append(Sensor(id:20202,
                                      uuid: "821f04d8-92e0-4fec-8b69-0cd710a68dce",
                                      name:"Bedroom",
                                      icon:"bed.double",
                                      iconColor:"gray",
                                      backgroundImage: "br",
                                      status: false,
                                      distance: 30 ))
        locationSensors.append(Sensor(id:20203,
                                      uuid: "34fa2185-a252-42bd-a186-3073e2cd0a8c",
                                      name:"Door",
                                      icon:"house",
                                      iconColor:"gray",
                                      backgroundImage: "dr",
                                      status: false,
                                      distance: 30 ))
       locationSensors.append(Sensor(id:20203,
                                      uuid: "a2711288-3d52-4088-895f-4914f8c12646",
                                      name:"Elevator",
                                      icon:"capslock",
                                      iconColor:"gray",
                                      backgroundImage: "el",
                                      status: false,
                                      distance: 30 ))
 
        
    }
        
    func requestLocationPermission() {
        self.locationManager.requestAlwaysAuthorization()
    }
        
    func locationManager(_ manager: CLLocationManager,
                             didEnterRegion region: CLRegion){
            
       
        
        if let beaconRegion = region as? CLBeaconRegion {
            print("DID ENTER REGION: uuid: \(beaconRegion.uuid.uuidString)")
     
            
        }
            
    }

    func locationManager(_ manager: CLLocationManager,
                         didExitRegion region: CLRegion){
                

        print ("Exited the region")
        
        //selectedBeacon.backgroundImage = "bkg"
        //notification = defaultNotification
        //selectedBeacon.status = false
        
    }

    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
      print("Failed monitoring region: \(error.localizedDescription)")
    
        
        
    }
          
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
      print("Location manager failed: \(error.localizedDescription)")
    }
        
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            if status == .authorizedAlways {
                publish(permissionGranted: true)
                
 
                
                if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                    startMonitoring()
                    
                    
                    print("Monitoring")
                    
                    return
                }
            } else {
                publish(permissionGranted: false)
            }
    }

    func publish(permissionGranted: Bool) {
            DispatchQueue.main.async {
                self.locationPermissionGranted = permissionGranted
            }
    }
        
    func startMonitoring() {
        
        for locationSensor in locationSensors{
            let uuid = UUID(uuidString: locationSensor.uuid)
            let beaconID = "com.cybertron.myBeaconRegion"
            let constraint = CLBeaconIdentityConstraint(uuid: uuid!,
                                                        major: CLBeaconMajorValue(2020),
                                                        minor:  CLBeaconMinorValue(17))
            locationManager.startRangingBeacons(satisfying: constraint)
            
            
            let beaconRegion = CLBeaconRegion(beaconIdentityConstraint: constraint, identifier: beaconID)
            locationManager.startMonitoring(for: beaconRegion)
            
            print ("add for monitoring \(locationSensor.uuid)")
        }
       
                    
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        for beacon in beacons{
            
           
            if((beacon.accuracy>0) && (beacon.accuracy<calibratedDistance)){
                print ("Beacon ID: \(beacon.uuid)")
                print ("Beacon ID: \(beacon.accuracy)")
                
                if let index = locationSensors.firstIndex(where: {$0.uuid == beacon.uuid.uuidString.lowercased()}){
                
                    print ("Found beacon")
                    selectedBeacon = locationSensors[index]
                    selectedBeacon.status = true
                    selectedBeacon.distance = beacon.accuracy
                    print ("selected beacon : \(selectedBeacon.name)")
                    print ("selected beacon status : \(selectedBeacon.status)")
                    print ("moveNotified : \(moveNotified)")
                    
                    if (selectedBeacon.name == "Elevator"){
                        notification = "Skip Elevator and try taking steps."
                        
                        alertManager.showAlert(title: "TreK",subtitle: notification)
                    }
                    else if ((!moveNotified) && (selectedBeacon.name == "Bedroom")){
                        notification = "Sleep well!."
                        
                        alertManager.showAlert(title: "TreK",subtitle: notification)
                    }
                    else if((!moveNotified) && (selectedBeacon.name == "Living Room")){
                        notification = "Lets watch some TV."
                        
                        alertManager.showAlert(title: "TreK",subtitle: notification)
                    }
                    else if(selectedBeacon.name == "Door"){
                        notification = "Bye!"
                        
                        alertManager.showAlert(title: "TreK",subtitle: notification)
                    }
                    else{
                        //notification = defaultNotification
                    }
                    
                }
                
               
            }
            else if((beacon.uuid.uuidString.lowercased() == selectedBeacon.uuid) && (beacon.accuracy>calibratedDistance)){
                selectedBeacon.status = false
                selectedBeacon.backgroundImage = "bkg"
                selectedBeacon.name = "Unknown"
                
                notification = defaultNotification
            }
                
        }
        
        
        
    }
    
    
    
}
