//
//  ViewController.swift
//  ARExperiment
//
//  Created by Berta Devant on 02/01/2018.
//  Copyright © 2018 Berta Devant. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class EnduranceSceneViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    fileprivate var modelNodeModel: SCNNode?
    private let modelNodeName = "enduranceV3"
    private var spotLight: SCNLight!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = false
        sceneView.debugOptions = []
        sceneView.antialiasingMode = .multisampling4X

        modelNodeModel = createSceneNodeForAsset(modelNodeName, assetPath: "art.scnassets/endurance-rotating.dae")
        //let scene = SCNScene(named: "art.scnassets/tars.scn")
        //sceneView.scene = scene!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.isLightEstimationEnabled = true;
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    private func createSceneNodeForAsset(_ assetName: String, assetPath: String) -> SCNNode? {
        guard let paperPlaneScene = SCNScene(named: assetPath) else {
            return nil
        }
        let carNode = paperPlaneScene.rootNode.childNode(withName: assetName, recursively: true)
        return carNode
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: sceneView) else {
            return
        }

        if let nodeExists = sceneView.scene.rootNode.childNode(withName: modelNodeName, recursively: true) {
            nodeExists.removeFromParentNode()
        }
        
        let hitResultsFeaturePoints: [ARHitTestResult] =
            sceneView.hitTest(location, types: .featurePoint)

        if let hit = hitResultsFeaturePoints.first {
            
            let rotate = simd_float4x4(SCNMatrix4MakeRotation(sceneView.session.currentFrame!.camera.eulerAngles.y, 0, 1, 0))
            
            let finalTransform = simd_mul(hit.worldTransform, rotate)
            
            let anchor = ARAnchor(transform: finalTransform)
            print("anchor \(anchor)")
            sceneView.session.add(anchor: anchor)
        }
    }
    
}

extension EnduranceSceneViewController: ARSCNViewDelegate {

     // Override to create and configure nodes for anchors added to the view's session.
//     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
//     let node = SCNNode()
//
//     return node
//     }

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if !anchor.isKind(of: ARPlaneAnchor.self) {
            DispatchQueue.main.async {
                guard let model = self.modelNodeModel else {
                    print("we have no model")
                    return
                }
                
                let modelClone = model.clone()
                modelClone.position = SCNVector3Zero

                node.addChildNode(modelClone)
                
            }
        }
    }

    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user

    }

    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay

    }

    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required

    }
}