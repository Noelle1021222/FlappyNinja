//
//  FBLoginViewController.swift
//  FlappyNinja
//
//  Created by 許雅筑 on 2016/9/30.
//  Copyright © 2016年 hsu.ya.chu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FBSDKLoginKit
import SpriteKit


protocol ScoreDataEnteredDelegate {
    func userEditEnterInformation(high_score:Int)
}

class FBLoginViewController: UIViewController,FBSDKLoginButtonDelegate,ScoreDataEnteredDelegate {

    

    
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var loginButtonTwo: FBSDKLoginButton!
    
    var facebookLoginButton: FBSDKLoginButton = FBSDKLoginButton()
    var userName: String = ""
    var userEmail: String = ""
    var userLink: String = ""
    var userID: String = ""
    var userPictureURL: String = ""
    var userDefault = NSUserDefaults.standardUserDefaults()
    var fireBaseHighScore = Int()
    var user = FIRAuth.auth()?.currentUser
    var delegate:ScoreDataEnteredDelegate? = nil
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let imageView = UIImageView(frame: self.view.bounds)
        imageView.image = UIImage(named: "gameBackground")//if its in images.xcassets
        self.view.addSubview(imageView)

//         self.view.backgroundColor = UIColor.grayColor()
        // Label初始化
        let dyLabel: UILabel = UILabel(frame: CGRectMake(0,0,200,70))
        
        // Label背景顏色
        dyLabel.backgroundColor = UIColor.grayColor()
        
        // 遮罩功能是否開啟
        dyLabel.layer.masksToBounds = true
        
        // 遮罩功能開啟後指定圓角大小
        dyLabel.layer.cornerRadius = 10.0
        //文字內容
        dyLabel.text = "My Game"
        //文字陰影偏移
        dyLabel.shadowOffset = CGSize(width: 1, height: 1)
        //文字陰影的顏色
        dyLabel.shadowColor = UIColor.blackColor()
        //文字大小
        dyLabel.font = UIFont.boldSystemFontOfSize(23)
        // 文字顏色
        dyLabel.textColor = UIColor.brownColor()
        // 文字對齊方式為：中央對齊
        dyLabel.textAlignment = NSTextAlignment.Center
        // layer座標指定，init Label時會將Layer座標設定與frame相同
        dyLabel.layer.position = CGPoint(x: self.view.bounds.width/2,y: 150)
        // view 中的背景顏色
        self.view.backgroundColor = UIColor.whiteColor()
        // 將設定好的Label加入原本的view
        self.view.addSubview(dyLabel)
        
        ////////////////////////////
//        var btn3:UIButton = UIButton(frame: CGRect(x: 50, y: 130, width: 180, height: 35))
//        btn3.setImage(UIImage(named: "button1.png"), forState: UIControlState.Normal)
//        btn3.titleLabel?.font = UIFont.boldSystemFontOfSize(30)
//        btn3.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
//        //btn3.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        btn3.setTitle("start", forState: UIControlState.Normal)
//        self.view.addSubview(btn3)

//        var clickButtonImage: UIButton! = UIButton(frame: CGRect(x: 50, y: 130, width: 180, height: 35))
//        clickButtonImage.setTitle("start", forState: UIControlState.Normal)
//
//        //宣告一個按鈕動作
//        func clickButton(sender: AnyObject) {
//            clickButtonImage.selected = !clickButtonImage.selected
//            //執行store_select這個function
//            store_select()
//        }
//        //設置store_select這個function
//        
//        func store_select(){
//            clickButtonImage.setImage(UIImage(named:"button1.png"),forState:UIControlState.Normal)
//            clickButtonImage.setImage(UIImage(named:"button2.png"),forState:UIControlState.Selected)
//        }
//        self.view.addSubview(clickButtonImage)

        ////////////////////////////////////////////////////////
        
        self.facebookLoginButton.center = self.view.center
        self.facebookLoginButton.readPermissions = ["public_profile","email","user_friends",]
        self.facebookLoginButton.delegate = self
        self.view!.addSubview(self.facebookLoginButton)
        self.facebookLoginButton.hidden = false

