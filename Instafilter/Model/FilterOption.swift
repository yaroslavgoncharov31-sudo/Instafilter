import PhotosUI
import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

enum FilterOption: String, CaseIterable, Identifiable {
    case crystallize, edges, gaussianBlur, sepiaTone, pixellate, unsharpMask, vignette, twirl

    var id: String { rawValue }

    var name: String {
        switch self {
        case .crystallize: "Crystallize"
        case .edges: "Edges"
        case .gaussianBlur: "Gaussian Blur"
        case .sepiaTone: "Sepia Tone"
        case .pixellate: "Pixellate"
        case .unsharpMask: "Unsharp Mask"
        case .vignette: "Vignette"
        case .twirl: "Twirl"
        }
    }

    var filter: CIFilter {
        switch self {
        case .crystallize: CIFilter.crystallize()
        case .edges: CIFilter.edges()
        case .gaussianBlur: CIFilter.gaussianBlur()
        case .sepiaTone: CIFilter.sepiaTone()
        case .pixellate: CIFilter.pixellate()
        case .unsharpMask: CIFilter.unsharpMask()
        case .vignette: CIFilter.vignette()
        case .twirl: CIFilter.twirlDistortion()

        }
    }
}
