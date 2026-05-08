import SwiftUI
import UIKit
import PhotosUI

// MARK: - CameraPickerView
// Camera  → UIImagePickerController (.camera)
// Gallery → PHPickerViewController  (iOS 14+, non-deprecated)
// Selects automatically based on hardware availability.

struct CameraPickerView: UIViewControllerRepresentable {

    @Binding var capturedImage : UIImage?
    @Binding var isPresented   : Bool

    static var isCameraAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        if Self.isCameraAvailable {
            let picker              = UIImagePickerController()
            picker.sourceType       = .camera
            picker.cameraCaptureMode = .photo
            picker.allowsEditing    = false
            picker.delegate         = context.coordinator
            return picker
        } else {
            var config         = PHPickerConfiguration()
            config.filter      = .images
            config.selectionLimit = 1
            let picker         = PHPickerViewController(configuration: config)
            picker.delegate    = context.coordinator
            return picker
        }
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    // MARK: - Coordinator

    final class Coordinator: NSObject,
                             UINavigationControllerDelegate,
                             UIImagePickerControllerDelegate,
                             PHPickerViewControllerDelegate {

        private let parent: CameraPickerView

        init(_ parent: CameraPickerView) { self.parent = parent }

        // Camera
        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            parent.capturedImage = info[.originalImage] as? UIImage
            parent.isPresented   = false
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }

        // Gallery
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.isPresented = false
            guard let result = results.first else { return }
            result.itemProvider.loadObject(ofClass: UIImage.self) { object, _ in
                DispatchQueue.main.async {
                    self.parent.capturedImage = object as? UIImage
                }
            }
        }
    }
}
