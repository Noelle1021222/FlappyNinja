//
//  GameScene.swift
//  FlappyNinja
//
//  Created by 許雅筑 on 2016/9/26.
//  Copyright (c) 2016年 hsu.ya.chu. All rights reserved.
//

import SpriteKit

import Firebase
import FirebaseDatabase
import FBSDKLoginKit
import AVFoundation

struct PhysicsCatagory{ //交互影響，重力影響
    
    static let Flyman:UInt32 = 0x1 << 1
    static let gound:UInt32 = 0x1 << 2
    static let gound2:UInt32 = 0x1 << 3

    static let Wall:UInt32 = 0x1 << 4
    static let Score:UInt32 = 0x1 << 5
    static let enemy:UInt32 = 0x1 << 6
    static let playerHealthBar:UInt32 = 0x1 << 7
    static let Heart:UInt32 = 0x1 << 8
    

}

let MaxHealth = 100
let HealthBarWidth: CGFloat = 330
let HealthBarHeight: CGFloat = 30


class GameScene: SKScene,SKPhysicsContactDelegate {
    
    var avPlayer: AVAudioPlayer!
    var coinPlayer:AVAudioPlayer!
    var heartPlayer:AVAudioPlayer!
    var enemyPlayer:AVAudioPlayer!
    var bumpWallPlayer:AVAudioPlayer!
    var diedPlayer:AVAudioPlayer!
    
//    func setupAudioFile(){
//        let soundFilePath = NSBundle.mainBundle().pathForResource("gameBackground", ofType: "mp3")
//        let soundFileURL = NSURL(fileURLWithPath: soundFilePath!)
//        
//        do{
//            try avPlayer = AVAudioPlayer(contentsOfURL: soundFileURL)
//            avPlayer.numberOfLoops = -1 //infinite
//            avPlayer.play()
//
//
//        }
//        catch{
//            print(error)
//        }
//    }
    
    var Ground = SKSpriteNode()
    var gound:SKSpriteNode = SKSpriteNode()
    var gound2:SKSpriteNode = SKSpriteNode()

    var FlyMan = SKSpriteNode()
    var TextureAtlas = SKTextureAtlas()
    var TextureArray = [SKTexture]()
    
//    var FlyManer = SKSpriteNode(imageNamed: "flyman_1")
    
    var wallPair = SKNode()
    
    var moveAndRemove = SKAction()
    var moveAndRemoveEnemy = SKAction()
    var gameStarted = Bool()
    
    var score = Int()
    
    var highScore = Int()
    var goToFireBaseHighScore = Int()
    
    let scoreLbl = SKLabelNode() //生成score label
    
    let fireScoreLbl = SKLabelNode() //生成score label

    var died = Bool()
    var user = FIRAuth.auth()?.currentUser

    let databaseRef = FIRDatabase.database().reference()
    let fromFBLogin:FBLoginViewController = FBLoginViewController()
    var bloodLbl = SKLabelNode()
//    var enemy = SKSpriteNode()
//    var enemyTextureAtlas = SKTextureAtlas()
//    var enemyTextureArray = [SKTexture]()

    //healthbar
    var playerHealthBar = SKSpriteNode()
    var playerHP = MaxHealth
    
    var Heart = SKSpriteNode()

    
    //restart
    var restartBTN = SKSpriteNode()
//    var backToMenuBTN = SKSpriteNode()
    var fireBaseHighScore:Int = Int()

    //music
    let coinUrl = NSBundle.mainBundle().URLForResource("coin_music", withExtension: "mp3")
    let heartUrl = NSBundle.mainBundle().URLForResource("heart_music", withExtension: "mp3")
    let enemyUrl = NSBundle.mainBundle().URLForResource("when_bump", withExtension: "mp3")
    let bumpUrl = NSBundle.mainBundle().URLForResource("bump_wall2", withExtension: "mp3")
    let diedUrl = NSBundle.mainBundle().URLForResource("died", withExtension: "mp3")

    func restartScene(){
        //remove and restart value
        self.removeAllChildren()
        self.removeAllActions()
        died = false
        gameStarted = false
        score = 0
        playerHP = MaxHealth

        createScene()
    }

    
    func createScene(){
        
        
//        setupAudioFile()
        let soundFilePath = NSBundle.mainBundle().pathForResource("gameBackground", ofType: "mp3")
        let soundFileURL = NSURL(fileURLWithPath: soundFilePath!)
        
        do{
            try avPlayer = AVAudioPlayer(contentsOfURL: soundFileURL)
            avPlayer.numberOfLoops = -1 //infinite
            avPlayer.play()
            
            
            
        }
        catch{
            print(error)
        }
        
//        print(UIFont.familyNames()) // 找到要用的文字
        self.physicsWorld.contactDelegate = self // handle any physics context that go on
        
        for i in 0..<2 {//create two background
            let background = SKSpriteNode(imageNamed: "Background")
            background.anchorPoint = CGPointZero
            background.position = CGPointMake(CGFloat(i) * self.frame.width, 0)
            background.name = "background" //internal name
            background.size = (self.view?.bounds.size)!  //調整background 到適合的size
            
            self.addChild(background)
            //接下來要去view controller 調整
            
        }
        
        updateHealthBar(playerHealthBar, withHealthPoints: playerHP)
//        playerHealthBar = SKSpriteNode(color:SKColor.greenColor(), size: CGSize(width: playerHP, height: 30))
        playerHealthBar.position = CGPoint(x: self.frame.width / 16, y: self.frame.height / 2 + self.frame.height / 2.3)
        playerHealthBar.anchorPoint = CGPointMake(0.0, 0.5)
        playerHealthBar.zPosition = 4
        self.addChild(playerHealthBar)
        
        bloodLbl.position = CGPoint(x: self.frame.width / 6.9, y: self.frame.height / 2 + self.frame.height / 2.8)
        bloodLbl.text = "\(playerHP)"
        bloodLbl.fontName = "04b_19"
        bloodLbl.zPosition = 5 //圖層
        bloodLbl.fontSize = 40
        self.addChild(bloodLbl)
        
        let coinImage = SKSpriteNode(imageNamed: "Coin")
        coinImage.size = CGSize(width: 30, height: 30)
        coinImage.zPosition = 5 //圖層

    coinImage.position = CGPoint(x: self.frame.width / 2.6, y: self.frame.height / 2 + self.frame.height / 2.6)
        self.addChild(coinImage)
    
        
        //label 位置
        scoreLbl.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 + self.frame.height / 2.8)
        scoreLbl.text = ": \(score)"
        scoreLbl.fontName = "04b_19"
        scoreLbl.zPosition = 5 //圖層
        scoreLbl.fontSize = 40
        self.addChild(scoreLbl)
        
