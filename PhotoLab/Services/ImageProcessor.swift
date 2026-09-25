import PhotosUI
import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

actor ImageProcessor {
    private let context = CIContext()

    func loadImage(item: PhotosPickerItem?) async throws -> CIImage? {
        guard let imageData = try await item?.loadTransferable(type: Data.self) else { return nil }
        guard let inputImage = UIImage(data: imageData) else { return nil }
        return CIImage(image: inputImage)
    }

    func applyProcessing(
        to beginImage: CIImage,
        option: FilterOption,
        filterIntensity: Double,
        rotationQuarterTurns: Int
    ) async -> Image? {
        guard !Task.isCancelled else { return nil }

        let rotatedImage = rotated(beginImage, by: rotationQuarterTurns)
        let currentFilter = await option.filter
        currentFilter.setValue(rotatedImage, forKey: kCIInputImageKey)

        let inputKeys = currentFilter.inputKeys
        let extent = rotatedImage.extent
        let imageCenter = CGPoint(x: extent.midX, y: extent.midY)
        let minSide = min(extent.width, extent.height)

        if inputKeys.contains(kCIInputIntensityKey) {
            currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey)
        }
        if inputKeys.contains(kCIInputRadiusKey) {
            currentFilter.setValue(filterIntensity * minSide * 0.8, forKey: kCIInputRadiusKey)
        }
        if inputKeys.contains(kCIInputScaleKey) {
            currentFilter.setValue(1 + filterIntensity * (minSide * 0.05), forKey: kCIInputScaleKey)
        }
        if inputKeys.contains(kCIInputCenterKey) {
            currentFilter.setValue(CIVector(cgPoint: imageCenter), forKey: kCIInputCenterKey)
        }

        guard !Task.isCancelled else { return nil }
        guard let outputImage = currentFilter.outputImage else { return nil }
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        return Image(uiImage: UIImage(cgImage: cgImage))
    }

    private func rotated(_ image: CIImage, by quarterTurns: Int) -> CIImage {
        let normalized = ((quarterTurns % 4) + 4) % 4
        guard normalized != 0 else { return image }
        let radians = CGFloat(normalized) * (.pi / 2)
        return image.transformed(by: CGAffineTransform(rotationAngle: radians))
    }
}
