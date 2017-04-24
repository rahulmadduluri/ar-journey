//
//  ViewController.swift
//  iOS-ar-journey
//
//  Created by Rahul Madduluri on 4/23/17.
//  Copyright © 2017 rahulm. All rights reserved.
//

import UIKit
import KudanAR

enum ArbiTrackState {
    case ARBI_PLACEMENT
    case ARBI_TRACKING
}

enum ObjectType {
    case model
    case video
}

class ViewController: ARCameraViewController {
    
    var modelNode: ARModelNode?
    var videoNode: ARVideoNode?
    
    var lastScale: Float = 0
    var lastPanX: Float = 0
    
    var arbiTrackingState: ArbiTrackState = .ARBI_PLACEMENT
    var objectType: ObjectType = .video
    
    // UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setupButtons()
    }
    

    // setup
    
    override func setupContent() {
        setupModel()
        setupVideo()
        setupArbiTrack()
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(arbiPinch(_:)))
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(arbiPan(_:)))
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(arbiTap(_:)))
        
        cameraView.addGestureRecognizer(pinchGestureRecognizer)
        cameraView.addGestureRecognizer(panGestureRecognizer)
        cameraView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // gesture handlers
    
    func arbiPinch(_ gesture: UIPinchGestureRecognizer) {
        var scaleFactor: Float = Float(gesture.scale)
        if (gesture.state == .began) {
            lastScale = 1
        }
        scaleFactor = 1 - (lastScale - scaleFactor)
        lastScale = Float(gesture.scale)
        
        synchronize(lockObj: ARRenderer.getInstance()) { 
            switch objectType {
            case .model:
                self.modelNode?.scale(byUniform: scaleFactor)
            case .video:
                self.videoNode?.scale(byUniform: scaleFactor)
            }
        }
    }
    
    func arbiPan(_ gesture: UIPanGestureRecognizer) {
        let x: Float = Float(gesture.translation(in: cameraView).x)
        
        if (gesture.state == .began) {
            lastPanX = x
        }
        let diff = x - lastPanX
        let deg = diff * 0.5
        
        synchronize(lockObj: ARRenderer.getInstance()) {
            switch objectType {
            case .model:
                self.modelNode?.rotate(byDegrees: deg, axisX: 0, y: 1, z: 0)
            case .video:
                self.videoNode?.rotate(byDegrees: deg, axisX: 0, y: 1, z: 0)
            }
        }
        
        lastPanX = x
    }
    
    func arbiTap(_ gesture: UITapGestureRecognizer) {
        let arbiTrack: ARArbiTrackerManager = ARArbiTrackerManager.getInstance()
        if (arbiTrackingState == .ARBI_PLACEMENT) {
            guard let targetNode = arbiTrack.targetNode else {
                print("ERROR: failed to start tracking")
                return
            }
            arbiTrack.start()
            targetNode.visible = false
            
            switch objectType {
            case .model:
                modelNode?.scale = Constants.initialModelScale
            case .video:
                videoNode?.scale(byUniform: Constants.initialVideoModelScale)
            }
            
            arbiTrackingState = .ARBI_TRACKING
            print("Start Tracking")
        }
        else if (arbiTrackingState == .ARBI_TRACKING) {
            arbiTrack.stop()
            arbiTrack.targetNode.visible = true
            arbiTrackingState = .ARBI_PLACEMENT
            print("End Tracking")
        }
    }
    
    func videoWasTouched(_ gesture: UITapGestureRecognizer) {
        videoNode?.reset()
        videoNode?.play()
    }
    
    func videoButtonTapped(_ gesture: UITapGestureRecognizer) {
        let arbiTrack: ARArbiTrackerManager = ARArbiTrackerManager.getInstance()

        guard let modelNode = modelNode else { return }
        guard let videoNode = videoNode else { return }
        
        arbiTrack.world.removeChild(modelNode)

        let children = arbiTrack.world.children
        if (children?.contains(videoNode) == true) {
            videoNode.reset()
            videoNode.play()
        } else {
            arbiTrack.world.addChild(videoNode)
        }
        
        objectType = .video
    }
    
    func modelButtonTapped(_ gesture: UITapGestureRecognizer) {
        let arbiTrack: ARArbiTrackerManager = ARArbiTrackerManager.getInstance()
        
        guard let modelNode = modelNode else { return }
        guard let videoNode = videoNode else { return }
        
        videoNode.reset()
        arbiTrack.world.removeChild(videoNode)

        let children = arbiTrack.world.children
        if (children?.contains(modelNode) == false) {
            arbiTrack.world.addChild(modelNode)
        }
        
        objectType = .model
    }
    
    // private functions
    
    private func setupModel() {
        guard let importer = ARModelImporter(bundled: "big_ben.armodel"),
            let textureImage = UIImage(named: "big_ben.png"),
            let tempModelNode = importer.getNode() else {
            print("ERROR: FAILED TO GET MODEL")
            return
        }
        
        // Set up and add material to model.
        
        let material = ARLightMaterial()
        material.colour.texture = ARTexture(uiImage: textureImage)
        material.diffuse.value = ARVector3(valuesX: 0.2, y: 0.2, z: 0.2)
        material.ambient.value = ARVector3(valuesX: 0.8, y: 0.8, z: 0.8)
        material.specular.value = ARVector3(valuesX: 0.3, y: 0.3, z: 0.3)
        material.shininess = 20
        material.reflection.reflectivity = 0.15
        
        let meshNodes = tempModelNode.meshNodes.flatMap { $0 as? ARMeshNode }
        for meshNode in meshNodes {
            meshNode.material = material
        }
        
        self.modelNode = tempModelNode
    }
    
    private func setupVideo() {
        videoNode = ARVideoNode(bundledFile: "star_wars_trailer.mp4")
        guard let videoNode = videoNode else {
            print("ERROR: Failed to setup video")
            return
        }
        
        videoNode.scale(byUniform: 0.35)
        videoNode.rotate(byDegrees: 0, axisX: 0, y: 0, z: 1)
        videoNode.play()
        videoNode.videoTextureMaterial.fadeInTime = 1
        videoNode.videoTexture.resetThreshold = 21
        //videoNode.addTouchTarget(self, withAction: #selector(videoWasTouched(_:)))
    }
    
    private func setupButtons() {
        let videoButton = UIButton(frame: CGRect(x: 75, y: 500, width: 90, height: 40))
        videoButton.backgroundColor = UIColor.black
        videoButton.setTitleColor(UIColor.white, for: .normal)
        videoButton.setTitle("Video", for: .normal)
        videoButton.addTarget(self, action: #selector(videoButtonTapped(_:)), for: .touchUpInside)
        let modelButton = UIButton(frame: CGRect(x: 225, y: 500, width: 90, height: 40))
        modelButton.backgroundColor = UIColor.black
        modelButton.setTitleColor(UIColor.white, for: .normal)
        modelButton.setTitle("Model", for: .normal)
        modelButton.addTarget(self, action: #selector(modelButtonTapped(_:)), for: .touchUpInside)
        
        view.addSubview(videoButton)
        view.addSubview(modelButton)
    }
    
    private func setupArbiTrack() {
        // Initialise gyro placement. Gyro placement positions content on a virtual floor plane where the device is aiming.
        guard let gyroPlaceManager = ARGyroPlaceManager.getInstance(),
            let targetImage = UIImage(named: "target.png"),
            let targetNode = ARNode(name: "targetNode"),
            let targetImageNode = ARImageNode(image: targetImage),
            let arbiTrack = ARArbiTrackerManager.getInstance() else {
            print("ERROR: Setup Arbi Track FAILED")
            return
        }
        
        // Set up the target node on which the object is placed.
        gyroPlaceManager.initialise()
        gyroPlaceManager.world.addChild(targetNode)
        
        // Add a visual reticule to the target node for the user
        targetNode.addChild(targetImageNode)
        
        // Scale and rotate the image to correct transformation
        targetImageNode.scale(byUniform: 0.1)
        targetImageNode.rotate(byDegrees: 90, axisX: 1, y: 0, z: 0)
        
        arbiTrack.initialise()
        arbiTrack.targetNode = targetNode
        
        switch objectType {
        case .model:
            guard let modelNode = modelNode else { return }
            arbiTrack.world.addChild(modelNode)
        case .video:
            guard let videoNode = videoNode else { return }
            arbiTrack.world.addChild(videoNode)
        }
    }
    
    private func synchronize(lockObj: AnyObject!, closure: ()->()){
        objc_sync_enter(lockObj)
        closure()
        objc_sync_exit(lockObj)
    }
    
}

private class Constants {
    static let initialModelScale: ARVector3 = ARVector3(valuesX: 0.03, y: 0.03, z: 0.03)
    static let initialVideoModelScale: Float = 0.5
}

