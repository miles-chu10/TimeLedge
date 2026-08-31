import SwiftUI
import TimeLedgeCore

enum SettingsSection: String, CaseIterable, Identifiable {
  case format = "Format"
  case style = "Style"
  case general = "General"

  var id: String { rawValue }
}

struct SettingsView: View {
  @ObservedObject var store: PreferencesStore
  let onSetLaunchAtLogin: (Bool) -> Void
  let onRefreshDisplays: () -> Void

  @State private var selectedSection: SettingsSection

  init(
    store: PreferencesStore,
    onSetLaunchAtLogin: @escaping (Bool) -> Void,
    onRefreshDisplays: @escaping () -> Void,
    initialSection: SettingsSection = .format
  ) {
    self.store = store
    self.onSetLaunchAtLogin = onSetLaunchAtLogin
    self.onRefreshDisplays = onRefreshDisplays
    _selectedSection = State(initialValue: initialSection)
  }

  var body: some View {
    VStack(spacing: 0) {
      header
      preview
        .padding(.horizontal, 20)
        .padding(.bottom, 16)

      Picker("Settings section", selection: $selectedSection) {
        ForEach(SettingsSection.allCases) { section in
          Text(section.rawValue).tag(section)
        }
      }
      .pickerStyle(.segmented)
      .labelsHidden()
      .padding(.horizontal, 20)
      .padding(.bottom, 14)

      Divider()

      ScrollView {
        Group {
          switch selectedSection {
          case .format:
            formatSettings
          case .style:
            styleSettings
          case .general:
            generalSettings
          }
        }
        .padding(20)
      }

      Divider()
      HStack {
        Label("No permissions, network, or analytics", systemImage: "hand.raised")
          .font(.caption)
          .foregroundColor(.secondary)
        Spacer()
        Button("Reset Format & Style") {
          store.resetAppearanceAndFormat()
        }
      }
      .padding(14)
    }
    .frame(width: 520, height: 680)
    .background(Color(nsColor: .windowBackgroundColor))
  }

  private var header: some View {
    HStack(spacing: 12) {
      Image(systemName: "clock.badge.checkmark")
        .font(.system(size: 28))
        .foregroundColor(.accentColor)
      VStack(alignment: .leading, spacing: 2) {
        Text("TimeLedge")
          .font(.title2.weight(.semibold))
        Text("A quiet clock for fullscreen focus")
          .foregroundColor(.secondary)
      }
      Spacer()
    }
    .padding(20)
  }

  private var preview: some View {
    TimelineView(
      .periodic(from: Date(), by: ClockFormatter.updateInterval(preferences: store.preferences))
    ) { context in
      let text = ClockFormatter.string(from: context.date, preferences: store.preferences)
      ZStack(alignment: .topTrailing) {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
          .fill(
            LinearGradient(
              colors: [
                Color.accentColor.opacity(0.5),
                Color(nsColor: .controlBackgroundColor),
              ],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            )
          )

        Text(text)
          .font(
            .system(
              size: CGFloat(store.preferences.fontSize),
              weight: store.preferences.fontWeight.swiftUIWeight,
              design: store.preferences.fontFamily.design
            )
          )
          .monospacedDigit()
          .foregroundColor(store.preferences.textColor.color)
          .opacity(store.preferences.textOpacity)
          .padding(.horizontal, 8)
          .padding(.vertical, 4)
          .background(
            RoundedRectangle(cornerRadius: 7, style: .continuous)
              .fill(
                Color.black.opacity(
                  previewShowsBackground ? store.preferences.backgroundOpacity : 0))
          )
          .padding(10)
      }
      .frame(height: 116)
      .accessibilityLabel(Text("Clock preview: \(text)"))
    }
  }

  private var previewShowsBackground: Bool {
    guard let display = store.displays.first(where: { $0.isBuiltIn }) ?? store.displays.first else {
      return false
    }
    return store.preference(for: display.id).showsBackground
  }

  private var formatSettings: some View {
    VStack(alignment: .leading, spacing: 14) {
      Toggle("Use 24-hour format", isOn: $store.preferences.use24HourFormat)
      Toggle("Display seconds", isOn: $store.preferences.showSeconds)
      Toggle("Show date", isOn: $store.preferences.showDate)
      Toggle("Show day of the week", isOn: $store.preferences.showWeekday)
      Divider()
      Toggle("Custom format", isOn: $store.preferences.customFormatEnabled)
      TextField("DateFormatter pattern", text: $store.preferences.customFormat)
        .textFieldStyle(.roundedBorder)
        .disabled(!store.preferences.customFormatEnabled)
        .onChange(of: store.preferences.customFormat) { value in
          if value.count > 128 {
            store.preferences.customFormat = String(value.prefix(128))
          }
        }
      Text("Uses Apple DateFormatter patterns and your current locale and time zone.")
        .font(.caption)
        .foregroundColor(.secondary)
      Text("Custom patterns are limited to 128 characters.")
        .font(.caption)
        .foregroundColor(.secondary)
    }
  }

