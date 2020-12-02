//
//  PokemonViewerViewController.swift
//  PokemonScanner
//
//  Created by Tom Bastable on 29/11/2020.
//

import UIKit
import SceneKit
import ARKit

// MARK: - Pokemon Viewer VC
class PokemonViewerViewController: UIViewController {

    ///The ARSceneView
    @IBOutlet var sceneView: ARSCNView!
    ///The frame that will be used to cut the pokemon card
    ///out of the ARSCNView.
    @IBOutlet var cropRect: UIView!
    ///The add button container view
    @IBOutlet var scanAgain: UIView!
    ///The Pokeball scan button
    @IBOutlet var scanButton: UIButton!
    ///The view where the pokemon details are kept for snapshotting
    @IBOutlet var detailView: PokemonCardDetailView!
    ///Button used to switch back to the add UI
    @IBOutlet var addButton: UIButton!
    ///Button used to switch to the viewing UI
    @IBOutlet var closeButton: UIButton!

    ///Stores the detected pokemons name
    private var pokemon: String?
    ///Stores the tracked image taken from the ARSCNView
    private var image: UIImage?

    // MARK: - VDL
    override func viewDidLoad() {
        super.viewDidLoad()
        //set the professor oak Delegate
        ProfessorOak.shared.delegate = self

        // Create a new scene
        let scene = SCNScene(named: "GameScene.scn")!
        //add lighting
        scene.rootNode.addChildNode(PokeNode.shared.sceneLight())

        // Set the scene to the view
        sceneView.autoenablesDefaultLighting = true
        sceneView.scene = scene
    }

    // MARK: - VWA
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        // Create a session configuration
        sceneView.session.run(PokeNode.shared.configuration)
    }

    // MARK: - VWD
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - Scan Card
    ///IBAction is called when a user chooses to scan a card
    ///It ends up in a Professor Oak request.
    @IBAction func scanCard(_ sender: Any) {
        //get a snapshot of the ARSCNVIEW
        let image = sceneView.snapshot()
        //resize the image
        let croppedImage = image.resizeImage(targetSize: CGSize(width: self.view.frame.width,
                                                                height: self.view.frame.height))
        //crop the image to the selected rect
        let profImage = croppedImage.crop(rect: cropRect.frame)
        //set the image to the vc
        self.image = profImage
        //Ask Professor Oak who this pokemon is...the suspense!
        ProfessorOak.shared.whosThatPokemon(profImage)
    }

    // MARK: - Stop Adding
    ///Close the Add Pokemon scene, and go back to viewing
    @IBAction func stopAdding(_ sender: Any) {
        addButton.isHidden = false
        closeButton.isHidden = true
        scanButton.isHidden = true
        cropRect.isHidden = true
    }

    // MARK: - Scan Again
    ///From the viewing, bring up the UI to add another pokemon
    @IBAction func scanAgain(_ sender: Any) {
        addButton.isHidden = true
        closeButton.isHidden = false
        scanButton.isHidden = false
        cropRect.isHidden = false
    }
}

// MARK: - ARSCNViewDelegate Extension
extension PokemonViewerViewController: ARSCNViewDelegate {
    // MARK: - Renderer
    ///Called when a recognised image is found within the world.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        //initialise a node
        let node = SCNNode()
        //process the below on the main thread
        DispatchQueue.main.async {
            //get the current imageAnchor
            if let imageAnchor = anchor as? ARImageAnchor {
                //create a plane from that anchor
                let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width,
                                     height: imageAnchor.referenceImage.physicalSize.height)
                plane.firstMaterial?.diffuse.contents = UIColor(white: 1, alpha: 0)
                //create a node from the plane geo
                let planeNode = SCNNode(geometry: plane)
                //lay the plane node flat
                planeNode.eulerAngles.x = -.pi / 2
                
                //safely add the detail view to the node
                if let image = UIImage.imageWithView(view: self.detailView!) {
                    planeNode.addChildNode(PokeNode.shared.detailNode(image: image))
                    node.addChildNode(planeNode)
                }
                
                //safely add the model and ball to the node (These will animate in)
                //FYI - Animation functions are located in PokeNode.swift
                if let pokemonNode = PokeNode.shared.modelNode(name: imageAnchor.referenceImage.name) {
                    planeNode.addChildNode(pokemonNode)
                    planeNode.addChildNode(PokeNode.shared.pokeballNode(isSmall: true))
                    node.addChildNode(planeNode)
                //If the pokemon model doesn't exist, provide a big pokeball instead
                } else {
                    planeNode.addChildNode(PokeNode.shared.pokeballNode(isSmall: true))
                    node.addChildNode(planeNode)
                }
            }
        }
        //return the node
        return node
    }
}

// MARK: - ProfessorOakDelegate Extension
extension PokemonViewerViewController: ProfessorOakDelegate {

    // MARK: - Pokemon Recognised
    ///Professor Oak has recognised a pokemon!
    func pokemonRecognised(_ name: String) {
        //switch to the viewing UI
        addButton.isHidden = false
        closeButton.isHidden = true
        scanButton.isHidden = true
        cropRect.isHidden = true

        //vibrate the device because awesomeness
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)

        //We've recognised the Pokemon - now let's call the API to get more data
        //on that pokemon card. This is only for base set Pokemon because I'm a 90's kid.
        PokemonTCGAPI.shared.retrieveBasePokemonCard(name: name) { (card, error) in
            //if the card is present
            if let card = card {
                //setup the detail view
                self.detailView.setupPokemonCard(card: card[0]) { (error) in
                    if error == nil {
                        //add the tracking image to the config
                        PokeNode.shared.addImageToConfiguration(name: name, image: self.image)
                        //Run the view's session with the new config.
                        //the ARSCNView delegate will handle the rest.
                        self.sceneView.session.run(PokeNode.shared.configuration)
                    }
                }
            }
        }
    }
}
