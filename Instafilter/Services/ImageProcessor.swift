import PhotosUI
import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct ImageProcessor {
    func loadImage(item: PhotosPickerItem?) async throws -> CIImage? {
            guard let imageData = try await item?.loadTransferable(type: Data.self) else { return nil }
            guard let inputImage = UIImage(data: imageData) else  { return nil }

            let beginImage = CIImage(image: inputImage)
            return CIImage(image: inputImage)
    }
    func applyProcessing(to beginImage: CIImage, currentFilter: CIFilter, filterIntensity: Double, context: CIContext) -> Image? {
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        currentFilter.setValue(Float(filterIntensity), forKey: kCIInputIntensityKey)
        guard let outputImage = currentFilter.outputImage else { return nil }
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        return Image(uiImage: UIImage(cgImage: cgImage))
    }
}
