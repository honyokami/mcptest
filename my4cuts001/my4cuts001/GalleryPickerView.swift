//
//  GalleryPickerView.swift
//  my4cuts001
//
//  Created by 黄炫凱 on 2025/9/4.
//

import SwiftUI
import UIKit

// 相册选择器视图
struct GalleryPickerView: UIViewControllerRepresentable {
    @Binding var selectedPhotos: [UIImage]
    @Binding var isPresented: Bool

    func makeUIViewController(context: Context) -> UIViewController {
        // 创建一个容器视图控制器
        let containerVC = UIViewController()
        containerVC.view.backgroundColor = .white

        // 创建导航栏
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: containerVC.view.frame.width, height: 44))
        containerVC.view.addSubview(navBar)

        // 创建导航项
        let navItem = UINavigationItem(title: "选择照片")
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: context.coordinator, action: #selector(Coordinator.cancel))
        navItem.leftBarButtonItem = cancelButton
        navBar.items = [navItem]

        // 创建相册选择器
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = .images
        configuration.selectionLimit = 4
        configuration.selectionBehavior = .ordered

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        picker.modalPresentationStyle = .overFullScreen

        // 添加到容器
        containerVC.addChild(picker)
        containerVC.view.addSubview(picker.view)
        picker.didMove(toParent: containerVC)

        // 设置picker视图的约束
        picker.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            picker.view.topAnchor.constraint(equalTo: navBar.bottomAnchor),
            picker.view.leadingAnchor.constraint(equalTo: containerVC.view.leadingAnchor),
            picker.view.trailingAnchor.constraint(equalTo: containerVC.view.trailingAnchor),
            picker.view.bottomAnchor.constraint(equalTo: containerVC.view.bottomAnchor)
        ])

        return containerVC
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: GalleryPickerView

        init(_ parent: GalleryPickerView) {
            self.parent = parent
        }

        @objc func cancel() {
            parent.isPresented = false
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            var selectedPhotos: [UIImage] = []
            let group = DispatchGroup()

            for result in results {
                group.enter()
                result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                    defer { group.leave() }
                    if let image = image as? UIImage {
                        selectedPhotos.append(image)
                    }
                }
            }

            group.notify(queue: .main) {
                // 关闭相册选择器
                picker.dismiss(animated: true) {}

                // 更新选中的照片
                self.parent.selectedPhotos = selectedPhotos
                self.parent.isPresented = false
            }
        }
    }
}

// 预览与排序视图的包装器
struct GalleryPreviewWrapper: View {
    @Binding var photos: [UIImage]
    @Binding var isPresented: Bool

    var body: some View {
        PhotoPreviewAndSortView(photos: photos)
            .onDisappear {
                isPresented = false
            }
    }
}

import PhotosUI

// 用于UIKit与SwiftUI的桥接（为保持兼容性保留）
struct GalleryPickerController: UIViewControllerRepresentable {
    @Binding var selectedPhotos: [UIImage]
    @Binding var isPresented: Bool

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = .images
        configuration.selectionLimit = 4
        configuration.selectionBehavior = .ordered

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: GalleryPickerController

        init(_ parent: GalleryPickerController) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            var selectedPhotos: [UIImage] = []
            let group = DispatchGroup()

            for result in results {
                group.enter()
                result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                    defer { group.leave() }
                    if let image = image as? UIImage {
                        selectedPhotos.append(image)
                    }
                }
            }

            group.notify(queue: .main) {
                // 关闭相册选择器
                picker.dismiss(animated: true) {}

                // 更新选中的照片
                self.parent.selectedPhotos = selectedPhotos
                // 跳转到照片预览与排序页
                if !selectedPhotos.isEmpty {
                    let previewVC = UIHostingController(rootView: PhotoPreviewAndSortView(photos: selectedPhotos))
                    if let presentingVC = picker.presentingViewController {
                        presentingVC.present(previewVC, animated: true, completion: nil)
                    }
                }
            }
        }
    }
}

#Preview {
    GalleryPickerView(selectedPhotos: .constant([]), isPresented: .constant(true))
}
