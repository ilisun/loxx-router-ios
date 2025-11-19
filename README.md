# LoxxRouter - Offline Routing SDK for iOS

Fast offline routing powered by OpenStreetMap data.

[![Swift](https://img.shields.io/badge/Swift-5.9-orange)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2013.0+-lightgrey)](https://developer.apple.com)
[![License](https://img.shields.io/badge/License-MIT-blue)](LICENSE)

## ✨ Features

- ✅ **Offline routing** - No network required
- ✅ **Fast C++ core** - High performance routing engine
- ✅ **Pure Swift API** - Swifty, type-safe public interface
- ✅ **Multiple profiles** - Car and pedestrian routing
- ✅ **iOS 13.0+** - Wide device support
- ✅ **Swift Concurrency** - Modern async/await support

## 📦 Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/ilisun/loxx-router-ios", from: "3.0.0")
]
```

Or in Xcode:
1. File → Add Package Dependencies
2. Enter URL: `https://github.com/ilisun/loxx-router-ios`
3. Select version: 3.0.0 or later

## 🚀 Quick Start

### 1. Prepare Routing Database

Download or create a `.routingdb` file from OpenStreetMap data using [loxx-converter](https://github.com/ilisun/loxx-core).

Add it to your Xcode project and ensure it's included in your app target.

### 2. Initialize Router

```swift
import LoxxRouter

// Option A: Use bundled database
let router = try LoxxRouter.bundled(resourceName: "routing")

// Option B: Use database in documents directory
let router = try LoxxRouter.documents(filename: "routing.routingdb")

// Option C: Use custom path
let router = try LoxxRouter(databasePath: "/path/to/routing.routingdb")
```

### 3. Calculate Route

#### Async/Await (Recommended)

```swift
let start = CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6173)
let end = CLLocationCoordinate2D(latitude: 55.7522, longitude: 37.6156)

let route = try await router.calculateRoute(
    from: start,
    to: end,
    profile: .car
)

print("Distance: \(route.distanceFormatted)")
print("Duration: \(route.durationFormatted)")
print("Waypoints: \(route.waypointCount)")
```

#### Completion Handler

```swift
router.calculateRoute(
    from: start,
    to: end,
    profile: .car
) { result in
    switch result {
    case .success(let route):
        print("Route found: \(route.distanceFormatted)")
    case .failure(let error):
        print("Routing failed: \(error)")
    }
}
```

#### Synchronous (Blocks thread)

```swift
do {
    let route = try router.calculateRoute(from: start, to: end, profile: .car)
    // Use route...
} catch {
    print("Error: \(error)")
}
```

## 📚 API Reference

### LoxxRouter

Main router class for calculating routes.

**Initializers:**
```swift
// Standard initializer
init(databasePath: String, options: LoxxRouterOptions = LoxxRouterOptions()) throws

// Convenience initializers
static func bundled(resourceName: String, bundle: Bundle = .main, options: LoxxRouterOptions = LoxxRouterOptions()) throws -> LoxxRouter
static func documents(filename: String = "routing.routingdb", options: LoxxRouterOptions = LoxxRouterOptions()) throws -> LoxxRouter
```

**Methods:**
```swift
// Synchronous
func calculateRoute(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, profile: LoxxRoutingProfile = .car) throws -> LoxxRoute

// Async/await
func calculateRoute(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, profile: LoxxRoutingProfile = .car) async throws -> LoxxRoute

// Completion handler
func calculateRoute(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, profile: LoxxRoutingProfile = .car, completion: @escaping (Result<LoxxRoute, LoxxRouterError>) -> Void)
```

### LoxxRoute

Calculated route with coordinates, distance, and duration.

**Properties:**
```swift
let coordinates: [CLLocationCoordinate2D]   // Route polyline
let distance: CLLocationDistance            // Distance in meters
let duration: TimeInterval                  // Duration in seconds

var distanceFormatted: String               // "11.3 km"
var durationFormatted: String               // "5 min" or "1 hr 16 min"
var averageSpeed: Double                    // Speed in km/h
var waypointCount: Int                      // Number of waypoints
var boundingBox: (southwest, northeast)?    // Bounding box
var isEmpty: Bool                           // Check if empty
```

### LoxxRoutingProfile

```swift
enum LoxxRoutingProfile {
    case car    // Car routing - uses motorways, roads
    case foot   // Pedestrian routing - uses footways, paths
}
```

### LoxxRouterOptions

```swift
struct LoxxRouterOptions {
    var tileZoom: Int = 14              // Tile zoom level
    var tileCacheCapacity: Int = 128    // Number of tiles in memory
}
```

### LoxxRouterError

```swift
enum LoxxRouterError: LocalizedError {
    case databaseNotFound       // Database file not found
    case noRoute                // No route between points
    case noTileData             // No map data for region
    case dataCorrupted          // Database corrupted
    case internalError(String)  // Internal error
}
```

## 🗺️ Display Route on Map

### With MapKit

```swift
import MapKit

let route = try await router.calculateRoute(from: start, to: end, profile: .car)

// Create polyline
let polyline = MKPolyline(coordinates: route.coordinates, count: route.waypointCount)
mapView.addOverlay(polyline)

// Fit to bounding box
if let bbox = route.boundingBox {
    let region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: (bbox.southwest.latitude + bbox.northeast.latitude) / 2,
            longitude: (bbox.southwest.longitude + bbox.northeast.longitude) / 2
        ),
        span: MKCoordinateSpan(
            latitudeDelta: bbox.northeast.latitude - bbox.southwest.latitude,
            longitudeDelta: bbox.northeast.longitude - bbox.southwest.longitude
        )
    )
    mapView.setRegion(region, animated: true)
}
```

### With MapLibre

```swift
import MapLibre

let route = try await router.calculateRoute(from: start, to: end, profile: .car)

// Option A: Simple polyline
let source = MLNShapeSource(
    identifier: "route",
    shape: MLNPolyline(coordinates: route.coordinates, count: UInt(route.waypointCount)),
    options: nil
)
mapView.style?.addSource(source)

let layer = MLNLineStyleLayer(identifier: "route-layer", source: source)
layer.lineColor = NSExpression(forConstantValue: UIColor.systemBlue)
layer.lineWidth = NSExpression(forConstantValue: 5)
layer.lineCap = NSExpression(forConstantValue: "round")
layer.lineJoin = NSExpression(forConstantValue: "round")
mapView.style?.addLayer(layer)

// Option B: Use convenience extension (if you imported MapLibreIntegration)
guard let style = mapView.style else { return }
route.addToMapStyle(style, color: .systemBlue, width: 5)

// Option C: Route with casing (outline)
route.addToMapStyleWithCasing(
    style,
    lineColor: .systemBlue,
    lineWidth: 5,
    casingColor: .white,
    casingWidth: 7
)

// Fit camera to route
mapView.showRoute(route, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50))
```

## ⚙️ Advanced Usage

### Custom Options

```swift
var options = LoxxRouterOptions()
options.tileZoom = 15           // Higher zoom = more detailed tiles
options.tileCacheCapacity = 256 // More cached tiles (uses more memory)

let router = try LoxxRouter.bundled(resourceName: "routing", options: options)
```

### Error Handling

```swift
do {
    let route = try await router.calculateRoute(from: start, to: end, profile: .car)
    // Success
} catch LoxxRouterError.databaseNotFound {
    print("Database file not found")
} catch LoxxRouterError.noRoute {
    print("No route found between these points")
} catch LoxxRouterError.noTileData {
    print("No map data available for this region")
} catch {
    print("Routing error: \(error)")
}
```

## 🏗️ Architecture

```
┌─────────────────────────────────────┐
│   Swift Application Code            │
└─────────────────┬───────────────────┘
                  │
┌─────────────────▼───────────────────┐
│   LoxxRouter (Pure Swift API)       │
│   - Public interface                │
│   - Type-safe Swift types           │
│   - Async/await support             │
└─────────────────┬───────────────────┘
                  │
┌─────────────────▼───────────────────┐
│   LoxxRouterBridge (Objective-C++)  │
│   - Bridges Swift ↔ C++            │
│   - Embedded in XCFramework         │
└─────────────────┬───────────────────┘
                  │
┌─────────────────▼───────────────────┐
│   LoxxRouterCore (C++ Engine)       │
│   - High-performance routing        │
│   - OpenStreetMap data processing   │
│   - Binary XCFramework              │
└─────────────────────────────────────┘
```

## 📄 License

MIT License. See [LICENSE](LICENSE) for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 🔗 Related Projects

- [loxx-core](https://github.com/ilisun/loxx-core) - C++ routing engine and converter tools
- [loxx-app-ios](https://github.com/ilisun/loxx-app-ios) - Example iOS application

## 📮 Support

For issues, questions, or suggestions, please [open an issue](https://github.com/ilisun/loxx-router-ios/issues) on GitHub.