        //最高分 label 位置
        fireScoreLbl.position = CGPoint(x: self.frame.width / 2 * 1.5, y: self.frame.height / 2 + self.frame.height / 2.8)
        
        fireScoreLbl.text = "\(self.fireBaseHighScore)"
        fireScoreLbl.fontName = "04b_19"

        fireScoreLbl.zPosition = 5 //圖層
        fireScoreLbl.fontSize = 40
        self.addChild(fireScoreLbl)
        
//        
//        //地板
//        Ground = SKSpriteNode(imageNamed: "Ground") //在Assets
//        Ground.setScale(0.5) //設大小
//        Ground.position = CGPoint(x:self.frame.width/2,y:0 + Ground.frame.height/2) //set 位置
//        let groundTexture = SKTexture(imageNamed: "Ground")
//        groundTexture.filteringMode = .Nearest // shorter form for SKTextureFilteringMode.Nearest
////        let movePipes = SKAction.moveByX(-distance - 50, y: 0, duration: NSTimeInterval(0.006 * distance))
//        let moveGroundSprite = SKAction.moveByX(-groundTexture.size().width * 2.0 - 50, y: 0, duration: NSTimeInterval(0.02 * groundTexture.size().width * 2.0))
//        let resetGroundSprite = SKAction.moveByX(groundTexture.size().width * 2.0, y: 0, duration: 0.0)
//        let moveGroundSpritesForever = SKAction.repeatActionForever(SKAction.sequence([moveGroundSprite,resetGroundSprite]))
//        
//        for var i:CGFloat = 0; i < 2.0 + self.frame.size.width / ( groundTexture.size().width * 2.0 ); ++i {
//            let Ground = SKSpriteNode(texture: groundTexture)
//            Ground.setScale(0.5)
//            Ground.position = CGPoint(x: i * Ground.size.width, y: Ground.size.height / 2.0)
//            Ground.runAction(moveGroundSpritesForever)
//            self.addChild(Ground)
//        }
        //y 座標的0是表示顯示於底部的0
        ///////////////
        let gound1 = SKTexture(imageNamed: "Ground")
        
        gound = SKSpriteNode(texture: gound1)
        gound.setScale(0.5) //設大小
        gound.name = "gound" //internal name

        gound.position = CGPoint(x: self.frame.width / 2, y: 0 + gound.frame.height / 2)
        gound.zPosition = 4
//        gound.position = CGPoint(x:CGRectGetMidX(self.frame), y:gound.size.height);
        
        
        self.addChild(gound)
        gound.physicsBody = SKPhysicsBody(rectangleOfSize: gound.size)
        gound.physicsBody?.categoryBitMask = PhysicsCatagory.gound
        gound.physicsBody?.collisionBitMask = PhysicsCatagory.Flyman  //碰撞
        gound.physicsBody?.contactTestBitMask = PhysicsCatagory.Flyman
        gound.physicsBody?.affectedByGravity = false //不希望 ground move
        gound.physicsBody?.dynamic = false
        
        
        
//        let ani1 = SKAction.moveTo(CGPoint(x: -gound.size.width/2 - 50, y: 0 + gound.frame.height / 2), duration: speed)
//        let ani2 = SKAction.moveTo(gound.position, duration: 0)
//        let ani3 = SKAction.sequence([ani1,ani2])
//        let ani4=SKAction.repeatActionForever(ani3)
//        gound.runAction(ani4)
    
        /////////
        gound2 = SKSpriteNode(texture: gound1)
        gound2.setScale(0.5) //設大小
        gound2.name = "gound2" //internal name

        gound2.zPosition = 4
        gound2.position = CGPoint(x:self.frame.width / 2 + gound2.size.width , y:0 + gound2.frame.height / 2);
        self.addChild(gound2)
        gound2.physicsBody = SKPhysicsBody(rectangleOfSize: gound2.size)
        gound2.physicsBody?.categoryBitMask = PhysicsCatagory.gound2
        gound2.physicsBody?.collisionBitMask = PhysicsCatagory.Flyman  //碰撞
        gound2.physicsBody?.contactTestBitMask = PhysicsCatagory.Flyman
        gound2.physicsBody?.affectedByGravity = false //不希望 ground move
        gound2.physicsBody?.dynamic = false
        
//        let ani1b = SKAction.moveTo(CGPoint(x: CGRectGetMidX(self.frame)-50, y: 0 + gound.frame.height / 2), duration: speed)
//        let ani2b = SKAction.moveTo(gound2.position, duration: 0)
//        let ani3b = SKAction.sequence([ani1b,ani2b])
//        let ani4b=SKAction.repeatActionForever(ani3b)
//        gound2.runAction(ani4b)
        
