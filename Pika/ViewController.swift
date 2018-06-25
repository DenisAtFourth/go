

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    let locationManager:CLLocationManager = CLLocationManager()
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        let center:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 51.5142173, longitude: -0.1235)
        let geoFenceRegion:CLCircularRegion = CLCircularRegion(
            center: center,
            radius: 50,
            identifier: "fourth"
        )
        geoFenceRegion.notifyOnExit = true
        geoFenceRegion.notifyOnEntry = true
        
        locationManager.startMonitoring(for: geoFenceRegion)
        
        
        
        let circle = MKCircle(center: center, radius: geoFenceRegion.radius)
        self.mapView.add(circle)
    }
    
    @IBAction func login(_ sender: UIButton) {
        //call login shit
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
        // call login shit
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("leaving region", region.identifier)
    }
    
    func callLogin(){
        // checks if you're close enough to the target
        // then calls ajax
    }
}











