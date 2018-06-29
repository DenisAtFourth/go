

import UIKit
import CoreLocation
import MapKit
import UserNotifications


class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UNUserNotificationCenterDelegate {
    
    let locationManager:CLLocationManager = CLLocationManager()
    var geoFenceRegion:CLCircularRegion?
    var notificationCenter: UNUserNotificationCenter = UNUserNotificationCenter.current()

    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.notificationCenter.delegate = self
        let options: UNAuthorizationOptions = [.alert, .sound]
        self.notificationCenter.requestAuthorization(options: options) { (granted, error) in
            if !granted {
                print("Permission not granted")
            }
        }

        
        self.mapView.delegate = self
        self.locationManager.delegate = self
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
        
        let center:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 51.5142173, longitude: -0.1235)
        self.geoFenceRegion = CLCircularRegion(
            center: center,
            radius: 50,
            identifier: "fourth"
        )
        self.geoFenceRegion?.notifyOnExit = true
        self.geoFenceRegion?.notifyOnEntry = true
        
        self.locationManager.startMonitoring(for: geoFenceRegion!)
//        self.checkLocation()
        
        let circle = MKCircle(center: center, radius: (geoFenceRegion?.radius)!)
        self.mapView.add(circle)
    }
    
    @IBAction func checkLocation(_ sender: UIButton? = nil) {
        //call login shit
        print("check login")
        locationManager.requestState(for: geoFenceRegion!)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let circleOverlay = overlay as? MKCircle else {
            return MKOverlayRenderer()
        }
        
        let circle = MKCircleRenderer(overlay: circleOverlay)
        circle.strokeColor = .red
        circle.fillColor = .red
        circle.lineWidth = 1
        circle.alpha = 0.5
        return circle
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        let center = location.coordinate
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: center, span: span)

        mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("entering region", region.identifier)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("leaving region", region.identifier)
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        self.loginButton.isHidden = true
        self.logoutButton.isHidden = true
        
        var task:DownloadTask
        
        switch state {
        case .inside:
            print("inside")
            // call login
            self.logoutButton.isHidden = false
            task = DownloadTask(url: "https://us-central1-fourth-go.cloudfunctions.net/login")
            task.start()
            
            self.handleEvent(forRegion: region, message: "entering")
            
            
        case .outside:
            print("outside")
            // call logout
            self.loginButton.isHidden = false
            task = DownloadTask(url: "https://us-central1-fourth-go.cloudfunctions.net/logout")
            task.start()
            
            self.handleEvent(forRegion: region, message: "leaving")
            
        default: break
        }
    }
    
    func handleEvent(forRegion region: CLRegion!, message:String!) {
        let content = UNMutableNotificationContent()
        content.title = "Fourth GO"
        content.body = "You're now \(message!) Fourth's realm!"
        content.sound = UNNotificationSound.default()
        
        var timeInSeconds: TimeInterval = 1 // 60s * 15 = 15min
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInSeconds,
                                                        repeats: false)
        
        let identifier = region.identifier
        let request = UNNotificationRequest(identifier: identifier,
                                            content: content,
                                            trigger: trigger)
        
        self.notificationCenter.add(request, withCompletionHandler: { (error) in
            if error != nil {
                print("Error adding notification with identifier: \(identifier)")
            }
        })
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // when app is onpen and in foregroud
        completionHandler(.alert)
    }
}











