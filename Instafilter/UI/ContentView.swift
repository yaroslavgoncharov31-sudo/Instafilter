import PhotosUI
import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct ContentView: View {
    @State private var viewModel = ContentViewModel()
    @State private var showingFilters = false

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                PhotosPicker(selection: $viewModel.selectedItem) {
                    if let processedImage = viewModel.processedImage {
                        processedImage
                            .resizable()
                            .scaledToFit()
                    } else {
                        ContentUnavailableView("No picture", systemImage: "photo.badge.plus", description: Text("Tap to import a photo"))
                    }
                }
                .buttonStyle(.plain)
                Spacer()

                HStack {
                    Text("Intensity")
                    Slider(value: $viewModel.filterIntensity)
                }
                HStack {
                    Button("Change filter") {
                        showingFilters = true
                    }
                    Spacer()
                }
            }
            .padding([.horizontal, .bottom])
            .navigationTitle("Instafilter")
            .confirmationDialog("Select a filter", isPresented: $showingFilters) {
                ForEach(viewModel.availableFilters, id: \.id) { option in
                    Button(option.name) {
                        viewModel.selectFilter(option)
                    }
                }
            }
        }
    }
}
#Preview {
    ContentView()
}
