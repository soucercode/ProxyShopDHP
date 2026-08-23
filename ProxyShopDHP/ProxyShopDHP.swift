import SwiftUI
import UIKit

// MARK: - App

@main
struct ProxyShopDHPApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }
}

// MARK: - Models / Store

enum Game: String, Identifiable {
    case freeFireMax
    case freeFire

    var id: String { rawValue }

    var title: String {
        switch self {
        case .freeFireMax: return "Free Fire Max"
        case .freeFire: return "Free Fire"
        }
    }

    var bundleID: String {
        switch self {
        case .freeFireMax: return "com.dts.freefiremax"
        case .freeFire: return "com.dts.freefireth"
        }
    }

    var tint: Color {
        switch self {
        case .freeFireMax: return .blue
        case .freeFire: return .orange
        }
    }
}

enum GameTab: String, CaseIterable, Identifiable {
    case proxy, location, mod

    var id: String { rawValue }

    var title: String {
        switch self {
        case .proxy: return "Proxy"
        case .location: return "Định Vị"
        case .mod: return "Mod NV"
        }
    }

    var icon: String {
        switch self {
        case .proxy: return "bolt.fill"
        case .location: return "location.fill"
        case .mod: return "person.fill"
        }
    }

    var color: Color {
        switch self {
        case .proxy: return .cyan
        case .location: return .green
        case .mod: return .purple
        }
    }
}

struct DHPFeature: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let tint: Color
    var enabled: Bool = false
}

@MainActor
final class AppStore: ObservableObject {
    @Published var selectedGame: Game?
    @Published var activeTab: GameTab = .proxy

    @Published var showLicense = false
    @Published var showSettings = false
    @Published var showInfo = false
    @Published var key = ""

    @Published var daysLeft = 20
    @Published var hoursLeft = 11

    @Published var proxy: [DHPFeature] = [
        .init(title: "Proxy Body", subtitle: "Full giao diện tùy chỉnh", icon: "person.fill", tint: .orange),
        .init(title: "Proxy Cổ V1", subtitle: "Tùy chọn V1", icon: "scope", tint: .yellow),
        .init(title: "Proxy Cổ V2", subtitle: "Tùy chọn V2", icon: "target", tint: .pink),
        .init(title: "Proxy Magic", subtitle: "Tùy chọn Magic", icon: "wand.and.stars", tint: .purple)
    ]

    @Published var location: [DHPFeature] = [
        .init(title: "Định Vị Súng Xanh", subtitle: "Hiển thị vị trí trên bản đồ", icon: "location.fill", tint: .cyan),
        .init(title: "Định Vị Súng Đỏ", subtitle: "Hiển thị vị trí trên bản đồ", icon: "scope", tint: .red),
        .init(title: "Định Vị Xanh Lá", subtitle: "Hiển thị vị trí trên bản đồ", icon: "location.fill", tint: .green)
    ]

    @Published var mods: [DHPFeature] = [
        .init(title: "Mod Skin Maro", subtitle: "Maro / One Punch Man", icon: "person.crop.circle.fill", tint: .orange),
        .init(title: "Mod Skin Alok V1", subtitle: "Mod Skin Alok", icon: "crown.fill", tint: .purple),
        .init(title: "Mod Skin Alok V2", subtitle: "Free Fire thường", icon: "crown.fill", tint: .cyan),
        .init(title: "Mod Skin Alok V3", subtitle: "Free Fire thường", icon: "crown.fill", tint: .pink),
        .init(title: "Mod Skin Alok V4", subtitle: "Free Fire thường", icon: "crown.fill", tint: .orange),
        .init(title: "Mod Skin Alok V5", subtitle: "Free Fire thường", icon: "crown.fill", tint: .green),
        .init(title: "Mod Skin Alok V6", subtitle: "Free Fire thường", icon: "crown.fill", tint: .red),
        .init(title: "Mod Skin Alok V7", subtitle: "Free Fire thường", icon: "crown.fill", tint: .gray)
    ]

