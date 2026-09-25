import SwiftUI
import PhotosUI
import CoreImage
import CoreImage.CIFilterBuiltins

@Observable
class ContentViewModel {
    var processedImage: Image?
    var filterIntensity: Double = 0.5 { didSet { reprocess() } }
    var currentFilterOption: FilterOption = .sepiaTone { didSet { reprocess() } }
    var selectedItem: PhotosPickerItem? { didSet { Task { await loadImage() } } }
    var rotationQuarterTurns: Int = 0 { didSet { reprocess() } }

    private var filterUsageCount: Int {
        get { UserDefaults.standard.integer(forKey: "filterUsageCount") }
        set { UserDefaults.standard.set(newValue, forKey: "filterUsageCount") }
    }
    var shouldRequestReview: Bool {
        filterUsageCount > 0 && filterUsageCount % 20 == 0
    }

    private var beginImage: CIImage?
    private let imageProcessor = ImageProcessor()
    private var processingTask: Task<Void, Never>?
    let availableFilters = FilterOption.allCases

    func rotateClockwise() { rotationQuarterTurns -= 1 }
    func rotateCounterClockwise() { rotationQuarterTurns += 1 }

    func selectFilter(_ option: FilterOption) {
        currentFilterOption = option
        filterUsageCount += 1
    }

    private func loadImage() async {
        beginImage = try? await imageProcessor.loadImage(item: selectedItem)
        rotationQuarterTurns = 0
        reprocess()
    }

    private func reprocess() {
        processingTask?.cancel()
        guard let beginImage else { return }

        let option = currentFilterOption
        let intensity = filterIntensity
        let rotation = rotationQuarterTurns

        processingTask = Task {
            let result = await imageProcessor.applyProcessing(
                to: beginImage,
                option: option,
                filterIntensity: intensity,
                rotationQuarterTurns: rotation
            )
            guard !Task.isCancelled else { return }
            processedImage = result
        }
    }
}
