//
//  CameraView.swift
//  my4cuts001
//
//  Created by 黄炫凱 on 2025/9/4.
//

import SwiftUI
import AVFoundation
import Photos
import UIKit

struct CameraView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var recentPhotos: [UIImage]
    @State private var showImageEditor = false
    @State private var capturedImage: UIImage? = nil
    @State private var isCameraReady = false
    @State private var errorMessage = ""
    @State private var showError = false
    @State private var showSettings = false
    @State private var currentCameraPosition: AVCaptureDevice.Position = .back
    @State private var captureCount = 0
    @State private var showCountdown = false
    @State private var countdownValue = 3
    @State private var showLoading = false

    // 相机会话和预览层
    private let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()

    var body: some View {
        ZStack {
            // 相机预览
            CameraPreview(session: session)
                .edgesIgnoringSafeArea(.all)

            // 顶部状态栏
            VStack {
                HStack {
                    Button(action: {
                        showSettings = true
                    }) {
                        Image(systemName: "gear")
                            .foregroundColor(.white)
                            .font(.title)
                            .padding()
                    }
                    Spacer()
                    Button(action: {
                        switchCamera()
                    }) {
                        Image(systemName: "arrow.triangle.2.circlepath.camera")
                            .foregroundColor(.white)
                            .font(.title)
                            .padding()
                    }
                }
                Spacer()
            }

            // 中部拍摄进度提示
            VStack {
                Spacer()
                Text("\(captureCount)/4")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(10)
                Spacer()
            }

            // 底部操作栏
            VStack {
                Spacer()
                HStack {
                    // 相册图标
                    Button(action: {
                        // 跳转到相册选择页
                        dismiss()
                    }) {
                        Image(systemName: "photo.fill")
                            .foregroundColor(.white)
                            .font(.title)
                            .padding()
                    }

                    Spacer()

                    // 大型圆形快门按钮
                    Button(action: {
                        takePhoto()
                    }) {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 80, height: 80)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 4)
                                    .frame(width: 70, height: 70)
                            )
                    }
                    .disabled(!isCameraReady)

                    Spacer()

                    // 预留位置
                    Button(action: {})
                    {
                        Image(systemName: "plus")
                            .foregroundColor(.clear)
                            .font(.title)
                            .padding()
                    }
                }
                .padding(.bottom, 40)
            }

            // 水印
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text("my4cuts")
                        .font(.caption)
                        .foregroundColor(Color.white.opacity(0.6))
                        .padding(5)
                        .background(Color.clear)
                        .frame(width: 20)
                }
                .padding(20)
            }

            // 倒计时视图
            if showCountdown {
                VStack {
                    Spacer()
                    Text("\(countdownValue)")
                        .font(.system(size: 100, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                }
                .background(Color.black.opacity(0.3))
            }

            // 加载动画
            if showLoading {
                ZStack {
                    Color.black
                        .edgesIgnoringSafeArea(.all)
                    VStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(2)
                        Text("正在生成您的照片...")
                            .foregroundColor(.white)
                            .padding()
                    }
                }
            }
        }
        .onAppear {
            setupCamera()
        }
        .onDisappear {
            session.stopRunning()
        }
        .fullScreenCover(isPresented: $showImageEditor) {
            if let image = capturedImage {
                ImageEditorView(image: image, recentPhotos: $recentPhotos, captureCount: $captureCount, showLoading: $showLoading)
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .alert(isPresented: $showError) {
            Alert(title: Text("错误"), message: Text(errorMessage), dismissButton: .default(Text("确定")))
        }
    }

    // 设置相机
    private func setupCamera() {
        session.beginConfiguration()
        session.sessionPreset = .photo

        // 移除现有输入
        for input in session.inputs {
            session.removeInput(input)
        }

        // 配置输入
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: currentCameraPosition) else {
            errorMessage = "无法访问\(currentCameraPosition == .back ? "后置" : "前置")摄像头"
            showError = true
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) {
                session.addInput(input)
            }
        } catch {
            errorMessage = "相机初始化失败: \(error.localizedDescription)"
            showError = true
            session.commitConfiguration()
            return
        }

        // 配置输出
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }

        session.commitConfiguration()

        // 启动会话
        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
            DispatchQueue.main.async {
                self.isCameraReady = true
            }
        }
    }

    // 切换摄像头
    private func switchCamera() {
        currentCameraPosition = currentCameraPosition == .back ? .front : .back
        setupCamera()
    }

    // 拍照
    private func takePhoto() {
        // 这里可以根据设置决定是否使用倒计时
        let useCountdown = true // 假设设置中启用了倒计时

        if useCountdown {
            startCountdown()
        } else {
            capturePhoto()
        }
    }

    // 开始倒计时
    private func startCountdown() {
        showCountdown = true
        countdownValue = 3

        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            countdownValue -= 1
            if countdownValue <= 0 {
                timer.invalidate()
                showCountdown = false
                capturePhoto()
            }
        }
    }

    // 捕获照片
    private func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        photoOutput.capturePhoto(with: settings, delegate: self)

        // 模拟闪光灯
        flashScreen()

        // 模拟快门声和振动
        playShutterSound()
        vibrateDevice()
    }

    // 屏幕闪光灯效果
    private func flashScreen() {
        let flashView = UIView(frame: UIScreen.main.bounds)
        flashView.backgroundColor = .white
        flashView.alpha = 0.0
        UIApplication.shared.windows.first?.addSubview(flashView)

        UIView.animate(withDuration: 0.1) { 
            flashView.alpha = 1.0
        } completion: { _ in
            UIView.animate(withDuration: 0.3) { 
                flashView.alpha = 0.0
            } completion: { _ in
                flashView.removeFromSuperview()
            }
        }
    }

    // 播放快门声
    private func playShutterSound() {
        // 在实际应用中，这里会播放快门音效
    }

    // 设备振动
    private func vibrateDevice() {
        UIDevice.current.playHapticFeedback(.impact)
    }
}