    let device = DeviceInfo.current

    func list(for tab: GameTab) -> [DHPFeature] {
        switch tab {
        case .proxy: proxy
        case .location: location
        case .mod: mods
        }
    }

    func toggle(featureID: UUID, tab: GameTab) {
        func update(_ input: [DHPFeature]) -> [DHPFeature] {
            input.map { item in
                guard item.id == featureID else { return item }
                var copy = item
                copy.enabled.toggle()
                return copy
            }
        }

        switch tab {
        case .proxy: proxy = update(proxy)
        case .location: location = update(location)
        case .mod: mods = update(mods)
        }
    }

    func activateKey() {
        let cleaned = key.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return }
        daysLeft = 30
        hoursLeft = 0
        showLicense = false
    }

    func copyUID() {
        UIPasteboard.general.string = device.vendorID
    }
}

// MARK: - Device

struct DeviceInfo {
    let iosVersion: String
    let model: String
    let vendorID: String
    let supported: Bool

    static var current: DeviceInfo {
        let ios = UIDevice.current.systemVersion
        let vendor = UIDevice.current.identifierForVendor?.uuidString ?? "Unavailable"
        let rawModel = modelIdentifier()

        let modelMap = [
            "iPhone10,2": "iPhone 8 Plus",
            "iPhone12,3": "iPhone 11 Pro",
            "iPhone12,5": "iPhone 11 Pro Max",
            "iPhone14,2": "iPhone 13 Pro",
            "iPhone14,3": "iPhone 13 Pro Max",
            "iPhone15,2": "iPhone 14 Pro",
            "iPhone15,3": "iPhone 14 Pro Max",
            "iPhone16,1": "iPhone 15 Pro",
            "iPhone16,2": "iPhone 15 Pro Max"
        ]

        let major = Int(ios.split(separator: ".").first ?? "0") ?? 0

        return DeviceInfo(
            iosVersion: ios,
            model: modelMap[rawModel] ?? rawModel,
            vendorID: vendor,
            supported: major >= 16
        )
    }

    private static func modelIdentifier() -> String {
        var info = utsname()
        uname(&info)
        return withUnsafeBytes(of: &info.machine) {
            String(bytes: $0, encoding: .ascii)?
                .trimmingCharacters(in: .controlCharacters.union(.whitespacesAndNewlines))
                ?? "Unknown"
        }
    }
}

// MARK: - Theme

struct DHPBackground: View {
    var body: some View {
        ZStack {
            Color(red: 0.025, green: 0.028, blue: 0.07).ignoresSafeArea()

            RadialGradient(
                colors: [.purple.opacity(0.24), .clear],
                center: .topLeading,
                startRadius: 0,
                endRadius: 520
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [.cyan.opacity(0.12), .clear],
                center: .bottomTrailing,
                startRadius: 0,
                endRadius: 600
            )
            .ignoresSafeArea()

            Canvas { context, size in
                var path = Path()
                let step: CGFloat = 30

                stride(from: 0, through: size.width, by: step).forEach {
                    path.move(to: CGPoint(x: $0, y: 0))
                    path.addLine(to: CGPoint(x: $0, y: size.height))
                }

                stride(from: 0, through: size.height, by: step).forEach {
                    path.move(to: CGPoint(x: 0, y: $0))
                    path.addLine(to: CGPoint(x: size.width, y: $0))
                }

                context.stroke(path, with: .color(.white.opacity(0.022)), lineWidth: 0.65)
            }
            .ignoresSafeArea()
        }
    }
}

struct GlassCard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(18)
            .background(.regularMaterial.opacity(0.34), in: RoundedRectangle(cornerRadius: 28))
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(.white.opacity(0.12), lineWidth: 1)
            )
    }
}

// MARK: - Home

struct HomeView: View {
    @StateObject private var store = AppStore()

