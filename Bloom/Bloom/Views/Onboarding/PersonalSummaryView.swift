import SwiftUI

struct PersonalSummaryView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        ZStack {
            BloomTheme.background
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    BackButtonView {
                        viewModel.goBack()
                    }
                    Spacer()
                }
                .padding(.horizontal, BloomTheme.pagePadding)
                .padding(.top, 10)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        Spacer().frame(height: 22)

                        Text("Your Bloom path")
                            .font(.system(size: 31, weight: .bold, design: .rounded))
                            .foregroundStyle(BloomTheme.textPrimary)

                        Text("Here’s how Bloom can begin shaping your experience.")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(BloomTheme.textSecondary)

                        summaryHeroCard

                        detailCards

                        if let saveErrorMessage = viewModel.saveErrorMessage, !saveErrorMessage.isEmpty {
                            Text(saveErrorMessage)
                                .font(.system(size: 14))
                                .foregroundStyle(.red.opacity(0.9))
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Spacer().frame(height: 28)
                    }
                    .padding(.horizontal, BloomTheme.pagePadding)
                }

                BottomCTAButton(
                    title: viewModel.isSaving ? "Saving..." : "Enter Bloom",
                    enabled: !viewModel.isSaving
                ) {
                    Task {
                        await viewModel.saveOnboardingIfPossible()
                        if viewModel.saveErrorMessage == nil || viewModel.saveErrorMessage?.isEmpty == true {
                            viewModel.finish()
                        }
                    }
                }
                .padding(.horizontal, BloomTheme.pagePadding)
                .padding(.bottom, 24)
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private var summaryHeroCard: some View {
        RoundedRectangle(cornerRadius: 30, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        BloomTheme.elevatedBackground,
                        BloomTheme.card
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(height: 250)
            .overlay(
                VStack(alignment: .leading, spacing: 18) {
                    Circle()
                        .fill(BloomTheme.cream.opacity(0.14))
                        .frame(width: 58, height: 58)
                        .overlay(
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 22))
                                .foregroundStyle(BloomTheme.cream)
                        )

                    Text(viewModel.summaryHeadline)
                        .font(.system(size: 25, weight: .bold, design: .rounded))
                        .foregroundStyle(BloomTheme.textPrimary)
                        .lineSpacing(5)

                    Text(viewModel.summaryBody)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(BloomTheme.textSecondary)
                        .lineSpacing(5)
                }
                .padding(24)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .stroke(BloomTheme.cardBorder, lineWidth: 1)
            )
    }

    private var detailCards: some View {
        VStack(spacing: 14) {
            SummaryMiniCard(
                title: "What you’ve been carrying",
                value: viewModel.selectedBlockerTitles.isEmpty
                    ? "Still exploring"
                    : viewModel.selectedBlockerTitles.joined(separator: ", ")
            )

            SummaryMiniCard(
                title: "What tends to repeat",
                value: viewModel.selectedPatternTitles.isEmpty
                    ? "Still exploring"
                    : viewModel.selectedPatternTitles.joined(separator: ", ")
            )

            SummaryMiniCard(
                title: "Your energy lately",
                value: viewModel.selectedEnergyTitle
            )

            SummaryMiniCard(
                title: "How things stay with you",
                value: viewModel.selectedReactionTitle
            )

            SummaryMiniCard(
                title: "Best starting rhythm",
                value: viewModel.selectedSupportStyleTitle
            )
        }
    }
}

private struct SummaryMiniCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(BloomTheme.rose)

            Text(value)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(BloomTheme.textPrimary)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(BloomTheme.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(BloomTheme.cardBorder, lineWidth: 1)
                )
        )
    }
}