        ///////////////
        
        //physicsBody
//        Ground.physicsBody = SKPhysicsBody(rectangleOfSize: Ground.size)
//        Ground.physicsBody?.categoryBitMask = PhysicsCatagory.Ground
//        Ground.physicsBody?.collisionBitMask = PhysicsCatagory.Flyman  //碰撞
//        Ground.physicsBody?.contactTestBitMask = PhysicsCatagory.Flyman
//        Ground.physicsBody?.affectedByGravity = false //不希望 ground move
//        Ground.physicsBody?.dynamic = false
        
//        Ground.zPosition = 3 //圖層在最前面
        
        
//        self.addChild(Ground)
        
        
        TextureAtlas = SKTextureAtlas(named: "Images")
        for i in 1...TextureAtlas.textureNames.count{
            var Name = "flyman_\(i+3).png"
            TextureArray.append(SKTexture(imageNamed: Name))
            
        }
        print(TextureAtlas)
        
        //man
        FlyMan = SKSpriteNode(imageNamed: TextureAtlas.textureNames[0] as! String)
        FlyMan.size = CGSize(width: 70, height: 78) // 設大小
        FlyMan.position = CGPoint(x: self.frame.width/2 - FlyMan.frame.width, y: self.frame.height/2)
        
        //physicsBody
        FlyMan.physicsBody = SKPhysicsBody(circleOfRadius: FlyMan.frame.height / 2)
        FlyMan.physicsBody?.categoryBitMask = PhysicsCatagory.Flyman
        FlyMan.physicsBody?.collisionBitMask = PhysicsCatagory.gound | PhysicsCatagory.Wall | PhysicsCatagory.gound2  // 與牆和地會有碰撞

        FlyMan.physicsBody?.contactTestBitMask = PhysicsCatagory.gound | PhysicsCatagory.Wall | PhysicsCatagory.Score | PhysicsCatagory.gound2  // 與牆和地會有碰撞

        FlyMan.physicsBody?.affectedByGravity = false  //一開始false是無重力狀態,使主角先浮在畫面的中間
        FlyMan.physicsBody?.dynamic = true
        FlyMan.physicsBody?.allowsRotation = false   //不旋轉
        FlyMan.zPosition = 2
        
        
        
        self.addChild(FlyMan)
        
 
//        self.addChild(playerHealthBar)
        
//        playerHealthBar.position = CGPoint(
//            x: FlyMan.position.x,
//            y: FlyMan.position.y - FlyMan.size.height/2 - 10
//        )
//        
//        updateHealthBar(playerHealthBar, withHealthPoints: playerHP)

//        enemyTextureAtlas = SKTextureAtlas(named: "ImageEnemy1")
//        for i in 1...enemyTextureAtlas.textureNames.count{
//            var Name = "enemy1_\(i).png"
//            enemyTextureArray.append(SKTexture(imageNamed: Name))
//            
//        }
//        print(enemyTextureAtlas)
//        
//        //man
//        enemy = SKSpriteNode(imageNamed: enemyTextureAtlas.textureNames[0] as! String)
//        enemy.size = CGSize(width: 80, height: 90) // 設大小
//        enemy.position = CGPoint(x: self.frame.width/2 - FlyMan.frame.width, y: self.frame.height/2)
//        
//        FlyMan.zPosition = 5
//
//        self.addChild(enemy)

    }

    override func didMoveToView(view: SKView) {
        
//        let soundFilePath = NSBundle.mainBundle().pathForResource("gameBackground", ofType: "mp3")
//        let soundFileURL = NSURL(fileURLWithPath: soundFilePath!)
//        
//        do{
//            try avPlayer = AVAudioPlayer(contentsOfURL: soundFileURL)
//            avPlayer.numberOfLoops = -1 //infinite
//            avPlayer.play()
//            
//            
//            
//        }
//        catch{
//            print(error)
//        }
        
        fireBaseHighScore = fromFBLogin.userDefault.objectForKey("fireBaseHighScore") as! Int
        print(fireBaseHighScore)

        //        let EnemyTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: #selector(GameScene.createEnemys), userInfo: nil, repeats: true)
        
        createScene()
//        updateHealthBar(playerHealthBar, withHealthPoints: playerHP)

 
    }
    
    func updateHealthBar(node: SKSpriteNode, withHealthPoints hp: Int) {
        
        let barSize = CGSize(width: HealthBarWidth, height: HealthBarHeight);
        
        let fillColor = UIColor(red: 113.0/255, green: 202.0/255, blue: 53.0/255, alpha:1)
        let borderColor = UIColor(red: 35.0/255, green: 28.0/255, blue: 40.0/255, alpha:1)
        
        // create drawing context
        UIGraphicsBeginImageContextWithOptions(barSize, false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        // draw the outline for the health bar
        borderColor.setStroke()
        let borderRect = CGRect(origin: CGPointZero, size: barSize)
        CGContextStrokeRectWithWidth(context, borderRect, 1)
        
        // draw the health bar with a colored rectangle
        fillColor.setFill()
        let barWidth = (barSize.width - 1) * CGFloat(hp) / CGFloat(MaxHealth)
        let barRect = CGRect(x: 0.5, y: 0.5, width: barWidth, height: barSize.height - 1)
        CGContextFillRect(context, barRect)
        
        // extract image
        let spriteImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // set sprite texture and size
        node.texture = SKTexture(image: spriteImage)
        node.size = barSize
    }
    
    func updateBlood(){
        bloodLbl.text = "\(playerHP)"
    }
    
    func createBTN() { //重新開始的按鈕
        let rectangle = SKSpriteNode(imageNamed: "rectangle")
        rectangle.size = CGSizeMake(230, 250)
        rectangle.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 3*1.75)
        rectangle.zPosition = 5

        restartBTN = SKSpriteNode(imageNamed: "RestartBtn")
        restartBTN.size = CGSizeMake(140, 70)
        restartBTN.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 3*1.85)
        restartBTN.zPosition = 6
        restartBTN.setScale(0)//for runAction
    
        
        self.addChild(rectangle)
        self.addChild(restartBTN)
        restartBTN.runAction(SKAction.scaleTo(1.0, duration: 0.3))//有點動畫的感覺(大小,出現延遲)
    }
    
