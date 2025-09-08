//
//  ContentView.swift
//  my4cuts001
//
//  Created by 黄炫凱 on 2025/9/4.
//

import SwiftUI
import PhotosUI
import AVFoundation
import UIKit

struct ContentView: View {
    @State private var showCamera = false
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var recentPhotos: [UIImage] = []
    @State private var showImageEditor = false
    @State private var imageToEdit: UIImage? = nil
    @State private var showAlert = false
    @State private var alertMessage = ""

    // 权限状态键
    private let cameraPermissionKey = "CameraPermissionDenied"
    private let photoPermissionKey = "PhotoPermissionDenied"

    var body: some View {
        ZStack {
            // 背景色
            Color.white
                .edgesIgnoringSafeArea(.all)

            VStack {
                // 顶部标题
                Text("my4cuts")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.top, 40)
                    .padding(.bottom, 60)

                // 主要内容区域
                VStack(spacing: 40) {
                    // 提示文本
                    Text("创建你的专属照片")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)

                    // 相机图标
                    Image(systemName: "camera.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.black)

                    // 操作按钮区域
                    VStack(spacing: 20) {
                        // 拍照按钮
                    Button(action: {
                        checkCameraPermission()
                    }) {
                            Text("拍照")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width: 250, height: 50)
                                .background(Color.black)
                                .cornerRadius(25)
                        }

                        // 选择照片按钮
                    Button(action: {
                        checkPhotoPermission()
                    }) {
                            Text("从相册选择")
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(width: 250, height: 50)
                            .background(Color.white)
                            .cornerRadius(25)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.black, lineWidth: 2)
                            )
                    }
                    }
                }

                // 最近照片预览区域
                if !recentPhotos.isEmpty {
                    VStack {
                        Text("最近编辑")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.top, 40)
                            .padding(.bottom, 10)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(recentPhotos, id: \.self) { 
                                    photo in
                                    Image(uiImage: photo)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 80, height: 80)
                                        .cornerRadius(8)
                                        .onTapGesture {
                                            imageToEdit = photo
                                            showImageEditor = true
                                        }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }

                Spacer()
            }

            // 右下角水印
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
        }
                // 权限检查相关方法
        private func checkCameraPermission() {
            // 检查相机权限状态
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            
            switch status {
            case .authorized:
                // 有权限，直接打开相机
                showCamera = true
            case .notDetermined:
                // 未请求过权限，请求权限
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    DispatchQueue.main.async {
                        if granted {
                            showCamera = true
                        } else {
                            // 记录拒绝状态
                            UserDefaults.standard.set(true, forKey: cameraPermissionKey)
                            showPermissionAlert(message: "没有相机权限，应用将无法拍照。请在设置中启用权限。")
                        }
                    }
                }
            case .denied, .restricted:
                // 已拒绝或受限制，显示提示
                showPermissionAlert(message: "没有相机权限，应用将无法拍照。请在设置中启用权限。")
            @unknown default:
                break
            }
        }
        
        private func checkPhotoPermission() {
            // 检查相册权限状态
            let status = PHPhotoLibrary.authorizationStatus()
            
            switch status {
            case .authorized:
                // 有权限，打开相册选择器
                // 由于我们替换了PhotosPicker为Button，这里使用一个临时解决方案
                // 在实际应用中，可能需要重新设计UI以结合权限检查和PhotosPicker
                showAlert = true
                alertMessage = "相册权限已授予，请使用系统相册应用选择照片后返回。"
            case .notDetermined:
                // 未请求过权限，请求权限
                PHPhotoLibrary.requestAuthorization { status in
                    DispatchQueue.main.async {
                        if status == .authorized {
                            // 有权限后，提示用户
                            showAlert = true
                            alertMessage = "相册权限已授予，请使用系统相册应用选择照片后返回。"
                        } else {
                            // 记录拒绝状态
                            UserDefaults.standard.set(true, forKey: photoPermissionKey)
                            showPermissionAlert(message: "没有相册权限，应用将无法访问照片。请在设置中启用权限。")
                        }
                    }
                }
            case .denied, .restricted:
                // 已拒绝或受限制，显示提示
                showPermissionAlert(message: "没有相册权限，应用将无法访问照片。请在设置中启用权限。")
            @unknown default:
                break
            }
        }
        
        private func showPermissionAlert(message: String) {
            alertMessage = message
            showAlert = true
        }
    }
    .alert(isPresented: $showAlert) {
        Alert(
            title: Text("权限请求"),
            message: Text(alertMessage),
            primaryButton: .default(Text("前往设置")) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            },
            secondaryButton: .cancel(Text("取消"))
        )
    }
    .onChange(of: selectedPhoto) {
            Task {
                if let data = try? await selectedPhoto?.loadTransferable(type: Data.self) {
                    if let image = UIImage(data: data) {
                        imageToEdit = image
                        showImageEditor = true
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraView(recentPhotos: $recentPhotos)
        }
        .onAppear {
            // 检查是否有权限被拒绝的记录
            checkPermissionStatus()
        }
        
        // 检查权限状态的方法
        private func checkPermissionStatus() {
            // 检查相机权限是否被拒绝
            if UserDefaults.standard.bool(forKey: cameraPermissionKey) {
                // 显示提示，但不强制用户立即去设置
                // 我们会在用户点击相机按钮时再次提示
            }
            
            // 检查相册权限是否被拒绝
            if UserDefaults.standard.bool(forKey: photoPermissionKey) {
                // 显示提示，但不强制用户立即去设置
                // 我们会在用户点击相册按钮时再次提示
            }
        }
        .fullScreenCover(isPresented: $showImageEditor) {
            // 图片编辑视图将在这里实现
