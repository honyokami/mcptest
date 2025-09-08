//
//  SplashView.swift
//  my4cuts001
//
//  Created by 黄炫凱 on 2025/9/4.
//

import SwiftUI

struct SplashView: View {
    @State private var showPermissionView = false
    @State private var opacity = 0.0

    var body: some View {
        VStack {
            if showPermissionView {
                PermissionView(isActive: $showPermissionView)
            } else {
                ZStack {
                    // 背景色
                    Color.white
                        .edgesIgnoringSafeArea(.all)

                    VStack {
                        // App Logo
                        Image(systemName: "camera.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.black)

                        // App Name
                        Text("my4cuts")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .padding(.top, 20)
                    }
                    .opacity(opacity)
                }
            }
        }
        .onAppear {
            // 渐入动画
            withAnimation(.easeInOut(duration: 0.8)) {
                opacity = 1.0
            }

            // 2秒后跳转
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showPermissionView = true
                }
            }
        }
    }
}