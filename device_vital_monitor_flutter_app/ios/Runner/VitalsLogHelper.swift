import Foundation
import UIKit
import Darwin

/// Helper used by AppDelegate (MethodChannel) and BGTask (background vitals log).
enum VitalsLogHelper {
  static func getThermalState() -> Int {
    let thermalState = ProcessInfo.processInfo.thermalState
    switch thermalState {
    case .nominal: return 0
    case .fair: return 1
    case .serious: return 2
    case .critical: return 3
    @unknown default: return 0
    }
  }

  static func getBatteryLevel() -> Int? {
    UIDevice.current.isBatteryMonitoringEnabled = true
    let raw = UIDevice.current.batteryLevel
    guard raw >= 0 else { return nil }
    let percent = Int(raw * 100)
    return min(100, max(0, percent))
  }

  static func getMemoryUsage() -> Int? {
    var info = mach_task_basic_info()
    var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size / MemoryLayout<natural_t>.size)
    let kerr = withUnsafeMutablePointer(to: &info) { infoPtr in
      infoPtr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { machPtr in
        task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), machPtr, &count)
      }
    }
    guard kerr == KERN_SUCCESS else { return nil }
    let used = info.resident_size
    let total = ProcessInfo.processInfo.physicalMemory
    guard total > 0 else { return 0 }
    let percent = Int((Double(used) / Double(total)) * 100)
    return min(100, max(0, percent))
  }

  /// POST vitals to backend. Returns true on success.
  static func postVitals(baseURL: String, deviceId: String) -> Bool {
    let thermal = getThermalState()
    guard let battery = getBatteryLevel() else { return false }
    guard let memory = getMemoryUsage() else { return false }

    let iso8601 = ISO8601DateFormatter()
    iso8601.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    let timestamp = iso8601.string(from: Date())

    let body: [String: Any] = [
      "device_id": deviceId,
      "timestamp": timestamp,
      "thermal_value": thermal,
      "battery_level": battery,
      "memory_usage": memory,
    ]
    guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else { return false }

    let urlString = baseURL.hasSuffix("/") ? "\(baseURL)api/vitals" : "\(baseURL)/api/vitals"
    guard let url = URL(string: urlString) else { return false }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = jsonData
    request.timeoutInterval = 10

    var success = false
    let sem = DispatchSemaphore(value: 0)
    URLSession.shared.dataTask(with: request) { _, response, _ in
      if let http = response as? HTTPURLResponse, (200..<400).contains(http.statusCode) {
        success = true
      }
      sem.signal()
    }.resume()
    sem.wait()
    return success
  }
}