// 设置面板视图
struct SettingsView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("相机设置")) {
                    Toggle("启用倒计时", isOn: .constant(true))
                    Picker("倒计时时间", selection: .constant(3)) {
                        Text("3秒").tag(3)
                        Text("5秒").tag(5)
                        Text("10秒").tag(10)
                    }
                }

                Section(header: Text("其他设置")) {
                    Toggle("启用快门声", isOn: .constant(true))
                    Toggle("启用振动反馈", isOn: .constant(true))
                }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// 图片编辑视图（占位实现）
struct ImageEditorView: View {
    let image: UIImage
    @Binding var recentPhotos: [UIImage]
    @Binding var captureCount: Int
    @Binding var showLoading: Bool
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color.white
                .edgesIgnoringSafeArea(.all)

            VStack {
                // 图片预览
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: UIScreen.main.bounds.height * 0.6)

                // 编辑工具区域
                Text("图片编辑工具")
                    .padding()

                // 保存按钮
                Button(action: {
                    saveImage()
                }) {
                    Text("保存")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 250, height: 50)
                        .background(Color.black)
                        .cornerRadius(25)
                }
                .padding(.top, 40)
            }
        }
    }

    // 保存图片到相册和最近照片列表
    private func saveImage() {
        // 添加到最近照片列表
        recentPhotos.insert(image, at: 0)
        // 限制最近照片数量为4
        if recentPhotos.count > 4 {
            recentPhotos.removeLast()
        }

        // 保存到相册
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)

        // 更新拍摄计数
        captureCount += 1

        // 关闭编辑视图
        dismiss()

        // 检查是否拍满4张
        if captureCount >= 4 {
            // 显示加载动画
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showLoading = true

                // 模拟加载过程
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    // 这里应该跳转到动画加载页
                    showLoading = false
                    // 返回到主界面
                    UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
}

// 扩展UIDevice以支持触觉反馈
extension UIDevice {
    enum HapticFeedback {
        case impact
        case selection
        case notification
    }

    func playHapticFeedback(_ type: HapticFeedback) {
        switch type {
        case .impact:
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        case .selection:
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
        case .notification:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }
}

#Preview {
    CameraView(recentPhotos: .constant([]))
}

// 相机预览视图
struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.frame
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

// 照片捕获委托
extension CameraView: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            DispatchQueue.main.async {_
                self.errorMessage = "拍照失败: \(error.localizedDescription)"
                self.showError = true
            }
            return
        }

        guard let imageData = photo.fileDataRepresentation() else {_
            DispatchQueue.main.async {_
                self.errorMessage = "无法处理照片数据"
                self.showError = true
            }
            return
        }

        if let image = UIImage(data: imageData) {_
            DispatchQueue.main.async {_
                self.capturedImage = image
                self.showImageEditor = true
            }
        }
    }
}