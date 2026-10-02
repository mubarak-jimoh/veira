import Foundation
import VeiraDomain

/// Realistic placeholder content for the first shippable shell.
enum SampleData {
    static let profile = UserProfile(
        displayName: "Amelia Chen",
        email: "amelia@veira.app",
        skinGoal: "Calm, even skin tone",
        memberSince: Calendar.current.date(from: DateComponents(year: 2026, month: 3, day: 12)) ?? Date()
    )

    static let todayScore = SkinScore(
        value: 82,
        capturedAt: Date(),
        summary: "Hydration is strong. Mild congestion around the T-zone — keep tonight’s treatment gentle.",
        metrics: [
            SkinMetric(name: "Hydration", value: 88, insight: "Barrier looks resilient", symbolName: "drop.fill"),
            SkinMetric(name: "Clarity", value: 74, insight: "Slight congestion", symbolName: "sparkles"),
            SkinMetric(name: "Texture", value: 81, insight: "Smoothing steadily", symbolName: "face.smiling.inverse"),
            SkinMetric(name: "Tone", value: 79, insight: "Even and calm", symbolName: "sun.max.fill")
        ]
    )

    static let progress: [ProgressSnapshot] = {
        let calendar = Calendar.current
        let now = Date()
        return [
            ProgressSnapshot(
                weekLabel: "This week",
                score: 82,
                note: "Hydration rebound after sleep consistency",
                capturedAt: now
            ),
            ProgressSnapshot(
                weekLabel: "Last week",
                score: 78,
                note: "Texture improved with evening retinoid",
                capturedAt: calendar.date(byAdding: .day, value: -7, to: now) ?? now
            ),
            ProgressSnapshot(
                weekLabel: "2 weeks ago",
                score: 74,
                note: "Mild flare after travel — recovered well",
                capturedAt: calendar.date(byAdding: .day, value: -14, to: now) ?? now
            ),
            ProgressSnapshot(
                weekLabel: "3 weeks ago",
                score: 71,
                note: "Baseline established after first scans",
                capturedAt: calendar.date(byAdding: .day, value: -21, to: now) ?? now
            )
        ]
    }()

    static let morningRoutine = SkinRoutine(
        title: "Morning reset",
        period: .morning,
        steps: [
            RoutineStep(
                title: "Cleanse",
                detail: "Gel cleanser, lukewarm water, 60 seconds",
                durationSeconds: 60,
                isCompleted: true,
                symbolName: "drop.fill"
            ),
            RoutineStep(
                title: "Tone",
                detail: "Hydrating mist — pat, don’t rub",
                durationSeconds: 30,
                isCompleted: true,
                symbolName: "sparkles"
            ),
            RoutineStep(
                title: "Serum",
                detail: "Vitamin C, two drops across face and neck",
                durationSeconds: 45,
                isCompleted: false,
                symbolName: "leaf.fill"
            ),
            RoutineStep(
                title: "Moisturise",
                detail: "Lightweight cream while skin is still damp",
                durationSeconds: 40,
                isCompleted: false,
                symbolName: "moon.fill"
            ),
            RoutineStep(
                title: "SPF",
                detail: "Broad-spectrum SPF 50 — don’t skip",
                durationSeconds: 30,
                isCompleted: false,
                symbolName: "sun.max.fill"
            )
        ],
        estimatedMinutes: 6
    )

    static let eveningRoutine = SkinRoutine(
        title: "Evening restore",
        period: .evening,
        steps: [
            RoutineStep(
                title: "Double cleanse",
                detail: "Oil cleanse, then gel — remove the day gently",
                durationSeconds: 90,
                isCompleted: false,
                symbolName: "drop.fill"
            ),
            RoutineStep(
                title: "Treatment",
                detail: "Peptide serum on damp skin",
                durationSeconds: 45,
                isCompleted: false,
                symbolName: "sparkles"
            ),
            RoutineStep(
                title: "Retinoid",
                detail: "Pea-sized amount, three nights a week",
                durationSeconds: 30,
                isCompleted: false,
                symbolName: "moon.stars.fill"
            ),
            RoutineStep(
                title: "Seal",
                detail: "Ceramide cream — focus on cheeks",
                durationSeconds: 40,
                isCompleted: false,
                symbolName: "leaf.fill"
            )
        ],
        estimatedMinutes: 8
    )

    static let onboardingPages: [OnboardingPage] = [
        OnboardingPage(
            title: "See your skin clearly",
            message: "A calm, private scan that turns light and texture into insight — not noise.",
            symbolName: "viewfinder"
        ),
        OnboardingPage(
            title: "Track what matters",
            message: "Watch hydration, clarity, and tone shift week by week with quiet confidence.",
            symbolName: "chart.line.uptrend.xyaxis"
        ),
        OnboardingPage(
            title: "A routine that fits",
            message: "Morning and evening steps tailored to your skin — simple enough to keep.",
            symbolName: "list.bullet"
        )
    ]

    static let permissions: [PermissionItem] = [
        PermissionItem(
            title: "Camera",
            detail: "Required for skin scans in natural light.",
            symbolName: "camera.fill",
            kind: .camera
        ),
        PermissionItem(
            title: "Photos",
            detail: "Save and compare progress photos over time.",
            symbolName: "photo.fill",
            kind: .photos
        ),
        PermissionItem(
            title: "Notifications",
            detail: "Gentle reminders for evening routine and weekly check-ins.",
            symbolName: "bell.fill",
            kind: .notifications
        )
    ]

    static let insightCards: [(title: String, body: String, symbol: String)] = [
        (
            "Tonight",
            "Skip actives if your skin feels tight. Focus on barrier repair.",
            "moon.stars.fill"
        ),
        (
            "This week",
            "Sleep consistency is lifting your hydration score.",
            "chart.line.uptrend.xyaxis"
        ),
        (
            "Watch",
            "T-zone congestion is mild — keep cleansing thorough but gentle.",
            "eye.fill"
        )
    ]
}
