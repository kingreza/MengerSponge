//
//  GameViewController.swift
//  Fractal
//
//  Created by Reza Shirazian on 2017-03-30.
//  Copyright © 2017 Reza Shirazian. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {
  
  var rootBox: BoxObject?
  var camera: SCNNode?
  var pointOfInterest: SCNNode?
  var spongeDepth: Int = 1
  var hashes: [String:BoxObject] = [String:BoxObject]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // create a new scene
    let scene = SCNScene(named: "art.scnassets/fractal.scn")!
    
    // create and add a camera to the scene
    let cameraNode = SCNNode()
    let camera = SCNCamera()

    
    
    //camera.zNear = 1
    //camera.zFar = 1000000.0
    camera.automaticallyAdjustsZRange = true

    cameraNode.camera = camera
    scene.rootNode.addChildNode(cameraNode)
    self.camera = cameraNode
    
    // place the camera
    cameraNode.position = SCNVector3(x: 200000.0, y: 200000.0, z: 200000.0)

    
    let box = scene.rootNode.childNode(withName: "box", recursively: true)!
    
    let pointOfInterest = SCNNode()
    pointOfInterest.position = box.position
    self.pointOfInterest = pointOfInterest
    scene.rootNode.addChildNode(pointOfInterest)
    
    let lookAt = SCNLookAtConstraint(target: pointOfInterest)
    //lookAt.isGimbalLockEnabled = true
    // create and add a light to the scene
//    for i in 0..<3 {
//      let lightNode = SCNNode()
//      lightNode.light = SCNLight()
//      lightNode.light!.type = .spot
//      lightNode.position = SCNVector3(x: Float((i-1) * 20), y: 20, z: 20)
//      lightNode.constraints = [lookAt]
//      scene.rootNode.addChildNode(lightNode)
//    }
    
    // create and add an ambient light to the scene
//    let ambientLightNode = SCNNode()
//    ambientLightNode.light = SCNLight()
//    ambientLightNode.light!.type = .ambient
//    ambientLightNode.light!.color = UIColor.darkGray
//    scene.rootNode.addChildNode(ambientLightNode)
    
    // retrieve the ship node
    
    
    cameraNode.constraints = [lookAt]
    // retrieve the SCNView
    let scnView = self.view as! SCNView
    
    // set the scene to the view
//    let scrollView = UIScrollView()

//    scrollView.contentSize = CGSize(width: scnView.frame.size.width * 2, height: scnView.frame.height * 2)
//    scrollView.delegate = self
//    scnView.addSubview(scrollView)
    scnView.scene = scene

    
    // allows the user to manipulate the camera
    scnView.allowsCameraControl = false
    scnView.autoenablesDefaultLighting = true

    
    // show statistics such as fps and timing information
    scnView.showsStatistics = true
    
    // configure the view
    scnView.backgroundColor = UIColor.black
    
    // add a tap gesture recognizer
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
    //let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
    scnView.addGestureRecognizer(tapGesture)
    //scnView.addGestureRecognizer(panGesture)
    

    self.rootBox = BoxObject(boxNode: box, scene: scene, level: 0)
    self.hashes[self.rootBox!.key] = self.rootBox
    if let rootBox = self.rootBox {
      rootBox.frac(hashes: &self.hashes)
      for box in rootBox.subBoxes {
        if !box.boxNode.isHidden {
          box.frac(hashes: &self.hashes)
          for subBox in box.subBoxes {
            if !subBox.boxNode.isHidden {
              subBox.frac(hashes: &self.hashes)
            }
          }
        }
      }
    }
  }
  
  func lookAtClickedBox(_ node: SCNNode) {
    if let pointOfInterest = self.pointOfInterest {
      SCNTransaction.begin()
      SCNTransaction.animationDuration = 1.0
      pointOfInterest.position = node.position
      SCNTransaction.commit()
    }
    
  }
  
