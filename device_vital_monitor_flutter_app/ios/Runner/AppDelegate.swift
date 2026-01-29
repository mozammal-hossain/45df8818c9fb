import Flutter
import UIKit
import Darwin
import BackgroundTasks

private let kAutoLoggingPrefs = "device_vital_monitor_auto_log"
private let kBaseURLKey = "base_url"
private let kDeviceIdKey = "device_id"
private let kVitalsLogTaskId = "com.example.device_vital_monitor_flutter_app.vitalsLog"

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    UIDevice.current.isBatteryMonitoringEnabled = true

    registerBackgroundTask()
    setupChannels(application: application)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func setupChannels(application: UIApplication) {
    guard let controller = window?.rootViewController as? FlutterViewController else { return }

    let sensorsChannel = FlutterMethodChannel(
      name: "device_vital_monitor/sensors",
      binaryMessenger: controller.binaryMessenger
    )
    sensorsChannel.setMethodCallHandler { [weak self] call, result in
      switch call.method {
      case "getThermalState":
        result(VitalsLogHelper.getThermalState())
      case "getBatteryLevel":
        if let level = VitalsLogHelper.getBatteryLevel() {
          result(level)
        } else {
          result(FlutterError(code: "BATTERY_ERROR", message: "Failed to get battery level", details: nil))
        }
      case "getMemoryUsage":
        if let usage = VitalsLogHelper.getMemoryUsage() {
          result(usage)
        } else {
          result(FlutterError(code: "MEMORY_ERROR", message: "Failed to get memory usage", details: nil))
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    let autoLoggingChannel = FlutterMethodChannel(
      name: "device_vital_monitor/auto_logging",
      binaryMessenger: controller.binaryMessenger
    )
    autoLoggingChannel.setMethodCallHandler { [weak self] call, result in
      switch call.method {
      case "scheduleBackgroundAutoLog":
        guard let args = call.arguments as? [String: Any],
              let baseUrl = args["baseUrl"] as? String, !baseUrl.isEmpty,
              let deviceId = args["deviceId"] as? String, !deviceId.isEmpty else {
          result(FlutterError(code: "INVALID_ARGS", message: "baseUrl and deviceId required", details: nil))
          return
        }
        let base = baseUrl.hasSuffix("/") ? String(baseUrl.dropLast()) : baseUrl
        UserDefaults.standard.set(base, forKey: "\(kAutoLoggingPrefs)_\(kBaseURLKey)")
        UserDefaults.standard.set(deviceId, forKey: "\(kAutoLoggingPrefs)_\(kDeviceIdKey)")
        self?.submitVitalsLogTask()
        result(nil)
      case "cancelBackgroundAutoLog":
        UserDefaults.standard.removeObject(forKey: "\(kAutoLoggingPrefs)_\(kBaseURLKey)")
        UserDefaults.standard.removeObject(forKey: "\(kAutoLoggingPrefs)_\(kDeviceIdKey)")
        BGTaskScheduler.shared.cancel(taskWithIdentifier: kVitalsLogTaskId)
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private func registerBackgroundTask() {
    BGTaskScheduler.shared.register(forTaskWithIdentifier: kVitalsLogTaskId, using: nil) { [weak self] task in
      self?.handleVitalsLogTask(task as! BGAppRefreshTask)
    }
  }

  private func submitVitalsLogTask() {
    let request = BGAppRefreshTaskRequest(identifier: kVitalsLogTaskId)
    request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
    do {
      try BGTaskScheduler.shared.submit(request)
    } catch {
    }
  }

  private func handleVitalsLogTask(_ task: BGAppRefreshTask) {
    task.expirationHandler = {
      task.setTaskCompleted(success: false)
    }

    guard let baseUrl = UserDefaults.standard.string(forKey: "\(kAutoLoggingPrefs)_\(kBaseURLKey)"),
          let deviceId = UserDefaults.standard.string(forKey: "\(kAutoLoggingPrefs)_\(kDeviceIdKey)") else {
      task.setTaskCompleted(success: true)
      return
    }

    let fullBase = baseUrl.hasSuffix("/") ? baseUrl : "\(baseUrl)/"
    let ok = VitalsLogHelper.postVitals(baseURL: fullBase, deviceId: deviceId)
    task.setTaskCompleted(success: ok)
    submitVitalsLogTask()
  }
}