//    func createBackBTN() { //重新開始的按鈕
//        backToMenuBTN = SKSpriteNode(imageNamed: "BackToMenu")
//        backToMenuBTN.size = CGSizeMake(50, 50)
//        backToMenuBTN.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 3 * 1.65-30 )
//        backToMenuBTN.zPosition = 7
//        backToMenuBTN.setScale(0)//for runAction
//       
//        self.addChild(backToMenuBTN)
//        backToMenuBTN.runAction(SKAction.scaleTo(1.0, duration: 0.3))//有點動畫的感覺(大小,出現延遲)
//    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        
        //flyman穿過牆加1
        //只希望在得到coin時coin消失,flyman still live
        
        
        if firstBody.categoryBitMask == PhysicsCatagory.Score && secondBody.categoryBitMask == PhysicsCatagory.Flyman || firstBody.categoryBitMask == PhysicsCatagory.Flyman && secondBody.categoryBitMask == PhysicsCatagory.Score{
            score += 1
            scoreLbl.text = ": \(score)"
            

            guard let newURL = coinUrl else {
                print("Could not find file")
                return
            }
            do {
                coinPlayer = try AVAudioPlayer(contentsOfURL: newURL)
                coinPlayer.volume = 0.5
                coinPlayer.prepareToPlay()
                coinPlayer.play()

            } catch let error as NSError {
                print(error.description)
            }
            firstBody.node?.removeFromParent() //coin 消失
        }

            
        //flyman 撞到牆
        else if firstBody.categoryBitMask == PhysicsCatagory.Flyman && secondBody.categoryBitMask == PhysicsCatagory.Wall || firstBody.categoryBitMask == PhysicsCatagory.Wall && secondBody.categoryBitMask == PhysicsCatagory.Flyman{
            
//            died = true
            //died 寫在外面會使假如人物撞到兩次以上,restart按鈕也會重複出現
            
            //music
            guard let newURL = bumpUrl else {
                print("Could not find file")
                return
            }
            do {
                bumpWallPlayer = try AVAudioPlayer(contentsOfURL: newURL)
                bumpWallPlayer.volume = 0.4
                
                bumpWallPlayer.prepareToPlay()
                bumpWallPlayer.play()
                
            } catch let error as NSError {
                print(error.description)
            }
            
            
            // 扣血
            playerHP = max(0,playerHP - 20)
            updateHealthBar(playerHealthBar, withHealthPoints: playerHP)
            updateBlood()
            
            if playerHP == 0 && died == false{
                //牆壁停
                enumerateChildNodesWithName("wallPair", usingBlock: ({
                    (node,error) in
                    node.speed = 0
                    self.removeAllActions() //假如沒有此code，後面的畫面會持續移動
                }))
                enumerateChildNodesWithName("gound", usingBlock: ({
                    (node,error) in
                    node.speed = 0
                    self.removeAllActions() //假如沒有此code，後面的畫面會持續移動
                }))
                enumerateChildNodesWithName("gound2", usingBlock: ({
                    (node,error) in
                    node.speed = 0
                    self.removeAllActions() //假如沒有此code，後面的畫面會持續移動
                }))
                died = true
                characterDied()
                avPlayer.stop()
            //stop scene後,restart
            highScoreToFireBase(self.score) //high score 在撞牆撞地時就執行
            createBTN()
//            createBackBTN()
            }
            
//            self.scene?.speed = 0  //當人和牆撞到,牆就停止(整個畫面停),但restartBTN不會執行
            
        }

        //flyman撞到鬼 enemyUrl
        else if firstBody.categoryBitMask == PhysicsCatagory.Flyman && secondBody.categoryBitMask == PhysicsCatagory.enemy || firstBody.categoryBitMask == PhysicsCatagory.enemy && secondBody.categoryBitMask == PhysicsCatagory.Flyman{
            
            //            died = true
            //died 寫在外面會使假如人物撞到兩次以上,restart按鈕也會重複出現
            
            
            //music
            guard let newURL = enemyUrl else {
                print("Could not find file")
                return
            }
            do {
                enemyPlayer = try AVAudioPlayer(contentsOfURL: newURL)
                enemyPlayer.volume = 1
                
                enemyPlayer.prepareToPlay()
                enemyPlayer.play()
                
            } catch let error as NSError {
                print(error.description)
            }

            
            // 扣血
            playerHP = max(0,playerHP - 1)
            updateHealthBar(playerHealthBar, withHealthPoints: playerHP)
            updateBlood()
            
            if playerHP == 0 && died == false{
                //牆壁停
                enumerateChildNodesWithName("wallPair", usingBlock: ({
                    (node,error) in
                    node.speed = 0
                    self.removeAllActions() //假如沒有此code，後面的畫面會持續移動
                }))
                enumerateChildNodesWithName("gound", usingBlock: ({
                    (node,error) in
                    node.speed = 0
                    self.removeAllActions() //假如沒有此code，後面的畫面會持續移動
                }))
                enumerateChildNodesWithName("gound2", usingBlock: ({
                    (node,error) in
                    node.speed = 0
                    self.removeAllActions() //假如沒有此code，後面的畫面會持續移動
                }))
                died = true
                //stop scene後,restart
                characterDied()
                avPlayer.stop()

                highScoreToFireBase(self.score) //high score 在撞牆撞地時就執行
                createBTN()
//                createBackBTN()
            }
            
            //            self.scene?.speed = 0  //當人和牆撞到,牆就停止(整個畫面停),但restartBTN不會執行
            
        }
            
            
        //flyman撞到地
        else if firstBody.categoryBitMask == PhysicsCatagory.Flyman && secondBody.categoryBitMask == PhysicsCatagory.gound || firstBody.categoryBitMask == PhysicsCatagory.gound && secondBody.categoryBitMask == PhysicsCatagory.Flyman{
            
            //            died = true
            //died 寫在外面會使假如人物撞到兩次以上,restart按鈕也會重複出現
            playerHP = 0
            updateHealthBar(playerHealthBar, withHealthPoints: playerHP)
            updateBlood()
            enumerateChildNodesWithName("wallPair", usingBlock: ({
                (node,error) in
                
                node.speed = 0
                self.removeAllActions() //假如沒有此code，後面的畫面會持續移動
            }))
            enumerateChildNodesWithName("gound", usingBlock: ({
                (node,error) in
                node.speed = 0
                self.removeAllActions() //假如沒有此code，後面的畫面會持續移動
            }))
            enumerateChildNodesWithName("gound2", usingBlock: ({
                (node,error) in
                node.speed = 0
                self.removeAllActions() //假如沒有此code，後面的畫面會持續移動
            }))
            if died == false{
                died = true
                //stop scene後,restart
                characterDied()
                avPlayer.stop()

                highScoreToFireBase(self.score) //high score 在撞牆撞地時就執行

                createBTN()
//                createBackBTN()
            }
            
            //          self.scene?.speed = 0  //當人和牆撞到,牆就停止(整個畫面停),但restartBTN不會執行
            
        }
   
        else if firstBody.categoryBitMask == PhysicsCatagory.Flyman && secondBody.categoryBitMask == PhysicsCatagory.gound2 || firstBody.categoryBitMask == PhysicsCatagory.gound2 && secondBody.categoryBitMask == PhysicsCatagory.Flyman{
            
            //            died = true
            //died 寫在外面會使假如人物撞到兩次以上,restart按鈕也會重複出現
            
            enumerateChildNodesWithName("gound2", usingBlock: ({
                (node,error) in
                
                node.speed = 0
                self.removeAllActions() //假如沒有此code，後面的畫面會持續移動
            }))
            if died == false{
                died = true
                //stop scene後,restart
                highScoreToFireBase(self.score) //high score 在撞牆撞地時就執行
                createBTN()
//                createBackBTN()
            }
            
            //          self.scene?.speed = 0  //當人和牆撞到,牆就停止(整個畫面停),但restartBTN不會執行
            
        }

        
            //撞到心
        else if firstBody.categoryBitMask == PhysicsCatagory.Flyman && secondBody.categoryBitMask == PhysicsCatagory.Heart || firstBody.categoryBitMask == PhysicsCatagory.Heart && secondBody.categoryBitMask == PhysicsCatagory.Flyman{
            
            //            died = true
            //died 寫在外面會使假如人物撞到兩次以上,restart按鈕也會重複出現
            
            // 扣血
            if playerHP != 100{
            playerHP = max(0,playerHP + 5)
            updateHealthBar(playerHealthBar, withHealthPoints: playerHP)
            updateBlood()
            firstBody.node?.removeFromParent() //coin 消失
            
            //music
                guard let newURL = heartUrl else {
                    print("Could not find file")
                    return
                }
                do {
                    heartPlayer = try AVAudioPlayer(contentsOfURL: newURL)
                    heartPlayer.volume = 1.5

                    heartPlayer.prepareToPlay()
                    heartPlayer.play()
                    
                } catch let error as NSError {
                    print(error.description)
                }

                

            }
            else{
                //血滿了吃愛心不會消失
                return
            }
            
            
        }

        
    }
    
    func characterDied(){
        //music
        guard let newURL = diedUrl else {
            print("Could not find file")
            return
        }
        do {
            diedPlayer = try AVAudioPlayer(contentsOfURL: newURL)
            diedPlayer.volume = 0.8
            
            diedPlayer.prepareToPlay()
            diedPlayer.play()
            
        } catch let error as NSError {
            print(error.description)
        }

    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if gameStarted == false{
            gameStarted = true
            FlyMan.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(TextureArray, timePerFrame: 0.1)))
            FlyMan.physicsBody?.affectedByGravity = true

            updateHealthBar(playerHealthBar, withHealthPoints: playerHP)
            updateBlood()
            let spawn = SKAction.runBlock({
                () in
                self.createWalls()  //包含創牆和移走牆
//                let EnemyTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: #selector(GameScene.createEnemys), userInfo: nil, repeats: true)
                
            })
            
            //牆的生成
            let delay = SKAction.waitForDuration(2.0)
            let SpawnDelay = SKAction.sequence([spawn,delay]) // 做的Action 序列,牆的生死和延遲
            let spawnDealyForever = SKAction.repeatActionForever(SpawnDelay) //重複做 spawnDelay
            self.runAction(spawnDealyForever)
            
            let distance = CGFloat(self.frame.width + wallPair.frame.width)
            let movePipes = SKAction.moveByX(-distance - 50, y: 0, duration: NSTimeInterval(0.006 * distance)) //duration 越大，間距越久，移動越慢(-50是使它延後50pixel移出畫面）
            let removePipes = SKAction.removeFromParent()
            //在生成牆和使牆移動需要有調整，否則就會連在一起
            
            moveAndRemove = SKAction.sequence([movePipes,removePipes])
            
            