    var body: some View {
        NavigationStack {
            ZStack {
                DHPBackground()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        homeHeader
                        deviceCard
                        gameCards
                        Color.clear.frame(height: 115)
                    }
                    .padding(.horizontal, 28)
                    .padding(.top, 10)
                }

                VStack {
                    Spacer()
                    licenseDock
                        .padding(.horizontal, 28)
                        .padding(.bottom, 18)
                }
            }
            .sheet(isPresented: $store.showLicense) {
                LicenseSheet()
                    .environmentObject(store)
            }
            .sheet(isPresented: $store.showSettings) {
                SettingsSheet()
                    .environmentObject(store)
            }
            .sheet(isPresented: $store.showInfo) {
                AboutSheet()
            }
            .navigationDestination(item: $store.selectedGame) { game in
                GameFunctionsView(game: game)
                    .environmentObject(store)
            }
            .preferredColorScheme(.dark)
        }
    }

    private var homeHeader: some View {
        HStack(spacing: 10) {
            Spacer()

            HStack(spacing: 7) {
                Text("PROXY SHOP DHP")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .cyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                Text("V1.0.0")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.cyan)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.cyan.opacity(0.08), in: Capsule())
                    .overlay(Capsule().stroke(.cyan.opacity(0.65), lineWidth: 1))
            }

            Spacer()

            Button {
                store.showSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 19, weight: .semibold))
                    .frame(width: 56, height: 56)
                    .background(.white.opacity(0.07), in: Circle())
                    .overlay(Circle().stroke(.white.opacity(0.14), lineWidth: 1))
            }
            .foregroundStyle(.white)
        }
    }

    private var deviceCard: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    Image(systemName: "apple.logo")
                        .frame(width: 25)
                    Text("iOS")
                        .foregroundStyle(.white.opacity(0.52))
                    Text(store.device.iosVersion)
                        .fontWeight(.medium)
                    Spacer()
                }

                HStack(spacing: 12) {
                    Image(systemName: "iphone")
                        .foregroundStyle(.cyan)
                        .frame(width: 25)
                    Text("Device")
                        .foregroundStyle(.white.opacity(0.52))
                    Text(store.device.model)
                        .fontWeight(.medium)
                    Spacer()
                }

                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(.green.opacity(0.18))
                            .frame(width: 44, height: 44)
                        Circle()
                            .fill(.green)
                            .frame(width: 12, height: 12)
                            .shadow(color: .green, radius: 10)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(store.device.supported ? "Có Hỗ Trợ" : "Không Hỗ Trợ")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(store.device.supported ? .green : .red)

                        HStack(spacing: 6) {
                            Text("UID")
                                .foregroundStyle(.white.opacity(0.45))
                            Text(compactUID(store.device.vendorID))
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundStyle(.white.opacity(0.46))
                        }
                    }

                    Spacer()

                    Button {
                        store.copyUID()
                    } label: {
                        Image(systemName: "doc.on.doc.fill")
                            .font(.system(size: 15, weight: .semibold))
                            .frame(width: 40, height: 40)
                            .background(.cyan.opacity(0.10), in: RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(.cyan.opacity(0.45), lineWidth: 1))
                    }
                    .foregroundStyle(.cyan)
                }
            }
        }
    }

    private var gameCards: some View {
        HStack(spacing: 18) {
            HomeGameCard(game: .freeFireMax) {
                store.selectedGame = .freeFireMax
            }

            HomeGameCard(game: .freeFire) {
                store.selectedGame = .freeFire
            }
        }
    }

    private var licenseDock: some View {
        GlassCard {
            HStack(spacing: 12) {
                Circle()
                    .fill(.green)
                    .frame(width: 10, height: 10)
                    .shadow(color: .green, radius: 10)

                VStack(alignment: .leading, spacing: 4) {
                    Text("KEY NDPX••••D67D")
                        .font(.system(size: 15, weight: .bold))
                    Text("Còn \(store.daysLeft) ngày \(store.hoursLeft) giờ")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.green)
                }

                Spacer()

                Button {
                    store.copyUID()
                } label: {
                    Image(systemName: "doc.on.doc.fill")
                        .frame(width: 42, height: 42)
                        .background(.cyan.opacity(0.11), in: RoundedRectangle(cornerRadius: 13))
                }
                .foregroundStyle(.cyan)

                Button {
                    store.showLicense = true
                } label: {
                    Text("Đổi Key")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 17)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                colors: [.purple, .cyan],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            in: Capsule()
                        )
                }
            }
        }
    }

    private func compactUID(_ id: String) -> String {
        guard id.count > 12 else { return id }
        return "\(id.prefix(6))••••\(id.suffix(6))"
    }
}

