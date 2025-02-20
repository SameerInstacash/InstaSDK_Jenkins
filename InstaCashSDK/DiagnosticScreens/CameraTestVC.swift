//
//  CameraTestVC.swift
//  InstaCashSDK
//
//  Created by Sameer Khan on 18/02/25.
//

import UIKit
import AVFoundation

class CameraTestVC: UIViewController, AVCapturePhotoCaptureDelegate {
    
    var isPhotoClick : ((_ click:Bool) -> Void)?
    
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var captureButton: UIButton!
    
    private let photoOutput = AVCapturePhotoOutput()
    var cameraLayer : AVCaptureVideoPreviewLayer?
    var captureSession: AVCaptureSession?
    var cameraDevice: AVCaptureDevice?
    
    var isComeFrom = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch isComeFrom {
        case "1":
            frontCameraClick()
        case "2":
            backCamera1Click()
        case "3":
            backCamera2Click()
        default:
            backCamera3Click()
        }
        
    }
    
    @IBAction func cameraDismiss(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: {
                guard let click = self.isPhotoClick else { return }
                click(false)
            })
        }
    }
    
    @IBAction func handleTakePhoto(_ sender: UIButton) {
        let photoSettings = AVCapturePhotoSettings()
        if photoSettings.availablePreviewPhotoPixelFormatTypes.first != nil {
            //photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoPreviewType]
            photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }
    
    func frontCameraClick() {
        
        self.captureSession = AVCaptureSession()
        
        if let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front) {
            
            do {
                let input = try AVCaptureDeviceInput(device: captureDevice)
                if ((captureSession?.canAddInput(input)) != nil) {
                    captureSession?.addInput(input)
                }
            } catch let error {
                print("Failed to set input device with error: \(error)")
            }
            
            
            if ((captureSession?.canAddOutput(photoOutput)) != nil) {
                captureSession?.addOutput(photoOutput)
            }
            
            
            let cameraLayer = AVCaptureVideoPreviewLayer(session: captureSession ?? AVCaptureSession())
            cameraLayer.frame = self.view.frame
            cameraLayer.videoGravity = .resizeAspectFill
            self.view.layer.addSublayer(cameraLayer)
            
            self.view.bringSubviewToFront(self.overlayView)
            self.view.bringSubviewToFront(self.closeButton)
            
            DispatchQueue.global(qos: .background).async(execute: {
                self.captureSession?.startRunning()
            })
            
        }
        
    }
    
    func backCamera1Click() {
        
        self.captureSession = AVCaptureSession()
        
        if let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back) {
            
            do {
                let input = try AVCaptureDeviceInput(device: captureDevice)
                if ((captureSession?.canAddInput(input)) != nil) {
                    captureSession?.addInput(input)
                }
            } catch let error {
                print("Failed to set input device with error: \(error)")
            }
            
            if ((captureSession?.canAddOutput(photoOutput)) != nil) {
                captureSession?.addOutput(photoOutput)
            }
            
            let cameraLayer = AVCaptureVideoPreviewLayer(session: captureSession ?? AVCaptureSession())
            cameraLayer.frame = self.view.frame
            cameraLayer.videoGravity = .resizeAspectFill
            self.view.layer.addSublayer(cameraLayer)
            
            self.view.bringSubviewToFront(self.overlayView)
            self.view.bringSubviewToFront(self.closeButton)
            
            DispatchQueue.global(qos: .background).async(execute: {
                self.captureSession?.startRunning()
            })
            
        }
    }
    
    func backCamera2Click() {
        
        self.captureSession = AVCaptureSession()
        
        if let captureDevice = AVCaptureDevice.default(.builtInUltraWideCamera, for: AVMediaType.video, position: .back) {
            
            do {
                let input = try AVCaptureDeviceInput(device: captureDevice)
                if ((captureSession?.canAddInput(input)) != nil) {
                    captureSession?.addInput(input)
                }
            } catch let error {
                print("Failed to set input device with error: \(error)")
            }
            
            if ((captureSession?.canAddOutput(photoOutput)) != nil) {
                captureSession?.addOutput(photoOutput)
            }
            
            let cameraLayer = AVCaptureVideoPreviewLayer(session: captureSession ?? AVCaptureSession())
            cameraLayer.frame = self.view.frame
            cameraLayer.videoGravity = .resizeAspectFill
            self.view.layer.addSublayer(cameraLayer)
            
            self.view.bringSubviewToFront(self.overlayView)
            self.view.bringSubviewToFront(self.closeButton)
            
            DispatchQueue.global(qos: .background).async(execute: {
                self.captureSession?.startRunning()
            })
            
        }
    }
    
    func backCamera3Click() {
        
        self.captureSession = AVCaptureSession()
        
        if let captureDevice = AVCaptureDevice.default(.builtInTelephotoCamera, for: AVMediaType.video, position: .back) {
            
            do {
                let input = try AVCaptureDeviceInput(device: captureDevice)
                if ((captureSession?.canAddInput(input)) != nil) {
                    captureSession?.addInput(input)
                }
            } catch let error {
                print("Failed to set input device with error: \(error)")
            }
            
            if ((captureSession?.canAddOutput(photoOutput)) != nil) {
                captureSession?.addOutput(photoOutput)
            }
            
            let cameraLayer = AVCaptureVideoPreviewLayer(session: captureSession ?? AVCaptureSession())
            cameraLayer.frame = self.view.frame
            cameraLayer.videoGravity = .resizeAspectFill
            self.view.layer.addSublayer(cameraLayer)
            
            self.view.bringSubviewToFront(self.overlayView)
            self.view.bringSubviewToFront(self.closeButton)
            
            DispatchQueue.global(qos: .background).async(execute: {
                self.captureSession?.startRunning()
            })
            
        }
    }
    
    //MARK: AVCapturePhotoOutput Delegate
    func photoOutput(_ output: AVCapturePhotoOutput, willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        print("willBeginCaptureFor")
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        print("didFinishProcessingPhoto")
        
        self.dismiss(animated: false, completion: {
            guard let click = self.isPhotoClick else { return }
            click(true)
        })
        
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
}
