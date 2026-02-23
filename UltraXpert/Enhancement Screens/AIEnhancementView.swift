//
//  AIEnhancementView.swift
//  UltraXpert
//
//  Created by sanjaysadha on 04/02/26.
//


import SwiftUI

struct AIEnhancementView: View {

    let originalImage: UIImage

    @State private var goProcessing = false
    @State private var selectedPreset: AIPreset = .standard

    enum AIPreset: String, CaseIterable {
        case standard = "Standard Enhance"
        case denoise = "Strong Denoise"
        case edge = "Edge Focus"
    }

    var body: some View {
        VStack(spacing: 18) {

            VStack(alignment: .leading, spacing: 6) {
                Text("AI Enhancement")
                    .font(.title2).bold()
                Text("Choose a preset to enhance automatically")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(uiImage: originalImage)
                .resizable()
                .scaledToFit()
                .frame(height: 240)
                .clipShape(RoundedRectangle(cornerRadius: 18))

            VStack(spacing: 12) {
                presetCard(.standard, desc: "Balanced enhancement for most scans")
                presetCard(.denoise, desc: "Removes strong noise, smoother output")
                presetCard(.edge, desc: "Highlights edges and boundaries")
            }

            Spacer()
        }
        .padding()
        .navigationDestination(isPresented: $goProcessing) {
            EnhancementProcessingView(originalImage: originalImage)
        }
    }

    private func presetCard(_ preset: AIPreset, desc: String) -> some View {
        Button {
            selectedPreset = preset
            goProcessing = true
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.purple.opacity(0.12))
                        .frame(width: 56, height: 56)

                    Image(systemName: "sparkles")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.purple)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(preset.rawValue)
                        .font(.headline)
                    Text(desc)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
            .padding(16)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
    }
}
