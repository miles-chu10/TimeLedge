import ServiceManagement

enum LoginItemController {
  static var isEnabledOrAwaitingApproval: Bool {
    let status = SMAppService.mainApp.status
    return status == .enabled || status == .requiresApproval
  }

  static var requiresApproval: Bool {
    SMAppService.mainApp.status == .requiresApproval
  }

  static func setEnabled(_ enabled: Bool) throws {
    let service = SMAppService.mainApp
    if enabled {
      if service.status != .enabled && service.status != .requiresApproval {
        try service.register()
      }
    } else if service.status == .enabled || service.status == .requiresApproval {
      try service.unregister()
    }
  }
}
