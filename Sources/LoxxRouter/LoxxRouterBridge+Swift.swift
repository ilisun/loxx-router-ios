import Foundation
import CoreLocation
import LoxxRouterCore  // Bridge is now part of XCFramework (must match binary target name)

/// Internal Swift extension to bridge Objective-C++ to pure Swift API
extension LoxxRouterBridge {
    
    /// Calculate route (Swift-friendly wrapper)
    func route(
        from start: CLLocationCoordinate2D,
        to end: CLLocationCoordinate2D,
        profile: LoxxRoutingProfile
    ) throws -> LoxxRoute {
        let profileInt: Int = (profile == .car) ? 0 : 1
        
        // Swift automatically converts ObjC error: parameter to throws
        do {
            let result = try self.route(from: start, to: end, profile: profileInt)
            return try parseRouteResult(result)
        } catch let nsError as NSError {
            throw convertError(nsError)
        }
    }
    
    /// Parse route dictionary result
    private func parseRouteResult(_ result: [AnyHashable: Any]) throws -> LoxxRoute {
        
        // Extract coordinates
        guard let coordValues = result["coordinates"] as? [NSValue] else {
            throw LoxxRouterError.internalError("Invalid coordinates in result")
        }
        
        let coordinates = coordValues.compactMap { value -> CLLocationCoordinate2D? in
            var coordinate = CLLocationCoordinate2D()
            value.getValue(&coordinate)
            return coordinate
        }
        
        // Extract distance and duration
        guard let distance = result["distance"] as? Double,
              let duration = result["duration"] as? Double else {
            throw LoxxRouterError.internalError("Invalid distance or duration in result")
        }
        
        return LoxxRoute(
            coordinates: coordinates,
            distance: distance,
            duration: duration
        )
    }
    
    /// Convert NSError from bridge to Swift LoxxRouterError
    private func convertError(_ nsError: NSError) -> LoxxRouterError {
        // Check error domain
        guard nsError.domain == LoxxRouterErrorDomain as String else {
            return .internalError(nsError.localizedDescription)
        }
        
        // Convert error code (matches LoxxRouterErrorCode from ObjC header)
        switch nsError.code {
        case 1: // LoxxRouterErrorCodeDatabaseNotFound
            return .databaseNotFound
        case 2: // LoxxRouterErrorCodeNoRoute
            return .noRoute
        case 3: // LoxxRouterErrorCodeNoTile
            return .noTileData
        case 4: // LoxxRouterErrorCodeDataCorrupted
            return .dataCorrupted
        case 5: // LoxxRouterErrorCodeInternal
            return .internalError(nsError.localizedDescription)
        default:
            return .internalError(nsError.localizedDescription)
        }
    }
}

