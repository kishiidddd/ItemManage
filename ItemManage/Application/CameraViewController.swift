//import UIKit
//import AVFoundation
//import Vision
//
//class CameraViewController: UIViewController {
//    // UI 组件
//    private let previewView = UIView()
//    private let resultLabel = UILabel()
//    
//    // 相机相关
//    private let session = AVCaptureSession()
//    private let sessionQueue = DispatchQueue(label: "sessionQueue")
//    private var previewLayer: AVCaptureVideoPreviewLayer?
//    
//    // Vision 请求
//    private lazy var classificationRequest: VNClassifyImageRequest = {
//        let request = VNClassifyImageRequest { request, error in
//            if let results = request.results as? [VNClassificationObservation] {
//                // 在主线程更新UI
//                DispatchQueue.main.async {
//                    // 取置信度 > 30% 的第一个结果
//                    if let top = results.first(where: { $0.confidence > 0.3 }) {
//                        self.resultLabel.text = "📦 \(top.identifier) (\(Int(top.confidence * 100))%)"
//                    } else {
//                        self.resultLabel.text = "🔍 未识别到物品"
//                    }
//                }
//            }
//        }
//        // 只返回前5个结果，提高性能
////        request.resultsLevel = .top5
//        return request
//    }()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        setupCamera()
//    }
//    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        previewLayer?.frame = previewView.bounds
//    }
//    
//    // MARK: - UI 设置
//    private func setupUI() {
//        view.backgroundColor = .black
//        
//        // 相机预览层容器
//        previewView.frame = view.bounds
//        previewView.backgroundColor = .black
//        view.addSubview(previewView)
//        
//        // 结果标签 - 悬浮在顶部
//        resultLabel.frame = CGRect(x: 20, y: view.safeAreaInsets.top + 20,
//                                  width: view.bounds.width - 40, height: 50)
//        resultLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
//        resultLabel.textColor = .white
//        resultLabel.textAlignment = .center
//        resultLabel.font = .systemFont(ofSize: 18, weight: .medium)
//        resultLabel.layer.cornerRadius = 12
//        resultLabel.layer.masksToBounds = true
//        resultLabel.text = "🔍 正在识别..."
//        view.addSubview(resultLabel)
//    }
//    
//    // MARK: - 相机设置
//    private func setupCamera() {
//        sessionQueue.async { [weak self] in
//            guard let self = self else { return }
//            
//            // 1. 获取摄像头
//            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera,
//                                                       for: .video,
//                                                       position: .back) else { return }
//            
//            do {
//                // 2. 配置输入
//                let input = try AVCaptureDeviceInput(device: device)
//                if self.session.canAddInput(input) {
//                    self.session.addInput(input)
//                }
//                
//                // 3. 配置输出 - 视频帧
//                let output = AVCaptureVideoDataOutput()
//                output.setSampleBufferDelegate(self, queue: self.sessionQueue)
//                if self.session.canAddOutput(output) {
//                    self.session.addOutput(output)
//                }
//                
//                // 4. 设置预览层
//                DispatchQueue.main.async {
//                    self.previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
//                    self.previewLayer?.videoGravity = .resizeAspectFill
//                    self.previewView.layer.addSublayer(self.previewLayer!)
//                }
//                
//                // 5. 启动会话
//                self.session.startRunning()
//            } catch {
//                print("相机初始化失败: \(error)")
//            }
//        }
//    }
//}
//
//// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
//extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
//    func captureOutput(_ output: AVCaptureOutput,
//                      didOutput sampleBuffer: CMSampleBuffer,
//                      from connection: AVCaptureConnection) {
//        // 从缓冲区获取图像
//        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
//        
//        // 执行 Vision 请求
//        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .right)
//        try? handler.perform([classificationRequest])
//    }
//}
