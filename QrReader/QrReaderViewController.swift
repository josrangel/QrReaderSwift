//
//  QrReaderViewController.swift
//  QrReader
//
//  Created by jrangel on 18/01/21.
//

import UIKit
import AVFoundation

class QrReaderViewController: UIViewController {

    // MARK: - Variables

    lazy var overlayView: UIView = {
        let readerOverlayView = ReaderOverlayView()
        readerOverlayView.backgroundColor = .clear
        readerOverlayView.clipsToBounds = true
        readerOverlayView.translatesAutoresizingMaskIntoConstraints = false
        return readerOverlayView
    }()
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .allButUpsideDown
    }

    // MARK: - Initiliazers

    private let containerView = UIView()
    private var captureSession = AVCaptureSession()
    private var previewLayer = AVCaptureVideoPreviewLayer()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            return
        }
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            initCamera(avCaptureDeviceInput: videoInput)
            configurationViews()
            drawDottedLine()
        } catch {
            print("error: ")
            showErrorCameraPermission()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard verifyAuthorizedPermissionCamera() else {
            print("false cam")
            showErrorCameraPermission()
            return
        }
        if captureSession.isRunning == false {
            captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if captureSession.isRunning == true {
            captureSession.stopRunning()
        }
    }

    // MARK: - Functions

    func initCamera(avCaptureDeviceInput: AVCaptureDeviceInput) {
        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddInput(avCaptureDeviceInput) {
            captureSession.addInput(avCaptureDeviceInput)
        } else {
            return
        }
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            return
        }
        captureSession.startRunning()
    }

    func configurationViews() {
        view.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        containerView.layer.addSublayer(previewLayer)
    }

    private func drawDottedLine() {
        containerView.addSubview(overlayView)
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        overlayView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        overlayView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        overlayView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }

    private func foundResult(code: String) {
        print(code)
        showResultQR(result: code)
    }

    private func showErrorCameraPermission() {
        showAlertPermission(title: "alertTitle".localized,
                            message: "cameraMicPermission".localized,
                            btnMessage: "accept".localized)
    }

    private func showResultQR(result: String) {
        showAlert(title: "alertTitle".localized,
                  message: result.localized,
                  btnMessage: "accept".localized)
    }

    private func showAlert(title: String, message: String, btnMessage: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: btnMessage,
                                      style: UIAlertAction.Style.default) { _ in
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

// MARK: - Extensions

extension QrReaderViewController: AVCaptureMetadataOutputObjectsDelegate{
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {

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
    }
}
