# My4Cuts 项目

这是一个移动端拍照应用的预览版本，提供了相机界面、权限请求和快门声音控制等功能。

## 项目结构

```
├── preview.html       # 主预览页面，包含相机界面和功能实现
├── test_sound.html    # 声音测试页面
├── sounds/            # 声音资源目录
│   └── dispense.wav   # 快门声音文件
├── images/            # 图像资源目录
│   ├── preview_placeholder.png
│   └── preview_placeholder.svg
├── js/                # JavaScript库目录
│   └── lottie.min.js  # Lottie动画库
└── README.md          # 项目说明文档
```

## 功能说明

### preview.html
- 启动页动画展示
- 相机和相册权限请求
- 相机界面（模拟）
- 倒计时拍摄功能（关闭/3秒/6秒）
- 快门声音开关
- 前后摄像头切换（模拟）
- 相册功能入口
- 顶部下滑设置面板

### test_sound.html
- 声音播放测试工具
- 支持文件声音播放和Base64编码声音播放
- 声音文件检查功能
- 详细的日志输出

## 使用方法

1. 在本地启动HTTP服务器（如Python的内置服务器）：
   ```
   python -m http.server
   ```

2. 访问以下地址查看页面：
   - 主预览页面: http://localhost:8000/preview.html
   - 声音测试页面: http://localhost:8000/test_sound.html

## 注意事项

- 由于浏览器的自动播放策略限制，声音需要用户交互后才能播放
- 相机功能是模拟实现的，实际应用中需要使用真实的相机API
- 在移动设备上查看效果最佳

## 技术栈

- HTML5
- Tailwind CSS
- JavaScript
- Font Awesome 图标
- Lottie 动画库（可选）

## 开发说明

- 项目采用响应式设计，支持不同尺寸的移动设备
- 界面遵循现代极简主义风格
- 动画效果使用CSS实现，确保流畅的用户体验
- 声音播放提供了错误处理和备选方案