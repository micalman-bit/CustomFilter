//
//  CustomFilterView.swift
//  CustomFilter
//
//  Created by Andrey Samchenko on 29.07.2023.
//

import SwiftUI
import CoreImage

struct CustomFilterView: View {
    @State private var intensity: Double = 0.0
    @State private var filteredImage: UIImage?

    var body: some View {
        VStack {
            Image(uiImage: filteredImage ?? UIImage(named: "image")!)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding()

            Text(String(format: "intensity: %.2f", intensity))
                .padding(.bottom, 20)

            Slider(value: $intensity, in: 0...100, step: 0.01)
                .padding([.horizontal, .bottom])
                .onChange(of: intensity, perform: { _ in
                    applyFilter()
                })

            Spacer()
        }
        .onAppear(perform: applyFilter)
        .padding()
    }

    private func applyFilter() {
        guard let inputImage = UIImage(named: "image") else {
            return
        }

        guard let ciImage = CIImage(image: inputImage) else {
            return
        }

        let kernel = CIColorKernel(source: """
            kernel vec4 exposureFilter(sampler image, float intensity) {
                vec4 inputColor = sample(image, samplerCoord(image));
                vec3 exposureColor = inputColor.rgb * (1.0 + intensity / 100);
                return vec4(exposureColor, inputColor.a);
            }
            """
        )

        let arguments = [ciImage, NSNumber(value: intensity) as Any]
        guard let outputCIImage = kernel?.apply(extent: ciImage.extent, arguments: arguments) else {
            return
        }

        if let outputCGImage = CIContext().createCGImage(outputCIImage, from: outputCIImage.extent) {
            let processedImage = UIImage(cgImage: outputCGImage)
            self.filteredImage = processedImage
        }
    }
}
