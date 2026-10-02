import AVFoundation
import Photos
import SwiftUI
import UserNotifications
import VeiraCore
import VeiraDesignSystem
import VeiraDomain

@MainActor
@Observable
final class PermissionsViewModel {
    var items: [PermissionItem]
    var granted: Set<PermissionKind> = []
    var isRequesting = false

    init(items: [PermissionItem] = SampleData.permissions) {
        self.items = items
    }

    var allCriticalGranted: Bool {
        granted.contains(.camera)
    }

    func isGranted(_ kind: PermissionKind) -> Bool {
        granted.contains(kind)
    }

    func markGranted(_ kind: PermissionKind) {
        granted.insert(kind)
    }
}

struct PermissionsScreen: View {
    @Environment(AppContainer.self) private var container
    @State private var model = PermissionsViewModel()

    let onFinished: () -> Void

    @Environment(\.veiraTheme) private var theme

    var body: some View {
        ZStack {
            VeiraAtmosphere()

            VStack(alignment: .leading, spacing: VeiraSpacing.xl.value) {
                VStack(alignment: .leading, spacing: VeiraSpacing.sm.value) {
                    VeiraOverline(text: "Almost ready")

                    Text("A few permissions")
                        .veiraFont(.displayMedium)
                        .foregroundStyle(theme.colors.textPrimary)
                        .accessibilityAddTraits(.isHeader)

                    Text("Veira only asks for what it needs — you can change these anytime in Settings.")
                        .veiraFont(.bodyLarge)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, VeiraSpacing.xl.value)

                VStack(spacing: VeiraSpacing.sm.value) {
                    ForEach(model.items) { item in
                        permissionRow(item)
                    }
                }

                Spacer()

                VStack(spacing: VeiraSpacing.sm.value) {
                    VeiraButton(
                        model.allCriticalGranted ? "Enter Veira" : "Allow camera to continue",
                        isLoading: model.isRequesting,
                        isEnabled: model.allCriticalGranted || !model.isRequesting
                    ) {
                        if model.allCriticalGranted {
                            finish()
                        } else {
                            Task { await request(.camera) }
                        }
                    }

                    if model.allCriticalGranted {
                        VeiraButton("Continue", variant: .ghost, action: finish)
                            .accessibilityHidden(true)
                            .frame(height: 0)
                            .opacity(0)
                    } else {
                        VeiraButton("I’ll set this up later", variant: .ghost) {
                            Task { await request(.camera) }
                        }
                    }
                }
                .padding(.bottom, VeiraSpacing.xl.value)
            }
            .veiraScreenPadding()
        }
        .task {
            await refreshStatuses()
        }
    }

    private func permissionRow(_ item: PermissionItem) -> some View {
        let granted = model.isGranted(item.kind)

        return HStack(spacing: VeiraSpacing.md.value) {
            VeiraSymbolBadge(systemName: item.symbolName, size: 48)

            VStack(alignment: .leading, spacing: VeiraSpacing.xxs.value) {
                Text(item.title)
                    .veiraFont(.titleSmall)
                    .foregroundStyle(theme.colors.textPrimary)

                Text(item.detail)
                    .veiraFont(.bodySmall)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: VeiraSpacing.xs.value)

            if granted {
                VeiraIconView(.checkCircle, size: 22)
                    .foregroundStyle(theme.colors.success)
                    .accessibilityLabel("Granted")
            } else {
                Button("Allow") {
                    Task { await request(item.kind) }
                }
                .veiraFont(.labelMedium)
                .foregroundStyle(theme.colors.accent)
                .padding(.horizontal, VeiraSpacing.sm.value)
                .padding(.vertical, VeiraSpacing.xs.value)
                .background(theme.colors.accentMuted)
                .clipShape(Capsule())
                .veiraTapTarget()
            }
        }
        .padding(VeiraSpacing.md.value)
        .background(theme.colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: VeiraRadius.lg.value, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: VeiraRadius.lg.value, style: .continuous)
                .strokeBorder(theme.colors.borderSubtle, lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
    }

    private func refreshStatuses() async {
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            model.markGranted(.camera)
        }
        if PHPhotoLibrary.authorizationStatus(for: .readWrite) == .authorized
            || PHPhotoLibrary.authorizationStatus(for: .readWrite) == .limited {
            model.markGranted(.photos)
        }
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        if settings.authorizationStatus == .authorized {
            model.markGranted(.notifications)
        }
    }

    private func request(_ kind: PermissionKind) async {
        model.isRequesting = true
        defer { model.isRequesting = false }

        switch kind {
        case .camera:
            let status = await AVCaptureDevice.requestAccess(for: .video)
            if status { model.markGranted(.camera) }
        case .photos:
            let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
            if status == .authorized || status == .limited {
                model.markGranted(.photos)
            }
        case .notifications:
            do {
                let granted = try await UNUserNotificationCenter.current()
                    .requestAuthorization(options: [.alert, .badge, .sound])
                if granted { model.markGranted(.notifications) }
            } catch {
                container.logger.warning("Notification permission failed: \(error)", category: .ui)
            }
        }

        await refreshStatuses()
    }

    private func finish() {
        Task {
            await container.preferencesRepository.setBool(true, for: .hasCompletedPermissions)
            await container.analytics.track(.init(name: "permissions_completed"))
            onFinished()
        }
    }
}

#Preview {
    PermissionsScreen(onFinished: {})
        .environment(AppContainer(configuration: EnvironmentConfigurationFactory.make()))
        .veiraThemed()
}