        FIRAuth.auth()?.addAuthStateDidChangeListener { auth ,user in
            if let user = user {
                let rootRef = FIRDatabase.database().reference()
                //if user 有登入過但users database 沒他的資料 userDetail == nil
                //if user 有登入過但users database highscore 沒他的資料  userDetail?.objectForKey("high_score") == nil
                
                rootRef.child("users").observeEventType(FIRDataEventType.Value, withBlock: {(snapshot)in
                    let usersDict = snapshot.value as? NSDictionary
                    let userDetail = usersDict?.objectForKey(user.uid)
                    if userDetail?.objectForKey("high_score") == nil || userDetail == nil {
                        //之前的暫存檔
                        let localHighScore = self.userDefault.objectForKey("fireBaseHighScore") as! Int
                        self.fireBaseHighScore = localHighScore
                        let protectedPage = self.storyboard?.instantiateViewControllerWithIdentifier("GameViewController") as! GameViewController
                        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                        appDelegate.window?.rootViewController = protectedPage
                    }
                        
                    else{
                        let fromfireBaseHighScore = userDetail?.objectForKey("high_score") as! Int
                        //            self.delegate!.userEditEnterInformation(self.fireBaseHighScore)
                        self.fireBaseHighScore = fromfireBaseHighScore
                        self.userDefault.setObject(fromfireBaseHighScore,forKey: "fireBaseHighScore")
                        
                        let protectedPage = self.storyboard?.instantiateViewControllerWithIdentifier("GameViewController") as! GameViewController
                        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                        appDelegate.window?.rootViewController = protectedPage
                
                    }
                })
                
//                self.facebookLoginButton.hidden = false

            }
            else{
                self.facebookLoginButton.center = self.view.center
                self.facebookLoginButton.readPermissions = ["public_profile","email","user_friends",]
                self.facebookLoginButton.delegate = self
                self.view!.addSubview(self.facebookLoginButton)
                self.facebookLoginButton.hidden = false
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        if (error != nil)
        {
            print(error.localizedDescription)
            facebookLoginButton.hidden = false
            return
        }
        else if result.isCancelled {
            // Handle cancellations
            facebookLoginButton.hidden = false

        }
        else {
            let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
            FIRAuth.auth()?.signInWithCredential(credential, completion: { (user,error) in
                if error != nil{
                    print(error!.localizedDescription)
                }
                else if result.isCancelled{     //使 登入取消不會跳error
                    print("Facebook login was cancelled.")
                }
                else{


                    print("User logged in with facebook...")
                    
//                    self.returnUserData()  //拿facebook 資料

                    NSUserDefaults.standardUserDefaults().setValue(user?.uid, forKey: "uid")
                    print(user?.uid)
                    self.userID = (user?.uid)!
                    print(self.userID)
                    let rootRef = FIRDatabase.database().reference()
                    rootRef.child("users").observeEventType(FIRDataEventType.Value, withBlock: {(snapshot)in
                        let usersDict = snapshot.value as! NSDictionary
                        let userDetail = usersDict.objectForKey(user!.uid)
                        let fromfireBaseHighScore = userDetail?.objectForKey("high_score") as! Int
                        //            self.delegate!.userEditEnterInformation(self.fireBaseHighScore)
                        self.fireBaseHighScore = fromfireBaseHighScore
                        self.userDefault.setObject(fromfireBaseHighScore,forKey: "fireBaseHighScore")
                    
                        let protectedPage = self.storyboard?.instantiateViewControllerWithIdentifier("MenuViewController") as! GameViewController
                        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                        appDelegate.window?.rootViewController = protectedPage
                    })
                }
            })
        }
    }
    
    func userEditEnterInformation(high_score:Int){
        

            self.fireBaseHighScore = high_score
//            let protectedPage = self.storyboard?.instantiateViewControllerWithIdentifier("GameViewController") as! GameViewController
//            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//            appDelegate.window?.rootViewController = protectedPage

    }
    
    func loginButtonWillLogin(loginButton: FBSDKLoginButton!) -> Bool {
        
        return true
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {

        try! FIRAuth.auth()!.signOut()
        print("User logged out of facebook...")
    }
    
    func returnUserData()
    {
        var dict : NSDictionary!
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email,link,picture.width(150).height(150)"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            if ((error) != nil)
            {
                
                print("Error: \(error)")
            }
            else
            {
                var myImageURL:String = ""
                print("fetched user: \(result)")
                dict = result as! NSDictionary
                self.userDefault.setObject(result.valueForKey("name"),forKey: "userName")
                
                self.userDefault.setObject(result.valueForKey("link"),forKey: "userLink")
                
                self.userDefault.setObject(result.valueForKey("email"),forKey: "userEmail")
                
                if let imageURL = dict.valueForKey("picture")?.valueForKey("data")?.valueForKey("url") as? String {
                    myImageURL = imageURL
                }
                //已解析
                self.userDefault.setObject(myImageURL,forKey: "userPictureURL")
                
                //                self.userDefault.synchronize()
                self.userName = self.userDefault.objectForKey("userName") as! String
                self.userPictureURL = self.userDefault.objectForKey("userPictureURL") as! String
                self.userLink = self.userDefault.objectForKey("userLink") as! String
                self.userEmail = self.userDefault.objectForKey("userEmail") as! String
                self.userPictureURL = self.userDefault.objectForKey("userPictureURL") as! String
                print("name:\(self.userName)")
                print("picture url:\(self.userPictureURL)")
                print("user link:\(self.userLink)")
                print("user mail: \(self.userEmail)")
                
            }
        })
    }


}
