//
//  QrReaderViewController.swift
//  QrReader
//
//  Created by jrangel on 18/01/21.
//

import UIKit
import AVFoundation

class QrReaderViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate{
    

    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    lazy var overlayView: UIView = {
        let ov = ReaderOverlayView()

        ov.backgroundColor                           = .clear
        ov.clipsToBounds                             = true
        ov.translatesAutoresizingMaskIntoConstraints = false

        return ov
    }()

    let cameraView: UIView = {
        let cv = UIView()

        cv.clipsToBounds                             = true
        cv.translatesAutoresizingMaskIntoConstraints = false

        return cv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            initCamera(avCaptureDeviceInput: videoInput)
        } catch {
            print("error: ")
            showErrorCameraPermission()
        }
        
    }
    
    func initCamera(avCaptureDeviceInput: AVCaptureDeviceInput) {
        

        if captureSession.canAddInput(avCaptureDeviceInput) {
            captureSession.addInput(avCaptureDeviceInput)
        } else {
            // TODO: force a error to prove failed()
            failedCaptureSession()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failedCaptureSession()
            return
        }
        drawDottedLine()
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        
        // TODO: add constraints preview layer
        captureSession.startRunning()
        
    }

    func failedCaptureSession() {
        captureSession = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard verifyAuthorizedPermissionCamera() else {
            print("false cam")
            showErrorCameraPermission()
            return
        }
        
        if captureSession?.isRunning == false {
            captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if captureSession?.isRunning == true {
            captureSession.stopRunning()
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else {
                print("not readableObject")
                return
                
            }
            guard let stringValue = readableObject.stringValue else {
                print("not stringValue")
                return
            }
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            foundResult(code: stringValue)
        }

        //dismiss(animated: true)
    }

    func foundResult(code: String) {
        print(code)
        showResultQR(result: code)
    }
    
    func drawDottedLine() {
        self.view.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(cameraView)
        self.view.addSubview(overlayView)
        
        
        for attribute in Array<NSLayoutConstraint.Attribute>([.left, .top, .right, .bottom]) {
            self.view.addConstraint(NSLayoutConstraint(item: overlayView, attribute: attribute, relatedBy: .lessThanOrEqual,
                                             toItem: cameraView, attribute: attribute, multiplier: 1, constant: 0))
        }
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .allButUpsideDown
    }
    
    private func showErrorCameraPermission(){
        showAlertPermission(title: "alertTitle".localized, message: "cameraMicPermission".localized, btnMessage: "accept".localized);
        
        
    }
    
    private func showResultQR(result: String){
        showAlert(title: "alertTitle".localized, message: result.localized, btnMessage: "accept".localized);
    }
    
    private func showAlert(title: String, message: String, btnMessage: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: btnMessage, style: UIAlertAction.Style.default) { _ in
            self.navigationController?.popViewController(animated: true)
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showAlertPermission(title: String, message: String, btnMessage: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            
        alert.addAction(UIAlertAction(title: btnMessage, style: UIAlertAction.Style.default) { _ in
            //self.navigationController?.popViewController(animated: true)
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!) {_ in
                self.navigationController?.popViewController(animated: true)
                //dismiss(animated: true) 
            }
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    
    private func verifyAuthorizedPermissionCamera() -> Bool {
        let avVideo = AVMediaType(rawValue: AVMediaType.video.rawValue)
        let cameraStatus = AVCaptureDevice.authorizationStatus(for: avVideo)
        return cameraStatus == .authorized
    }


}
