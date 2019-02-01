//
//  GameScene.swift
//  CatapultaArdillas
//
//  Created by DAM2 on 17/1/19.
//  Copyright © 2019 DAM2. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate
{
    var catapulta = SKSpriteNode();
    var giroIzq = SKAction()
    
    
    var cargadorNivel: SKNode!
    var salidaBellotas: SKNode!
    var disparoCamara = SKSpriteNode()
    
    var etiquetaMarcador : SKLabelNode!
    var puntuacion = 0
    
    override func didMove(to view: SKView)
    {
        catapulta = childNode(withName: "catapulta") as! SKSpriteNode
        giroIzq = SKAction.rotate(toAngle: 45, duration: 0.5, shortestUnitArc:true)
        
        
        cargadorNivel = childNode(withName: "cargadorNivel")
        cargadorNivel.addChild(SKReferenceNode(fileNamed:"Nivel1.sks"))
        
        salidaBellotas = childNode(withName: "salidaBellotas")
        creaMuelle()
        creaCazo()
        
        self.physicsWorld.contactDelegate = self
        etiquetaMarcador = camera?.childNode(withName: "marcador") as! SKLabelNode
       
    }
    
    override func touchedBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        let tochedNode = self.atPoint(touches.first!.location(in: self))
        if let name = tochedNode.name
        {
            if name == "reiniciar"
            {
                reiniciarPartida()
            }
        }
        else
        {
            catapulta.removeAllActions()
            catapulta.run(giroIzq)
        
            //creo un disparo y lo añado en el punto de salida de las bellotas
            let disparo = SKSpriteNode(imageNamed: "acorn2.png")
            disparo.zPosition = 4
            disparo.physicsBody = SKPhysicsBody(circleOfRadius: 15)
            disparo.position = salidaBellotas.position
            disparo.physicsBody?.collisionBitMask = 3                                           //0011
            disparo.physicsBody?.contactTestBitMask = 3                                         //0011
            disparo.physicsBody?.categoryBitMask = 3                                            //0011
        
            disparoCamara =  disparo
            addChild(disparo)
            self.camera?.position.x = UIScreen.main.bounds.width / 2
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        catapulta.removeAllActions()
    }

    override func update(_ currentTime: TimeInterval) {
        if disparoCamara.position.x > 512
        {
            self.camera?.position.x = disparoCamara.position.x
        }
    }
    
    func creaMuelle()
    {
        let tamano = CGSize(width: 1, height: 1)
        let anclaMuelle = SKSpriteNode(color: .red, size: tamano)
        anclaMuelle.physicsBody = SKPhysicsBody(rectangleOf: tamano)
        anclaMuelle.physicsBody?.isDynamic = false
        anclaMuelle.position = CGPoint(x: catapulta.position.x, y: catapulta.position.y + 300)
        
        anclaMuelle.physicsBody?.collisionBitMask = 8 //1000
        addChild(anclaMuelle)
        
        //creo el muelle y lo añado
        let muelle = SKPhysicsJointSpring.joint(withBodyA: anclaMuelle.physicsBody!, bodyB: catapulta.physicsBody!, anchorA: anclaMuelle.position, anchorB: anclaMuelle.position)
        muelle.frequency = 1    //fuerza del muelle
        muelle.damping = 0.2    //rebote del muelle
        scene?.physicsWorld.add(muelle)
    }
    
    func creaCazo()
    {
        let cazo = childNode(withName: "cazo") as! SKSpriteNode
        let fijaCazo = SKPhysicsJointFixed.joint(withBodyA: cazo.physicsBody!, bodyB: catapulta.physicsBody!, anchor: cazo.position)
        
        scene?.physicsWorld.add(fijaCazo)
    }
    
    func didBegin(_ contact: SKPhysicsContact)
    {
        if(contact.bodyA.categoryBitMask == 3) || (contact.bodyB.categoryBitMask == 3)
        {
            if(contact.bodyA.categoryBitMask == 5) || (contact.bodyB.categoryBitMask == 5)
            {
                print("contacto entre gato bellota")
                let emisor = SKEmitterNode(fileNamed: "Explosion.sks")
                emisor?.position = contact.contactPoint
                addChild(emisor!)
                contact.bodyA.node?.removeFromParent()
                contact.bodyB.node?.removeFromParent()
                puntuacion = puntuacion + 10
                actualizaMarcador()
                
            }
            if(contact.bodyA.categoryBitMask == 6) || (contact.bodyB.categoryBitMask == 6)
            {
                let emisor = SKEmitterNode(fileNamed: "ExplosionPerros.sks")
                emisor?.position = contact.contactPoint
                addChild(emisor!)
                contact.bodyA.node?.removeFromParent()
                contact.bodyB.node?.removeFromParent()
                puntuacion = puntuacion + 20
                actualizaMarcador()
            }
        }
    }
    
    func actualizaMarcador()
    {
        etiquetaMarcador.text = String(puntuacion)
    }
    
    func reiniciarPartida()
    {
        if let view = self.view
        {
            if let scene = SKScene(fileNamed:"GameScene")
            {
                scene.scaleMode = .aspectFill
                view.presentScene(scene)
            }
        }
    }
}