  private var styleSettings: some View {
    VStack(alignment: .leading, spacing: 16) {
      settingRow("Font family") {
        Picker("Font family", selection: $store.preferences.fontFamily) {
          ForEach(ClockFontFamily.allCases) { family in
            Text(family.title).tag(family)
          }
        }
        .labelsHidden()
        .frame(width: 150)
      }

      settingRow("Font weight") {
        Picker("Font weight", selection: $store.preferences.fontWeight) {
          ForEach(ClockFontWeight.allCases) { weight in
            Text(weight.title).tag(weight)
          }
        }
        .labelsHidden()
        .frame(width: 150)
      }

      settingRow("Font size") {
        HStack {
          Slider(value: $store.preferences.fontSize, in: 10...28, step: 1)
            .frame(width: 130)
          Text("\(Int(store.preferences.fontSize)) px")
            .monospacedDigit()
            .frame(width: 42, alignment: .trailing)
        }
      }

      settingRow("Font color") {
        Picker("Font color", selection: $store.preferences.textColor) {
          ForEach(ClockTextColor.allCases) { color in
            Text(color.title).tag(color)
          }
        }
        .labelsHidden()
        .frame(width: 150)
      }

      settingRow("Font opacity") {
        HStack {
          Slider(value: $store.preferences.textOpacity, in: 0.25...1, step: 0.05)
            .frame(width: 130)
          Text("\(Int(store.preferences.textOpacity * 100))%")
            .monospacedDigit()
            .frame(width: 42, alignment: .trailing)
        }
      }

      settingRow("Background opacity") {
        HStack {
          Slider(value: $store.preferences.backgroundOpacity, in: 0.15...0.9, step: 0.05)
            .frame(width: 130)
          Text("\(Int(store.preferences.backgroundOpacity * 100))%")
            .monospacedDigit()
            .frame(width: 42, alignment: .trailing)
        }
      }

      settingRow("Right margin") {
        Picker("Right margin", selection: $store.preferences.rightMargin) {
          ForEach(ClockRightMargin.allCases) { margin in
            Text(margin.title).tag(margin)
          }
        }
        .labelsHidden()
        .frame(width: 150)
      }

      Text("Wide margin leaves extra room for the camera and microphone privacy indicator.")
        .font(.caption)
        .foregroundColor(.secondary)
    }
  }

  private var generalSettings: some View {
    VStack(alignment: .leading, spacing: 16) {
      Toggle("Show clock", isOn: $store.preferences.isClockVisible)

      settingRow("Visibility") {
        Picker("Visibility", selection: $store.visibilityMode) {
          ForEach(ClockVisibilityMode.allCases) { mode in
            Text(mode.title).tag(mode)
          }
        }
        .labelsHidden()
        .frame(width: 180)
      }

      Text(store.visibilityMode.detail)
        .font(.caption)
        .foregroundColor(.secondary)

      settingRow("Window level") {
        Picker("Window level", selection: $store.preferences.windowLayer) {
          ForEach(ClockWindowLayer.allCases) { layer in
            Text(layer.title).tag(layer)
          }
        }
        .labelsHidden()
        .frame(width: 150)
      }

      Text("Use Over Apps to keep the clock visible in fullscreen Spaces.")
        .font(.caption)
        .foregroundColor(.secondary)

      Divider()

      HStack {
        Text("Displays")
          .font(.headline)
        Spacer()
        Button("Refresh") {
          onRefreshDisplays()
        }
      }

      if store.displays.isEmpty {
        Text("No active displays found.")
          .foregroundColor(.secondary)
      } else {
        ForEach(store.displays) { display in
          VStack(alignment: .leading, spacing: 8) {
            HStack {
              Label(
                display.localizedName,
                systemImage: display.isBuiltIn ? "laptopcomputer" : "display"
              )
              Spacer()
              Toggle(
                "Enable \(display.localizedName)",
                isOn: displayEnabledBinding(display.id)
              )
              .labelsHidden()
            }

            Toggle(
              "Readable background",
              isOn: displayBackgroundBinding(display.id)
            )
            .disabled(!store.preference(for: display.id).isEnabled)
          }
          .padding(10)
          .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
              .fill(Color(nsColor: .controlBackgroundColor))
          )
        }
      }

      Divider()

      Toggle(
        "Launch at login",
        isOn: Binding(
          get: { store.preferences.launchAtLogin },
          set: { onSetLaunchAtLogin($0) }
        )
      )

      if let error = store.loginItemError {
        Text(error)
          .font(.caption)
          .foregroundColor(.orange)
      }
    }
  }

  private func displayEnabledBinding(_ displayID: String) -> Binding<Bool> {
    Binding(
      get: { store.preference(for: displayID).isEnabled },
      set: { store.setDisplayEnabled($0, displayID: displayID) }
    )
  }

  private func displayBackgroundBinding(_ displayID: String) -> Binding<Bool> {
    Binding(
      get: { store.preference(for: displayID).showsBackground },
      set: { store.setDisplayBackground($0, displayID: displayID) }
    )
  }

  private func settingRow<Content: View>(
    _ title: String,
    @ViewBuilder content: () -> Content
  ) -> some View {
    HStack {
      Text(title)
      Spacer()
      content()
    }
  }
}
