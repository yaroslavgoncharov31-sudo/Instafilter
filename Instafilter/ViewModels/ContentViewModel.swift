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
    private var filterUsageCount: Int {
        get { UserDefaults.standard.integer(forKey: "filterUsageCount") }
        set { UserDefaults.standard.set(newValue, forKey: "filterUsageCount")}
    }
    var shouldRequestReview: Bool {
        filterUsageCount > 0 && filterUsageCount % 20 == 0
    }
    private var beginImage: CIImage?
    private let imageProcessor = ImageProcessor()
    private let context = CIContext()
    let availableFilters = FilterOption.allCases

    var rotationQuarterTurns: Int = 0 { didSet { reprocess() } }

    func rotateClockwise() {
        rotationQuarterTurns -= 1
    }
    func rotateCounterClockwise() {
        rotationQuarterTurns += 1
    }

    func selectFilter(_ option: FilterOption) {
        currentFilter = option.filter
        filterUsageCount += 1
    }

    private func loadImage() async {
        beginImage = try? await imageProcessor.loadImage(item: selectedItem)
        rotationQuarterTurns = 0
        reprocess()
    }

    private func reprocess() {
        guard let beginImage else { return }
        let rotatedImage = imageProcessor.rotated(beginImage, by: rotationQuarterTurns)
        processedImage = imageProcessor.applyProcessing(
            to: rotatedImage,
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
