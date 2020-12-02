//
//  PokeNode.swift
//  PokemonScanner
//
//  Created by Tom Bastable on 01/12/2020.
//

import Foundation
import ARKit

// MARK: - PokeNode
/**
Manages and provides SCNNodes for the ARKit scene.
Also holds the ARImageTrackingConfiguration for easy global access.

 - Author:
 Tom Bastable
 - Important:
 Has not gone through QA
 - Version: 0.01a
 
 Stored Properties:
 - shared: Holds an initialised static property of PokeNode.
 - configuration: Initialised instance of ARImageTrackingConfiguration()

 Whats new in this version:
 - Nodes now animate
 - Pokemon Nodes now have a pokeball particle effect.
 */
class PokeNode {
    ///Static instance of PokeNode
    static let shared = PokeNode()
    ///Holds the ARImageTrackingConfiguration for the Scene
    let configuration = ARImageTrackingConfiguration()

    // MARK: - Scene Light
    ///Provides a SCNNode Light - it's above ground and omnidirectional.
    func sceneLight() -> SCNNode {

        let spotLight = SCNNode()
        spotLight.light = SCNLight()
        spotLight.scale = SCNVector3(1,1,1)
        spotLight.light?.intensity = 1200
        spotLight.castsShadow = true
        spotLight.position = SCNVector3Zero
        spotLight.light?.type = SCNLight.LightType.omni
        spotLight.light?.color = UIColor.white
        spotLight.position.z = 0.08

        return spotLight

    }

    // MARK: - Model Node
    ///Returns a pokemon model node as an optional - if it comes back nil
    ///then the project doesn't have the 3d Model for that pokemon.
    ///Perhaps provide a large Pokeball instead.
    func modelNode(name: String?) -> SCNNode? {
        
        //check for a valid model of that Pokemon
        if let pokemonNode = getModel(filepath: "\(name ?? "").scn") {
            //set position, angle, scale and shadows.
            pokemonNode.position = SCNVector3Zero
            pokemonNode.eulerAngles.x = .pi / 2
            pokemonNode.scale = SCNVector3(0.000, 0.000, 0.000)
            pokemonNode.castsShadow = true

            //Put together the particle system
            let particlesNode = SCNNode()
            let particleSystem = SCNParticleSystem(named: "PokeballParticle", inDirectory: "")
            particlesNode.addParticleSystem(particleSystem!)
            particlesNode.position = SCNVector3Zero
            particlesNode.eulerAngles.x = -.pi / 2
            particlesNode.scale = SCNVector3(8, 8, 8)
            //attach the particles to the model node
            pokemonNode.addChildNode(particlesNode)

            //set a delay for the model animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.animateModel(node: pokemonNode)
            }
            //return the node
            return pokemonNode
        } else {
            //no model present - return nil
            return nil
        }
    }

    // MARK: - Pokeball Node
    ///Provides a Pokeball Node in two different scales based on the boolean.
    func pokeballNode(isSmall: Bool) -> SCNNode {
        //setup the pokeball node
        let ballNode = getModel(filepath: "Pokeball.scn")!
        ballNode.position = SCNVector3Zero
        ballNode.scale = isSmall ? SCNVector3(0.0001, 0.0001, 0.0001) :
                                   SCNVector3(0.0003, 0.0003, 0.0003)
        ballNode.eulerAngles.x = -.pi / 2
        ballNode.position.y = -0.1
        ballNode.position.z = 0.1
        //delay the animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.animateBall(node: ballNode, isSmall: isSmall)
        }
        //return the node
        return ballNode
    }
    
    //MARK: - Detail Node
    ///The Detail Node takes in an image provided by the detailView.
    ///Contains all data on that pokemon card.
    func detailNode(image: UIImage) -> SCNNode {

        //setup the detail node
        let detailNode = SCNNode(geometry: SCNPlane(width: 1.5, height: 0.45))
        detailNode.geometry?.firstMaterial?.diffuse.contents = image
        detailNode.position = SCNVector3Zero
        detailNode.scale = SCNVector3(0.04, 0.04, 0.04)
        detailNode.eulerAngles.x = .pi / 2
        detailNode.position.z = 0.08

        //return the node
        return detailNode
    }

    //MARK: - Animate Model
    ///Takes in the Pokemon Model and animates it (Increases its scale)
    func animateModel(node: SCNNode?) {
        if let node = node {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 2
            node.scale = SCNVector3(0.001, 0.001, 0.001)
            SCNTransaction.commit()
        }
    }

    // MARK: - Animate Ball
    ///Animates the pokeball to be in front of the model.
    func animateBall(node: SCNNode?, isSmall: Bool) {
        if let node = node {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 1
            node.eulerAngles.x = .pi / 2
            node.position.y = isSmall ? -0.03 : 0
            node.position.z = 0.01
            SCNTransaction.commit()
        }
    }

    // MARK: - Add Image to Configuration
    ///Takes in an image, and the Pokemon name, and places it within the global
    ///image recognition configuration. Called after a pokemon is confirmed.
    func addImageToConfiguration(name: String, image: UIImage?) {
        //unwrap cgimage
        if let cgImage = image?.cgImage {
            //create the tracking image (Needs to be adjusted to actual pokemon card size)
            let trackingImage = ARReferenceImage.init(cgImage,
                                                      orientation: .up,
                                                      physicalWidth: 0.082)
            trackingImage.name = "\(name)"
            //add to configuration.
            configuration.trackingImages.insert(trackingImage)
            configuration.maximumNumberOfTrackedImages = configuration.trackingImages.count
        }
    }

    // MARK: - Get Model
    ///Gets a 3d Model based on the pokemon name.
    ///Private function - only to be called within PokeNode.
    private func getModel(filepath: String) -> SCNNode? {
        let returnNode = SCNNode()
        if let scene = SCNScene(named: filepath) {
            for vNode in (scene.rootNode.childNodes) {
                returnNode.addChildNode(vNode)
            }
            return returnNode
        }
        return nil
    }
}
