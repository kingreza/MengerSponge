//
//  BoxObject.swift
//  Fractal
//
//  Created by Reza Shirazian on 2017-03-31.
//  Copyright © 2017 Reza Shirazian. All rights reserved.
//

import SceneKit


class BoxObject {
  var parent: BoxObject?
  var scene: SCNScene
  var boxNode: SCNNode
  var subBoxes: [BoxObject]
  var level: Int
  var key: String
  
  init(boxNode: SCNNode, scene: SCNScene, level: Int, parent: BoxObject? = nil) {
    self.boxNode = boxNode
    self.scene = scene
    self.subBoxes = [BoxObject]()
    self.level = level
    self.key = "\(self.boxNode.position.x)\(self.boxNode.position.y)\(self.boxNode.position.z)"
    self.boxNode.name = self.key
    self.parent = parent
  }
  
  func fracChildren(hashes: inout [String: BoxObject]) {
    for box in self.subBoxes {
      if !box.boxNode.isHidden {
        box.frac(hashes: &hashes)
      }
    }
  }
  
  func frac(hashes: inout [String: BoxObject]) {
    guard let boxModel = boxNode.geometry as? SCNBox else {
      fatalError("box is not set correctly for fractal calculation")
    }

    let nw = boxModel.width / 3

    for i in 0..<3 {
      for j in 0..<3 {
        for k in 0..<3 {

          let newBox = SCNBox(width: nw, height: nw, length: nw, chamferRadius: 0)
          //let hue = CGFloat(Double(i*100 + j*10 + k) / 3.0)
          let color = UIColor.orange
          newBox.firstMaterial?.diffuse.contents = color
          newBox.firstMaterial?.lightingModel = .phong
          newBox.firstMaterial?.shininess = 1.2
          let node = SCNNode(geometry: newBox)
          
          node.position = SCNVector3(x: Float(CGFloat((CGFloat((i - 1)) * nw)) + CGFloat(boxNode.position.x)),
                                     y: Float(CGFloat((CGFloat((j - 1)) * nw)) + CGFloat(boxNode.position.y)),
                                     z: Float(CGFloat((CGFloat((k - 1)) * nw)) + CGFloat(boxNode.position.z)))
          
          scene.rootNode.addChildNode(node)
          boxNode.isHidden = true
          if (i == 1 && j == 1) || (i == 1 && k == 1) || (j == 1 && k == 1) {
            node.isHidden = true
          }
          let newBoxObject = BoxObject(boxNode: node, scene: scene, level: self.level + 1, parent: self)
          hashes[newBoxObject.key] = newBoxObject
          node.name = newBoxObject.key
          //print("new cube added at level \(level) at position \(node.position)")
          subBoxes.append(newBoxObject)
        }
      }
    }
  }
}
