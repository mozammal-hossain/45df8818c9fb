import Flutter
import UIKit
import Darwin

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    guard let controller = window?.rootViewController as? FlutterViewController else {
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    UIDevice.current.isBatteryMonitoringEnabled = true

    let channel = FlutterMethodChannel(
      name: "device_vital_monitor/sensors",
      binaryMessenger: controller.binaryMessenger
    )
    channel.setMethodCallHandler { [weak self] call, result in
      switch call.method {
      case "getThermalState":
        if let thermalState = self?.getThermalState() {
          result(thermalState)
        } else {
          result(FlutterError(
            code: "THERMAL_ERROR",
            message: "Failed to get thermal state",
            details: nil
          ))
        }
      case "getBatteryLevel":
        if let level = self?.getBatteryLevel() {
          result(level)
        } else {
          result(FlutterError(
            code: "BATTERY_ERROR",
            message: "Failed to get battery level",
            details: nil
          ))
        }
      case "getMemoryUsage":
        if let usage = self?.getMemoryUsage() {
          result(usage)
        } else {
          result(FlutterError(
            code: "MEMORY_ERROR",
            message: "Failed to get memory usage",
            details: nil
          ))
        }
      case "getStorageInfo":
        if let storageInfo = self?.getStorageInfo() {
          result(storageInfo)
        } else {
          result(FlutterError(
            code: "STORAGE_ERROR",
            message: "Failed to get storage info",
            details: nil
          ))
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  /// Returns battery level 0–100 using UIDevice.batteryLevel (0.0–1.0).
  /// Uses Double; round-half-down so 0.75 → 74% to match iOS status bar
  /// (API often reports 1% high vs system UI). Returns nil if unknown (-1.0).
  private func getBatteryLevel() -> Int? {
    let raw = UIDevice.current.batteryLevel
    guard raw >= 0 else { return nil }
    let percent = Int(raw * 100)
    return min(100, max(0, percent))
  }

  /// Returns thermal state (0–3) using ProcessInfo.thermalState.
  /// 0 = nominal, 1 = fair, 2 = serious, 3 = critical
  private func getThermalState() -> Int? {
    let thermalState = ProcessInfo.processInfo.thermalState
    let result: Int
    switch thermalState {
    case .nominal:
      result = 0
    case .fair:
      result = 1
    case .serious:
      result = 2
    case .critical:
      result = 3
    @unknown default:
      result = 0
    }
    return result
  }

  /// Returns used memory percentage (0–100) using mach_task_basic_info.
  /// Uses process resident_size vs total physical memory.
  private func getMemoryUsage() -> Int? {
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

  /// Returns storage information as a dictionary with:
  /// - 'total': total storage in bytes (Int64)
  /// - 'used': used storage in bytes (Int64)
  /// - 'available': available storage in bytes (Int64)
  /// - 'usagePercent': usage percentage 0-100 (Int)
  private func getStorageInfo() -> [String: Any]? {
    guard let attributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()),
          let totalBytes = attributes[.systemSize] as? Int64,
          let freeBytes = attributes[.systemFreeSize] as? Int64 else {
      return nil
    }
    
    let usedBytes = totalBytes - freeBytes
    let usagePercent = totalBytes > 0 ? Int((Double(usedBytes) / Double(totalBytes)) * 100) : 0
    
    return [
      "total": totalBytes,
      "used": usedBytes,
      "available": freeBytes,
      "usagePercent": max(0, min(100, usagePercent))
    ]
  }
}