struct HomeGameCard: View {
    let game: Game
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                ZStack {
                    game.tint.opacity(0.92)

                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundStyle(.white)
                }
                .frame(height: 165)

                VStack(alignment: .leading, spacing: 10) {
                    Text(game.title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)

                    Text(game.bundleID)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.42))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .frame(height: 140)
                .background(.black.opacity(0.26))
            }
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(game.tint.opacity(0.72), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Game Functions

struct GameFunctionsView: View {
    let game: Game

    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            DHPBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    navHeader

                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 52, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.purple, .cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 104, height: 104)
                        .background(.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 25))
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(.cyan.opacity(0.18), lineWidth: 1)
                        )

                    Text(game.title)
                        .font(.system(size: 27, weight: .bold))

                    Text(game.bundleID)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.42))

                    tabBar
                    featureSection

                    Button {
                        openGame()
                    } label: {
                        Label("MỞ GAME", systemImage: "play.fill")
                            .font(.system(size: 19, weight: .bold))
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                LinearGradient(
                                    colors: [.purple, .cyan],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                in: RoundedRectangle(cornerRadius: 22)
                            )
                    }
                }
                .padding(.horizontal, 28)
                .padding(.top, 12)
                .padding(.bottom, 28)
            }
        }
        .navigationBarBackButtonHidden()
        .preferredColorScheme(.dark)
    }

    private var navHeader: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 19, weight: .bold))
                    .frame(width: 52, height: 52)
                    .background(.white.opacity(0.07), in: Circle())
                    .overlay(Circle().stroke(.white.opacity(0.13), lineWidth: 1))
            }
            .foregroundStyle(.white)

            Spacer()

            Text(game.title)
                .font(.system(size: 20, weight: .bold))

            Spacer()

            Color.clear.frame(width: 52, height: 52)
        }
    }

    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(GameTab.allCases) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.18)) {
                        store.activeTab = tab
                    }
                } label: {
                    VStack(spacing: 7) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 16, weight: .semibold))
                        Text(tab.title)
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .foregroundStyle(store.activeTab == tab ? tab.color : .white.opacity(0.46))
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(store.activeTab == tab ? tab.color.opacity(0.11) : .clear)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(store.activeTab == tab ? tab.color.opacity(0.7) : .clear, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(6)
        .background(.white.opacity(0.055), in: RoundedRectangle(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(.white.opacity(0.12), lineWidth: 1))
    }

    private var featureSection: some View {
        GlassCard {
            VStack(spacing: 0) {
                HStack {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(store.activeTab.color)
                        .frame(width: 5, height: 24)

                    Text(sectionTitle)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(store.activeTab.color)

                    Spacer()

                    Text(statusBadge)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(store.activeTab.color)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .overlay(
                            Capsule().stroke(store.activeTab.color.opacity(0.7), lineWidth: 1)
                        )
                }
                .padding(.bottom, 7)

                ForEach(store.list(for: store.activeTab)) { feature in
                    FeatureRow(feature: feature) {
                        store.toggle(featureID: feature.id, tab: store.activeTab)
                    }
                }
            }
        }
    }

    private var sectionTitle: String {
        switch store.activeTab {
        case .proxy: return "⚡ PROXY SHOP DHP"
        case .location: return "➤ ĐỊNH VỊ SÚNG"
        case .mod: return "♙ MOD NHÂN VẬT"
        }
    }

    private var statusBadge: String {
        switch store.activeTab {
        case .proxy: return "AUTO"
        case .location: return "LIVE"
        case .mod: return "SOON"
        }
    }

    private func openGame() {
        // Navigation hook only. Connect this to your own authorized app-launch logic.
        let bundle = game.bundleID
        guard let url = URL(string: "app-settings:\(bundle)") else { return }
        _ = UIApplication.shared.canOpenURL(url)
    }
}

