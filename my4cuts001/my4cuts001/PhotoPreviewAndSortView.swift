//
//  PhotoPreviewAndSortView.swift
//  my4cuts001
//
//  Created by 黄炫凱 on 2025/9/4.
//

import SwiftUI
import UIKit

enum PhotoSortError: Error {
    case emptyPhotos
}

struct PhotoPreviewAndSortView: View {
    @Environment(\.dismiss) var dismiss
    @State private var sortedPhotos: [UIImage]
    @State private var showLoading = false
    @State private var isDragging = false
    @State private var draggedIndex: Int?
    @State private var targetIndex: Int?
    @State private var animationID = UUID()

    // 初始化时确保有4张照片，不足则复制最后一张
    init(photos: [UIImage]) {
        var adjustedPhotos = photos
        if adjustedPhotos.isEmpty {
            // 如果没有照片，使用默认图像
            adjustedPhotos = [UIImage(named: "placeholder") ?? UIImage()] // 假设项目中有placeholder图像
        } else if adjustedPhotos.count < 4 {
            // 如果少于4张，复制最后一张直到有4张
            let lastPhoto = adjustedPhotos.last!
            while adjustedPhotos.count < 4 {
                adjustedPhotos.append(lastPhoto)
            }
        }
        self._sortedPhotos = State(initialValue: adjustedPhotos)
    }

    var body: some View {
        ZStack {
            // 背景色
            Color.white
                .edgesIgnoringSafeArea(.all)

            VStack {
                // 顶部导航栏
                HStack {
                    Button("取消") {
                        dismiss()
                    }
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding()

                    Spacer()

                    Text("预览")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.black)

                    Spacer()

                    Button("完成") {
                        processPhotos()
                    }
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding()
                }

                // 照片网格预览区域
                GeometryReader {
                    geometry in
                    let gridWidth = geometry.size.width
                    let spacing: CGFloat = 10
                    let itemWidth = (gridWidth - spacing * 3) / 2 // 2列布局

                    GridView(
                        items: $sortedPhotos,
                        isDragging: $isDragging,
                        draggedIndex: $draggedIndex,
                        targetIndex: $targetIndex,
                        animationID: $animationID,
                        itemWidth: itemWidth,
                        spacing: spacing
                    )
                }
                .padding()
                .id(animationID)

                // 底部提示文本
                Text("可拖拽排序")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showLoading) {
            LoadingAnimationView(photos: sortedPhotos)
        }
    }

    // 处理照片（压缩等）
    private func processPhotos() {
        showLoading = true
        // 这里可以添加照片处理逻辑
        // 模拟处理延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // 处理完成后跳转到动画加载页
            // 实际项目中可能需要将处理后的照片传递给下一个视图
        }
    }
}

// 网格视图实现
struct GridView: View {
    @Binding var items: [UIImage]
    @Binding var isDragging: Bool
    @Binding var draggedIndex: Int?
    @Binding var targetIndex: Int?
    @Binding var animationID: UUID
    let itemWidth: CGFloat
    let spacing: CGFloat

    var body: some View {
        VStack(spacing: spacing) {
            ForEach(0..<2) { row in
                HStack(spacing: spacing) {
                    ForEach(0..<2) { column in
                        let index = row * 2 + column
                        if index < items.count {
                            GridItemView(
                                image: items[index],
                                index: index,
                                isDragging: $isDragging,
                                draggedIndex: $draggedIndex,
                                targetIndex: $targetIndex,
                                items: $items,
                                animationID: $animationID,
                                width: itemWidth
                            )
                        }
                    }
                }
            }
        }
    }
}

// 网格项视图实现
struct GridItemView: View {
    let image: UIImage
    let index: Int
    @Binding var isDragging: Bool
    @Binding var draggedIndex: Int?
    @Binding var targetIndex: Int?
    @Binding var items: [UIImage]
    @Binding var animationID: UUID
    let width: CGFloat

    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(width: width, height: width)
            .clipped()
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(draggedIndex == index ? Color.blue : Color.clear, lineWidth: 3)
            )
            .opacity(draggedIndex == index ? 0.5 : 1.0)
            .scaleEffect(draggedIndex == index ? 1.05 : 1.0)
            .onLongPressGesture(minimumDuration: 0.3) {
                isDragging = true
                draggedIndex = index
            }
            .simultaneousGesture(
                DragGesture()
                    .onChanged { _ in
                        // 在实际应用中，可以在这里添加拖拽位置计算
                    }
                    .onEnded { _ in
                        if let draggedIndex = draggedIndex, let targetIndex = targetIndex {
                            if draggedIndex != targetIndex {
                                // 执行交换
                                let temp = items[draggedIndex]
                                items[draggedIndex] = items[targetIndex]
                                items[targetIndex] = temp
                                // 更新动画ID以强制刷新视图
                                animationID = UUID()
                            }
                        }
                        isDragging = false
                        draggedIndex = nil
                        targetIndex = nil
                    }
            )
            .onTapGesture {
                if isDragging, let draggedIndex = draggedIndex, draggedIndex != index {
                    targetIndex = index
                }
            }
    }
}

// 动画加载页
struct LoadingAnimationView: View {
    let photos: [UIImage]
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)
            VStack {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(2)
                Text("正在处理您的照片...")
                    .foregroundColor(.white)
                    .padding()
            }
        }
        .onAppear {
            // 模拟处理完成后返回
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                dismiss()
            }
        }
    }
}

#Preview {
    // 创建示例图像用于预览
    let sampleImages = [
        UIImage(named: "sample1") ?? UIImage(),
        UIImage(named: "sample2") ?? UIImage(),
        UIImage(named: "sample3") ?? UIImage(),
        UIImage(named: "sample4") ?? UIImage()
    ]
    PhotoPreviewAndSortView(photos: sampleImages)
}
