//  PermissionView.swift
//  my4cuts
//
//  Created by AI Assistant on 2025/9/7.
//

import SwiftUI
import AVFoundation
import Photos
import UIKit

struct PermissionView: View {
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Binding var isActive: Bool
    @State private var navigateToMain = false

    var body: some View {
        ZStack {
            // 背景色
            Color.white
                .edgesIgnoringSafeArea(.all)

            VStack {
                // 标题
                Text("需要您的权限")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.bottom, 20)
                    .padding(.top, 40)

                // 描述
                Text("My4Cuts需要访问您的相机和相册以捕捉和编辑照片")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 40)

                // 图标
                Image(systemName: "camera.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.black)
                    .padding(.bottom, 40)

                // 按钮区域
                VStack(spacing: 20) {
                    // 允许按钮
                    Button(action: {
                        requestPermissions()
                    }) {
                        Text("允许")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 250, height: 50)
                            .background(Color.black)
                            .cornerRadius(25)
                    }

                    // 不允许按钮
                    Button(action: {
                        alertMessage = "没有相机和相册权限，应用将无法正常工作。请在设置中启用权限。"
                        showAlert = true
                    }) {
                        Text("不允许")
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
                .padding(.bottom, 40)
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
        .fullScreenCover(isPresented: $navigateToMain) {
            ContentView()
        }
    }

    // 请求权限
    private func requestPermissions() {
        // 先请求相机权限
        AVCaptureDevice.requestAccess(for: .video) { cameraGranted in
            if cameraGranted {
                // 相机权限已授予，请求相册权限
                PHPhotoLibrary.requestAuthorization { photoStatus in
                    if photoStatus == .authorized {
                        // 两个权限都已授予
                        DispatchQueue.main.async {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                isActive = false
                                navigateToMain = true
                            }
                        }
                    } else {
                        // 相册权限未授予
                        DispatchQueue.main.async {
                            alertMessage = "没有相册权限，应用将无法保存和访问照片。请在设置中启用权限。"
                            showAlert = true
                        }
                    }
                }
            } else {
                // 相机权限未授予
                DispatchQueue.main.async {
                    alertMessage = "没有相机权限，应用将无法拍照。请在设置中启用权限。"
                    showAlert = true
                }
            }
        }
    }
}