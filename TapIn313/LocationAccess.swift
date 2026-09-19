import CoreLocation

/// Tracks whether the student has allowed location, and asks only when told to.
/// Used just to show the blue "you are here" dot on the map. Location is never stored,
/// sent anywhere, or used to filter or sort programs.
@Observable
final class LocationAccess: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private(set) var status: CLAuthorizationStatus

    override init() {
        status = manager.authorizationStatus
        super.init()
        manager.delegate = self
    }

    var isAuthorized: Bool {
        status == .authorizedWhenInUse || status == .authorizedAlways
    }

    var isDenied: Bool {
        status == .denied || status == .restricted
    }

    /// Shows the system permission prompt the first time. Does nothing once the choice is made.
    func request() {
        manager.requestWhenInUseAuthorization()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        status = manager.authorizationStatus
    }
}