//            let EnemyTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: #selector(GameScene.createEnemys), userInfo: nil, repeats: true)
            
            let spawnEnemy = SKAction.runBlock({
                () in
                self.createEnemys()
            })
            
//            //敵人的生成
            let delayEnemy = SKAction.waitForDuration(1.0)
            let SpawnDelayEnemy = SKAction.sequence([spawnEnemy,delayEnemy]) // 做的Action 序列,牆的生死和延遲
            let spawnDealyEnemyForever = SKAction.repeatActionForever(SpawnDelayEnemy) //重複做 spawnDelay
////
            let moveEnemy = SKAction.moveByX(-distance - 50, y: 0, duration: NSTimeInterval(0.0080 * distance)) //duration 越大，間距越久，移動越慢(-50是使它延後50pixel移出畫面）
            let removeEnemy = SKAction.removeFromParent()
            moveAndRemoveEnemy = SKAction.sequence([moveEnemy,removeEnemy])

            self.runAction(spawnDealyEnemyForever)

            
            
            //
            let speed=10.0

            let ani1 = SKAction.moveTo(CGPoint(x: -gound.size.width/2 - 50, y: 0 + gound.frame.height / 2), duration: speed)
            let ani2 = SKAction.moveTo(gound.position, duration: 0)
            let ani3 = SKAction.sequence([ani1,ani2])
            let ani4=SKAction.repeatActionForever(ani3)
            gound.runAction(ani4)
            
            let ani1b = SKAction.moveTo(CGPoint(x: CGRectGetMidX(self.frame)-50, y: 0 + gound.frame.height / 2), duration: speed)
            let ani2b = SKAction.moveTo(gound2.position, duration: 0)
            let ani3b = SKAction.sequence([ani1b,ani2b])
            let ani4b=SKAction.repeatActionForever(ani3b)
            gound2.runAction(ani4b)
            
            
            
            
            //遊戲還沒開始玩前就有預備要移動
            FlyMan.physicsBody?.velocity = CGVectorMake(0, 0)
            //jump!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            FlyMan.physicsBody?.applyImpulse(CGVectorMake(0, 90))  //點擊時的移動(jump)
            updateHealthBar(playerHealthBar, withHealthPoints: playerHP)
            updateBlood()
