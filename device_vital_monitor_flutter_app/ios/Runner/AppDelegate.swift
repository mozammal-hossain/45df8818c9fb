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
    let channel = FlutterMethodChannel(
      name: "device_vital_monitor/sensors",
      binaryMessenger: controller.binaryMessenger
    )
    channel.setMethodCallHandler { [weak self] call, result in
      switch call.method {
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