struct FeatureRow: View {
    let feature: DHPFeature
    let action: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: feature.icon)
                .font(.system(size: 19, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 58, height: 58)
                .background(feature.tint.opacity(0.78), in: RoundedRectangle(cornerRadius: 14))
                .shadow(color: feature.tint.opacity(0.18), radius: 10)

            VStack(alignment: .leading, spacing: 3) {
                Text(feature.title)
                    .font(.system(size: 16, weight: .semibold))
                Text(feature.subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.48))
            }

            Spacer()

            Toggle(
                "",
                isOn: Binding(
                    get: { feature.enabled },
                    set: { _ in action() }
                )
            )
            .labelsHidden()
            .tint(feature.tint)
        }
        .padding(.vertical, 9)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(.white.opacity(0.065))
                .frame(height: 1)
        }
    }
}

// MARK: - Key / Settings

struct LicenseSheet: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("Dán key để kích hoạt.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("UID thiết bị")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(store.device.vendorID)
                            .font(.system(size: 12, design: .monospaced))
                            .textSelection(.enabled)
                    }

                    TextField("NDPXPRX-XXXXXXXX", text: $store.key)
                        .textInputAutocapitalization(.characters)
                }

                Section {
                    Button {
                        store.activateKey()
                    } label: {
                        Label("Kích hoạt", systemImage: "checkmark.seal.fill")
                    }

                    Button {
                        store.copyUID()
                    } label: {
                        Label("Sao chép UID", systemImage: "doc.on.doc.fill")
                    }

                    Button("Đóng") {
                        dismiss()
                    }
                }
            }
            .navigationTitle("License Key")
            .preferredColorScheme(.dark)
        }
    }
}

struct SettingsSheet: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                    } label: {
                        Label("Ngôn Ngữ", systemImage: "globe")
                    }

                    Button {
                    } label: {
                        Label("Kiểm Tra Cập Nhật", systemImage: "arrow.triangle.2.circlepath")
                    }

                    Button {
                    } label: {
                        Label("Xóa Bộ Nhớ Đệm", systemImage: "trash")
                    }

                    Button {
                    } label: {
                        Label("Chia Sẻ Ứng Dụng", systemImage: "square.and.arrow.up")
                    }

                    Button {
                    } label: {
                        Label("Thông Tin Ứng Dụng", systemImage: "info.circle")
                    }
                }

                Section("Thiết Bị") {
                    Text("iOS \(store.device.iosVersion)")
                    Text(store.device.model)
                    Text(store.device.vendorID)
                        .font(.system(size: 11, design: .monospaced))
                        .textSelection(.enabled)

                    Button("Sao chép UID") {
                        store.copyUID()
                    }
                }
            }
            .navigationTitle("Cài Đặt")
            .preferredColorScheme(.dark)
        }
    }
}

struct AboutSheet: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 15) {
                Image(systemName: "shield.checkered")
                    .font(.system(size: 55))
                    .foregroundStyle(LinearGradient(colors: [.purple, .cyan], startPoint: .top, endPoint: .bottom))

                Text("Proxy SHOP DHP")
                    .font(.system(size: 25, weight: .bold))

                Text("V1.0.0")
                    .foregroundStyle(.secondary)

                Text("SwiftUI • iOS 16+")
                    .foregroundStyle(.secondary)

                Spacer()
            }
            .padding(30)
            .navigationTitle("Thông Tin")
            .preferredColorScheme(.dark)
        }
    }
}