//  func scrollViewDidScroll(_ scrollView: UIScrollView) {
//    let scrollWidthRatio = Float(scrollView.contentOffset.x / scrollView.frame.size.width)
//    let scrollHeightRatio = Float(scrollView.contentOffset.y / scrollView.frame.size.height)
//    self.camera!.eulerAngles.y = Float(-2 * M_PI) * scrollWidthRatio
//    self.camera!.eulerAngles.x = Float(-M_PI) * scrollHeightRatio
//  }
  
  func handlePan(_ gestureRecognzie: UIGestureRecognizer) {
//    if let pan = gestureRecognzie as? UIPanGestureRecognizer {
//      let translation = pan.translation(in: self.view!)
//      
//      let pan_x = Float(translation.x)
//      let pan_y = Float(-translation.y)
//      let anglePan = sqrt(pow(pan_x,2)+pow(pan_y,2))*(Float)(M_PI)/180.0
//      var rotationVector = SCNVector4()
//      
//      rotationVector.x = -pan_y
//      rotationVector.y = pan_x
//      rotationVector.z = 0
//      rotationVector.w = anglePan
//      
//      self.camera!.rotation = rotationVector
//      
//      if(pan.state == UIGestureRecognizerState.ended) {
//        let currentPivot = self.camera!.pivot
//        let changePivot = SCNMatrix4Invert(self.camera!.transform)
//        self.camera!.pivot = SCNMatrix4Mult(changePivot, currentPivot)
//        self.camera!.transform = SCNMatrix4Identity
//      }
//    }
  }
  
  func handleTap(_ gestureRecognize: UIGestureRecognizer) {
//     retrieve the SCNView
    let scnView = self.view as! SCNView

    // check what nodes are tapped
    let p = gestureRecognize.location(in: scnView)
    let hitResults = scnView.hitTest(p, options: [:])
    // check that we clicked on at least one object
    if hitResults.count > 0 {
        // retrieved the first clicked object
        let result: AnyObject = hitResults[0]
        print(hitResults.count)
        // get its material
        let material = result.node!.geometry!.firstMaterial!
        self.getHitFaceFrom(result: result as! SCNHitTestResult)
        if let name = result.node.name, let box = self.hashes[name] {
          if let parent = box.parent {
            parent.fracChildren(hashes: &self.hashes)
          }
          box.fracChildren(hashes: &self.hashes)
        }
//
//        // highlight it
//        SCNTransaction.begin()
//        SCNTransaction.animationDuration = 0.5
//
//        // on completion - unhighlight
//        SCNTransaction.completionBlock = {
//            SCNTransaction.begin()
//            SCNTransaction.animationDuration = 0.5
//
//            material.emission.contents = UIColor.black
//
//            SCNTransaction.commit()
//        }
//
//        material.emission.contents = UIColor.red
//
//        SCNTransaction.commit()
        //lookAtClickedBox(result.node!)
    }
  }
  
  override var shouldAutorotate: Bool {
    return false
  }
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    if UIDevice.current.userInterfaceIdiom == .phone {
      return .allButUpsideDown
    } else {
      return .all
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Release any cached data, images, etc that aren't in use.
  }
  
  private func setCameraDepth() {
    if let camera = self.camera?.camera {
      camera.zNear = 0.001 / Double(spongeDepth)
      camera.zFar = 11.0 / Double(spongeDepth)

    }
  }
  
  private func getBoxFromNode(node: SCNNode) -> BoxObject? {
    if let name = node.name {
      return self.hashes[name]
    }
    return nil
  }
  
  private func getHitFaceFrom(result: SCNHitTestResult) {
    guard let box = result.node.geometry as? SCNBox, let boxObject = getBoxFromNode(node: result.node) else {
      fatalError()
    }
    let normal = result.localNormal
    let node = result.node
    print("dealing with depth \(boxObject.level)")
    self.spongeDepth = boxObject.level
    SCNTransaction.begin()
    SCNTransaction.animationDuration = 10
    let parentWidth = (boxObject.parent?.boxNode.geometry as? SCNBox)?.width
    let width: Float = Float(parentWidth ?? box.width * 0.95)
    //box.materials.first?.emission.contents = UIColor.red
    //let RATIO: Float = 3.0
    if round(normal.x) == -1 {
      print("Left face hit")
      self.camera?.position.y = node.position.y
      self.camera?.position.z = node.position.z
      self.camera?.position.x = node.position.x - width
    } else if round(normal.x) == 1 {
      print("Right face hit")
      self.camera?.position.y = node.position.y
      self.camera?.position.z = node.position.z
      self.camera?.position.x = node.position.x + width
    } else if round(normal.y) == -1 {
      print("Bottom face hit")
      self.camera?.position.x = node.position.x
      self.camera?.position.z = node.position.z
      self.camera?.position.y = node.position.y - width
    } else if round(normal.y) == 1 {
      print("Top face hit")
      self.camera?.position.x = node.position.x
      self.camera?.position.z = node.position.z
      self.camera?.position.y = node.position.y + width
    } else if round(normal.z) == -1 {
      print("Back face hit")
      self.camera?.position.x = node.position.x
      self.camera?.position.y = node.position.y
      self.camera?.position.z = node.position.z - width
    } else if round(normal.z) == 1 {
      self.camera?.position.x = node.position.x
      self.camera?.position.y = node.position.y
      self.camera?.position.z = node.position.z + width
      print("Front face hit")
    } else {
      // Error, no face detected
    }
    
    if let pointOfInterest = self.pointOfInterest {
      pointOfInterest.position = node.position
    }
    //self.setCameraDepth()
    SCNTransaction.commit()
    
    
  }
}