//            playerHealthBar.position = CGPoint(
//                x: FlyMan.position.x,
//                y: FlyMan.position.y - FlyMan.size.height/2 - 10
//            )

            
        }
        else{
            if died == true{ //人物不能移動
                print("in")
            }
            
            
            else{
            // 遊戲開始後還是要移動
            FlyMan.physicsBody?.velocity = CGVectorMake(0, 0)
            FlyMan.physicsBody?.applyImpulse(CGVectorMake(0, 90))  //點擊時的移動
            updateHealthBar(playerHealthBar, withHealthPoints: playerHP)
                updateBlood()
//            playerHealthBar.position = CGPoint(
//                    x: FlyMan.position.x,
//                    y: FlyMan.position.y - FlyMan.size.height/2 - 10
//                )

            }
            
        }
        
        for touch in touches{
            let location = touch.locationInNode(self)
            
            if died == true {
//                if backToMenuBTN.containsPoint(location) {
//                    self.delegate_MyProtocol?.SceneChange("MainMenu")
//                    
//                }
                //location 有值
                //新增最高分，之後存到firebase
                if restartBTN.containsPoint(location){
                    restartScene()
                    
                }
                //restartBTN
            }
        }
        

        
        
    }

    func highScoreToFireBase(score:Int){
        //若本次玩的分數高過歷史分數，則更新firebase，否則不更新
        if score > highScore{
            highScore = score

            if highScore > self.fireBaseHighScore{
                goToFireBaseHighScore = highScore
            }
            else {
                goToFireBaseHighScore = fireBaseHighScore
            }
        }
        else {
            return
        }
        print(self.highScore)
        
        let highScoreData : [String : AnyObject] =
            ["high_score":self.goToFireBaseHighScore
        ]
        
//        databaseRef.child("users").child(FIRAuth.auth()!.currentUser!.uid).observeSingleEventOfType(.ChildAdded, withBlock: { (snapshot) in
//            let value = snapshot.value as? NSDictionary
//            let username = value?[FIRAuth.auth()!.currentUser!.uid] as! String
//            if FIRAuth.auth()!.currentUser!.uid == username {
//                databaseRef.child(FIRAuth.auth()!.currentUser!.uid).setValue(highScoreData)
//            }
//            else{
//                databaseRef.child("users").child(FIRAuth.auth()!.currentUser!.uid).setValue(highScoreData)
//            }
//        })
        databaseRef.child("users").child(user!.uid).setValue(highScoreData)
        
//
//        databaseRef.child("users").child(FIRAuth.auth()!.currentUser!.uid).setValue(highScoreData)
        
     
//        用來測試users是否會蓋住，結果是不會
//        var uuid = NSUUID().UUIDString
//        databaseRef.child("Customers").child(uuid).setValue(highScoreData)
    

    }
    
    
    func createWalls(){
//        wallPair = SKNode()
        var temp:Int = Int(arc4random_uniform(100))+1
        var scoreNode = SKSpriteNode()
        switch temp {
        case 0...70:
            scoreNode = SKSpriteNode(imageNamed: "Coin") //得分增加coin 本來是條線
            //topwall 1000*100
            //因為topWall.setScale(0.5) 所以變成500*50
            //因為topWall=> y: self.frame.height / 2 = 250, wall是出現在中間，後來加350才平移上去
            //因為btmWall=> y: self.frame.height / 2 - 350
            //wall 之間的gap 是：700(pipe的差距)-500 = 200
            scoreNode.size = CGSize(width: 50, height: 50)
            scoreNode.position = CGPoint(x:self.frame.width + 25 , y: self.frame.height / 2)
            scoreNode.physicsBody = SKPhysicsBody(rectangleOfSize: scoreNode.size)
            scoreNode.physicsBody?.affectedByGravity = false
            scoreNode.physicsBody?.dynamic = false
            scoreNode.physicsBody?.categoryBitMask = PhysicsCatagory.Score
            scoreNode.physicsBody?.collisionBitMask = 0
            scoreNode.physicsBody?.contactTestBitMask = PhysicsCatagory.Flyman
            scoreNode.color = SKColor.blueColor()

            break
        case 71...100:
             scoreNode = SKSpriteNode(imageNamed: "heart") //得分增加coin 本來是條線
            //topwall 1000*100
            //因為topWall.setScale(0.5) 所以變成500*50
            //因為topWall=> y: self.frame.height / 2 = 250, wall是出現在中間，後來加350才平移上去
            //因為btmWall=> y: self.frame.height / 2 - 350
            //wall 之間的gap 是：700(pipe的差距)-500 = 200
            scoreNode.size = CGSize(width: 50, height: 50)
            scoreNode.position = CGPoint(x:self.frame.width + 25 , y: self.frame.height / 2)
            scoreNode.physicsBody = SKPhysicsBody(rectangleOfSize: scoreNode.size)
            scoreNode.physicsBody?.affectedByGravity = false
            scoreNode.physicsBody?.dynamic = false
            scoreNode.physicsBody?.categoryBitMask = PhysicsCatagory.Heart
            scoreNode.physicsBody?.collisionBitMask = 0
            scoreNode.physicsBody?.contactTestBitMask = PhysicsCatagory.Flyman
            scoreNode.color = SKColor.blueColor()

            break
        default:
            break
            
        }
//        let scoreNode = SKSpriteNode(imageNamed: "heart") //得分增加coin 本來是條線
//        //topwall 1000*100
//        //因為topWall.setScale(0.5) 所以變成500*50
//        //因為topWall=> y: self.frame.height / 2 = 250, wall是出現在中間，後來加350才平移上去
//        //因為btmWall=> y: self.frame.height / 2 - 350
//        //wall 之間的gap 是：700(pipe的差距)-500 = 200
//        scoreNode.size = CGSize(width: 50, height: 50)
//        scoreNode.position = CGPoint(x:self.frame.width + 25 , y: self.frame.height / 2)
//        scoreNode.physicsBody = SKPhysicsBody(rectangleOfSize: scoreNode.size)
//        scoreNode.physicsBody?.affectedByGravity = false
//        scoreNode.physicsBody?.dynamic = false
//        scoreNode.physicsBody?.categoryBitMask = PhysicsCatagory.Score
//        scoreNode.physicsBody?.collisionBitMask = 0
//        scoreNode.physicsBody?.contactTestBitMask = PhysicsCatagory.Flyman
//        scoreNode.color = SKColor.blueColor()

        wallPair = SKNode()
        wallPair.name = "wallPair"  //internal name 內部使用名
        
        let topWall = SKSpriteNode(imageNamed: "Wall")
        let btmWall = SKSpriteNode(imageNamed: "Wall")
        //位置
        topWall.position = CGPoint(x: self.frame.width + 25  , y: self.frame.height / 2 + 380) //x的長度 self.frame.width/2 是看得見他們
        btmWall.position = CGPoint(x: self.frame.width + 25  , y: self.frame.height / 2 - 380)
        //各加25 是因為movePipe - 50
        
        topWall.setScale(0.5)
        btmWall.setScale(0.5)
        
        //高牆的物理性質
        topWall.physicsBody = SKPhysicsBody(rectangleOfSize: topWall.size)
        topWall.physicsBody?.categoryBitMask = PhysicsCatagory.Wall
        topWall.physicsBody?.collisionBitMask = PhysicsCatagory.Flyman
        topWall.physicsBody?.contactTestBitMask = PhysicsCatagory.Flyman
        topWall.physicsBody?.affectedByGravity = false
        topWall.physicsBody?.dynamic = false
        
        //低牆的物理性質
        btmWall.physicsBody = SKPhysicsBody(rectangleOfSize: btmWall.size)
        btmWall.physicsBody?.categoryBitMask = PhysicsCatagory.Wall
        btmWall.physicsBody?.collisionBitMask = PhysicsCatagory.Flyman
        btmWall.physicsBody?.contactTestBitMask = PhysicsCatagory.Flyman
        btmWall.physicsBody?.affectedByGravity = false
        btmWall.physicsBody?.dynamic = false
        
        
        topWall.zRotation = CGFloat(M_PI)  //旋轉top wall使它頭在下面 180度

        
        wallPair.addChild(topWall)
        wallPair.addChild(btmWall)
        
        wallPair.zPosition = 2 //圖層在最後面，被牆擋到
        
        
        //call RandomFunction
        var randomPosition = CGFloat.random(min:-200,max: 200)  //在 200~ -200 間移動
        wallPair.position.y = wallPair.position.y + randomPosition
        
        wallPair.addChild(scoreNode)
        
        
        
        
        wallPair.runAction(moveAndRemove)  //因為已經是放在外部參數
        self.addChild(wallPair)
    }
    
    
    func createEnemys(){
        var enemy = SKSpriteNode()
        var enemyTextureAtlas = SKTextureAtlas()
        var enemyTextureArray = [SKTexture]()
        enemyTextureAtlas = SKTextureAtlas(named: "ImageEnemy1")
        for i in 1...enemyTextureAtlas.textureNames.count{
            var Name = "enemy1_\(i).png"
            enemyTextureArray.append(SKTexture(imageNamed: Name))
            
        }
        
        //man
        enemy = SKSpriteNode(imageNamed: enemyTextureAtlas.textureNames[0] as! String)
        enemy.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(enemyTextureArray, timePerFrame: 0.2)))
        
        enemy.size = CGSize(width: 70, height: 75) // 設大小
        var MinValue = self.size.width / 8
        var MaxValue = self.size.width - 20
        var SpawnPoint = UInt32(MaxValue-MinValue)
        var randomPosition = CGFloat.random(min:-400,max: 400)  //在 200~ -200 間移動
        enemy.position = CGPoint(x: randomPosition  , y: self.size.height)

