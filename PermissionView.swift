//
//  PermissionView.swift
//  my4cuts001
//
//  Created by 黄炫凱 on 2025/9/4.
//

import SwiftUI
import AVFoundation
import Photos
import UIKit

struct PermissionView: View {
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Binding var showPermissionView: Bool
    @State private var navigateToMain = false

    var body: some View {
        ZStack {
            // 背景色
            Color.white
                .edgesIgnoringSafeArea(.all)

            VStack {
                // 标题
                Text("需要您的授权")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.bottom, 20)
                    .padding(.top, 40)

                // 描述
                Text("My4Cuts需要使用相机和相册来拍摄和制作人生四格照片")
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
                    // 好按钮
                    Button(action: {
                        requestPermissions()
                    }) {
                        Text("好")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 250, height: 50)
                            .background(Color.black)
                            .cornerRadius(25)
                    }

                    // 不允许按钮
                    Button(action: {
                        // 记录拒绝状态
                        let cameraPermissionKey = "CameraPermissionDenied"
                        let photoPermissionKey = "PhotoPermissionDenied"
                        UserDefaults.standard.set(true, forKey: cameraPermissionKey)
                        UserDefaults.standard.set(true, forKey: photoPermissionKey)
                        
                        // 跳转到主相机页面
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showPermissionView = false
                            navigateToMain = true
                        }
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
        // 记录权限状态的键
        let cameraPermissionKey = "CameraPermissionDenied"
        let photoPermissionKey = "PhotoPermissionDenied"
        
        // 先请求相机权限
        AVCaptureDevice.requestAccess(for: .video) { cameraGranted in
            // 记录相机权限状态
            if !cameraGranted {
                UserDefaults.standard.set(true, forKey: cameraPermissionKey)
            }
            
            // 请求相册权限
            PHPhotoLibrary.requestAuthorization { photoStatus in
                // 记录相册权限状态
                if photoStatus != .authorized {
                    UserDefaults.standard.set(true, forKey: photoPermissionKey)
                }
                
                // 无论权限是否授予，都跳转到主相机页面
                DispatchQueue.main.async {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showPermissionView = false
                        navigateToMain = true
                    }
                }
            }
        }
    }
}