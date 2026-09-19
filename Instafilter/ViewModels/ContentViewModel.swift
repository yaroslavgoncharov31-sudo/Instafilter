import SwiftUI
import PhotosUI
import CoreImage
import CoreImage.CIFilterBuiltins

@Observable
class ContentViewModel {
    var processedImage: Image?
    var filterIntensity: Double = 0.5 { didSet { reprocess() } }
    var currentFilter: CIFilter = CIFilter.sepiaTone() { didSet { reprocess() } }
    var selectedItem: PhotosPickerItem? { didSet { Task { await loadImage() } } }

    private var beginImage: CIImage?
    private let imageProcessor = ImageProcessor()
    private let context = CIContext()

    let availableFilters = FilterOption.allCases

    func selectFilter(_ option: FilterOption) {
        currentFilter = option.filter
    }

    private func loadImage() async {
        beginImage = try? await imageProcessor.loadImage(item: selectedItem)
        reprocess()
    }

    private func reprocess() {
        guard let beginImage else { return }
        processedImage = imageProcessor.applyProcessing(
            to: beginImage,
            currentFilter: currentFilter,
            filterIntensity: filterIntensity,
            context: context
        )
    }
    private func setFilter(_ filter: CIFilter) async {
        currentFilter = filter
        await loadImage()
    }
}