//        wallPair.position.y = wallPair.position.y + randomPosition

        enemy.physicsBody = SKPhysicsBody(circleOfRadius: enemy.frame.height / 2)
        enemy.physicsBody?.categoryBitMask = PhysicsCatagory.enemy
        enemy.physicsBody?.collisionBitMask = PhysicsCatagory.Flyman | PhysicsCatagory.Wall // 會被主角推開
        enemy.physicsBody?.contactTestBitMask = PhysicsCatagory.Flyman
        enemy.physicsBody?.affectedByGravity = false
        enemy.physicsBody?.dynamic = true  //有動態反應
//        FlyMan.physicsBody = SKPhysicsBody(circleOfRadius: FlyMan.frame.height / 2)
//        FlyMan.physicsBody?.categoryBitMask = PhysicsCatagory.Flyman
//        FlyMan.physicsBody?.collisionBitMask = PhysicsCatagory.Ground | PhysicsCatagory.Wall | PhysicsCatagory.enemy  // 與牆和地會有碰撞
//        FlyMan.physicsBody?.contactTestBitMask = PhysicsCatagory.Ground | PhysicsCatagory.Wall | PhysicsCatagory.Score
//        FlyMan.physicsBody?.affectedByGravity = false  //一開始false是無重力狀態,使主角先浮在畫面的中間
//        FlyMan.physicsBody?.dynamic = true
//        FlyMan.physicsBody?.allowsRotation = false   //不旋轉
//        FlyMan.zPosition = 2
        
        
        let action = SKAction.moveToY(-30, duration: 3.0)
        enemy.runAction(SKAction.repeatActionForever(action))

        enemy.zPosition = 1
