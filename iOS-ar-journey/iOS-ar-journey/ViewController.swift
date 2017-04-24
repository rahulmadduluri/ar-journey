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

class ViewController: ARCameraViewController {
    
    var modelNode: ARModelNode?
    
    var lastScale: Float = 0
    var lastPanX: Float = 0
    var arbiButtonState: ArbiTrackState = .ARBI_PLACEMENT
    
    // UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // setup
    
    override func setupContent() {
        setupModel()
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
            self.modelNode?.scale(byUniform: scaleFactor)
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
            self.modelNode?.rotate(byDegrees: deg, axisX: 0, y: 1, z: 0)
        }
        
        lastPanX = x
    }
    
    func arbiTap(_ gesture: UITapGestureRecognizer) {
        let arbiTrack: ARArbiTrackerManager = ARArbiTrackerManager.getInstance()
        if (arbiButtonState == .ARBI_PLACEMENT) {
            arbiTrack.start()
            arbiTrack.targetNode.visible = false
            modelNode?.scale = ARVector3(valuesX: 1, y: 1, z: 1)
            arbiButtonState = .ARBI_TRACKING
            print("TRACKINGTRACKING")
        }
        else if (arbiButtonState == .ARBI_TRACKING) {
            arbiTrack.stop()
            arbiTrack.targetNode.visible = true
            arbiButtonState = .ARBI_PLACEMENT
            print("NOTTRACKINGNOTTRACKING")
        }
    }
    
    // private functions
    
    private func setupModel() {
        // import model from file
        guard let falconImporter = ARModelImporter(bundled: "millenium-falcon.armodel"),
            let textureImage = UIImage(named: "falcon.jpg"),
            let falconModelNode = falconImporter.getNode() else {
            print("ERROR: FAILED TO GET FALCON MODEL")
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
        
        let meshNodes = falconModelNode.meshNodes.flatMap { $0 as? ARMeshNode }
        for meshNode in meshNodes {
            meshNode.material = material
        }
        
        self.modelNode = falconModelNode
    }
    
    private func setupArbiTrack() {
        // Initialise gyro placement. Gyro placement positions content on a virtual floor plane where the device is aiming.
        guard let gyroPlaceManager = ARGyroPlaceManager.getInstance(),
            let targetImage = UIImage(named: "target.png"),
            let targetNode = ARNode(name: "targetNode"),
            let targetImageNode = ARImageNode(image: targetImage),
            let arbiTrack = ARArbiTrackerManager.getInstance(),
            let modelNode = modelNode else {
            print("ERROR: Setup Arbi Track FAILED")
            return
        }
        
        // Set up the target node on which the model is placed.
        gyroPlaceManager.initialise()
        gyroPlaceManager.world.addChild(targetNode)
        
        // Add a visual reticule to the target node for the user
        targetNode.addChild(targetImageNode)
        
        // Scale and rotate the image to correct transformation
        targetImageNode.scale(byUniform: 0.1)
        targetImageNode.rotate(byDegrees: 90, axisX: 1, y: 0, z: 0)
        
        arbiTrack.initialise()
        arbiTrack.targetNode = targetNode
        arbiTrack.world.addChild(modelNode)
    }
    
    private func synchronize(lockObj: AnyObject!, closure: ()->()){
        objc_sync_enter(lockObj)
        closure()
        objc_sync_exit(lockObj)
    }
    
}

