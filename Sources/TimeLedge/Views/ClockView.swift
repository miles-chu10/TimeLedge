import SwiftUI
import TimeLedgeCore

struct ClockView: View {
  @ObservedObject var store: PreferencesStore
  let displayID: String
  let maximumWidth: CGFloat
  let onSizeChange: (CGSize) -> Void

  var body: some View {
    let preferences = store.preferences
    let showsBackground = store.preference(for: displayID).showsBackground
    let interval = ClockFormatter.updateInterval(preferences: preferences)

    TimelineView(.periodic(from: Date(), by: interval)) { context in
      let text = ClockFormatter.string(from: context.date, preferences: preferences)
      Text(text)
        .font(
          .system(
            size: CGFloat(preferences.fontSize),
            weight: preferences.fontWeight.swiftUIWeight,
            design: preferences.fontFamily.design
          )
        )
        .monospacedDigit()
        .foregroundColor(preferences.textColor.color)
        .opacity(preferences.textOpacity)
        .lineLimit(1)
        .minimumScaleFactor(0.5)
        .frame(maxWidth: maximumWidth, alignment: .trailing)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, showsBackground ? 8 : 0)
        .padding(.vertical, showsBackground ? 4 : 0)
        .background(
          RoundedRectangle(cornerRadius: 7, style: .continuous)
            .fill(Color.black.opacity(showsBackground ? preferences.backgroundOpacity : 0))
        )
        .accessibilityLabel(Text("Current time \(text)"))
        .background(
          GeometryReader { proxy in
            Color.clear
              .onAppear { onSizeChange(proxy.size) }
              .onChange(of: proxy.size) { onSizeChange($0) }
          }
        )
    }
    .fixedSize(horizontal: false, vertical: true)
  }
}