//        
//        let distance = CGFloat(self.frame.width + wallPair.frame.width)
//
//        let moveEnemy = SKAction.moveByX(-distance - 50, y: 0, duration: NSTimeInterval(0.01 * distance)) //duration 越大，間距越久，移動越慢(-50是使它延後50pixel移出畫面）
//        let removeEnemy = SKAction.removeFromParent()
//        moveAndRemoveEnemy = SKAction.sequence([moveEnemy,removeEnemy])
        
        //            self.runAction(spawnDealyEnemyForever)
        enemy.runAction(moveAndRemove)  //因為已經是放在外部參數

        self.addChild(enemy)

        
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        //使background 不斷重複跑
        if gameStarted == true {
            if died == false{
//                enumerateChildNodesWithName("Ground", usingBlock: ({
//                    (node,error) in
//                    var bg = node as! SKSpriteNode
//                    bg.position = CGPoint(x: bg.position.x - 3, y: bg.position.y) //減越多移動越快
//                    
//                    if bg.position.x <= -bg.size.width{
//                        bg.position = CGPointMake(bg.position.x + bg.size.width * 2, bg.position.y)
//                    }
//                    
//                    
//                }))
                
                enumerateChildNodesWithName("background", usingBlock: ({
                    (node,error) in
                    var bg = node as! SKSpriteNode
                    bg.position = CGPoint(x: bg.position.x - 3, y: bg.position.y) //減越多移動越快
                    
                    if bg.position.x <= -bg.size.width{
                        bg.position = CGPointMake(bg.position.x + bg.size.width * 2, bg.position.y)
                    }
                    
                    
                }))

            }
            
        }
    }
}
