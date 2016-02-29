//
//  OverlayView.swift
//  MapTiltMaze
//
//  Created by Stanley Chiang on 2/12/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import UIKit
import GameKit

protocol overlayDelegate {
    func showGameCenterLogin(sender: UIViewController)
    func updateLevel(direction:Int)
    func getLevel() -> Int
    func play(sender: UIButton)
    func resetGame()
    func stopMotion()
}

class OverlayView: UIView {
    
    var delegate:overlayDelegate!
    
    var backButton:UIButton!
    var nextButton:UIButton!
    var startButton:UIButton!
    
    var resetButton:UIButton!
    var backOrNextButton:UIButton!
    
    var purchaseButton:UIButton!
    
    var levelTextLabel:UILabel!
    var levelValueLabel:UILabel!
    
    var recordTextLabel:UILabel!
    var recordValueLabel:UILabel!
    
    let elementHeight:CGFloat = 50
    
    var records:[Int:String] = [Int:String]()
    
    var lockImage:UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Initialize Game Center
    func initGameCenter() {
        let localPlayer = GKLocalPlayer.localPlayer()
        // Check if user is already authenticated in game center
        if !localPlayer.authenticated {
            
            // Show the Login Prompt for Game Center
            localPlayer.authenticateHandler = {(viewController, error) -> Void in
                if viewController != nil {
                    self.delegate.showGameCenterLogin(viewController!)
                }else {
                    localPlayer.loadDefaultLeaderboardIdentifierWithCompletionHandler({ (leaderboardIdentifier, error) -> Void in
                        if error != nil {
                            print(error)
                        }else {
                            print(leaderboardIdentifier!)
                        }
                    })
                    self.loadLeaderBoard(level: 1)
                    self.loadLeaderBoard(level: 2)
                    self.loadLeaderBoard(level: 3)
                }
            }
        }
    }
    
    func recordTime(level level: Int, record:Int64){
        let score = GKScore(leaderboardIdentifier: "level\(level)ID")
        score.value = record
        GKScore.reportScores([score]) { (error) -> Void in
            if error != nil {
                print(error)
            }else {
                print("Score reported: \(score.value)")
                let time = record / 100
                self.records.updateValue("\(Int(time / 60)) : \(Int(time % 60)).\(Int(time * 10 % 10))", forKey: level)
            }
        }
    }
    
    func loadLeaderBoard(level level:Int){
        let leaderboardRequest = GKLeaderboard() as GKLeaderboard!
        leaderboardRequest.identifier = "level\(level)ID"
        if leaderboardRequest != nil {
            leaderboardRequest.loadScoresWithCompletionHandler({ (score, error) -> Void in
                if error != nil {
                    print(error)
                } else {
                    if let myscore:[GKScore] = score {
                        self.records.updateValue(myscore.first!.formattedValue!, forKey: level)
                        print(self.records)
                    } else {
                        self.recordTime(level: level, record: 10000)
                    }
                }
            })
        }
    }
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
//        http://stackoverflow.com/questions/4661589/how-to-get-touches-when-parent-view-has-userinteractionenabled-set-to-no-in-ios?rq=1
        let hitView = super.hitTest(point, withEvent: event)
        if hitView == self {
            return nil
        }else {
            return hitView
        }
    }
    
    func loadMainGameMenu(){
        
        if backButton != nil && startButton != nil && nextButton != nil {
            backButton.alpha = 1
            startButton.alpha = 1
            nextButton.alpha = 1
            return
        }
        
        let oneThirdWidth = frame.width / 3.0
        
        backButton = UIButton(frame: CGRectMake(0, frame.height - elementHeight, oneThirdWidth, elementHeight))
        backButton.setTitle("Back", forState: .Normal)
        backButton.backgroundColor = UIColor.clearColor()
        backButton.setTitleColor(UIColor.purpleColor(), forState: UIControlState.Normal)
        backButton.addTarget(self, action: "backActionMainMenu:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(backButton)
        
        startButton = UIButton(frame: CGRectMake(oneThirdWidth, frame.height - elementHeight, oneThirdWidth, elementHeight))
        startButton.setTitle("Start", forState: .Normal)
        startButton.backgroundColor = UIColor.clearColor()
        startButton.setTitleColor(UIColor.greenColor(), forState: UIControlState.Normal)
        startButton.addTarget(self, action: "startActionMainMenu:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(startButton)
        
        nextButton = UIButton(frame: CGRectMake(oneThirdWidth*2, frame.height - elementHeight, oneThirdWidth, elementHeight))
        nextButton.setTitle("Next", forState: .Normal)
        nextButton.backgroundColor = UIColor.clearColor()
        nextButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        nextButton.addTarget(self, action: "nextActionMainMenu:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(nextButton)
        
        let currentLevel = delegate.getLevel()
        levelValueLabel = UILabel(frame: CGRectMake(0,frame.height - 2 * elementHeight, frame.width / 2.0, elementHeight))
        levelValueLabel.text = "\(currentLevel)"
        levelValueLabel.textAlignment = .Center
        addSubview(levelValueLabel)
        
        levelTextLabel = UILabel(frame: CGRectMake(0,frame.height - 3 * elementHeight, frame.width / 2.0, elementHeight))
        levelTextLabel.text = "Level"
        levelTextLabel.textAlignment = .Center
        addSubview(levelTextLabel)
        
        recordValueLabel = UILabel(frame: CGRectMake(frame.width / 2.0,frame.height - 2 * elementHeight, frame.width / 2.0, elementHeight))
        
        recordValueLabel.text = "Loading..."
        recordValueLabel.textAlignment = .Center
        addSubview(recordValueLabel)
        
        
        recordTextLabel = UILabel(frame: CGRectMake(frame.width / 2.0,frame.height - 3 * elementHeight, frame.width / 2.0, elementHeight))
        recordTextLabel.text = "Record"
        recordTextLabel.textAlignment = .Center
        addSubview(recordTextLabel)
        
    }
    
    func backActionMainMenu(sender: UIButton){
        delegate.updateLevel(-1)
        recordValueLabel.text = getRecordValue()
        checkIfLevelLocked()
    }

    func nextActionMainMenu(sender: UIButton){
        delegate.updateLevel(1)
        recordValueLabel.text = getRecordValue()
        checkIfLevelLocked()
    }
    
    func checkIfLevelLocked() {
        if delegate.getLevel() + 1 == 4 {
            addLockedLevelViews()
        }else {
            removeAddLockedLevelViews()
        }
    }
    
    func startActionMainMenu(sender: UIButton){
        delegate.play(sender)
    }
    
    func getRecordValue() -> String{
        let currentLevel = delegate.getLevel()
        var recordString = "Loading..."
        for (k,v) in records {
            if k == currentLevel + 1 {
                recordString = v
                break
            }
        }
        return recordString
    }
    
    func hideMainMenu(){
        backButton.alpha = 0
        startButton.alpha = 0
        nextButton.alpha = 0
    }
    
    func loadInGameMenu(){
        
        if backOrNextButton != nil && resetButton != nil {
            backOrNextButton.alpha = 1
            resetButton.alpha = 1
            return
        }
        
        let oneHalfWidth = frame.width / 2.0
        
        backOrNextButton = UIButton(frame: CGRectMake(0, frame.height - elementHeight, oneHalfWidth, elementHeight))
        backOrNextButton.setTitle("Back", forState: .Normal)
        backOrNextButton.backgroundColor = UIColor.purpleColor()
        backOrNextButton.addTarget(self, action: "backActionInGame:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(backOrNextButton)
        
        resetButton = UIButton(frame: CGRectMake(oneHalfWidth, frame.height - elementHeight, oneHalfWidth, elementHeight))
        resetButton.setTitle("Reset", forState: .Normal)
        resetButton.backgroundColor = UIColor.greenColor()
        resetButton.addTarget(self, action: "resetActionInGame:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(resetButton)
        
    }
    
    func backActionInGame(sender: UIButton){
        print("back InGame")
        delegate.stopMotion()
        
        recordValueLabel.text = "Loading..."
        
        delegate.updateLevel(0)
        hideInGameMenu()
        loadMainGameMenu()
    }
    
    func resetActionInGame(sender: UIButton){
        print("reset InGame")
        recordValueLabel.text = "00:00:00"
        delegate.updateLevel(0)
        delegate.resetGame()
    }
    
    func hideInGameMenu(){
        backOrNextButton.alpha = 0
        resetButton.alpha = 0
    }
    
    func addLockedLevelViews(){
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        startButton.userInteractionEnabled = false
        
        if purchaseButton != nil && lockImage != nil{
            purchaseButton.alpha = 1
            lockImage.alpha = 1
            return
        }

        let blockFrame = CGRectMake(frame.width / 3, frame.height / 3, frame.width / 3, frame.height / 3)
        
        lockImage = UIImageView(image: UIImage(named: "lock"))
        lockImage.frame = blockFrame
        addSubview(lockImage)

        purchaseButton = UIButton()
        purchaseButton.frame = blockFrame
        purchaseButton.setTitle("Buy Map: $.99", forState: UIControlState.Normal)
        purchaseButton.addTarget(self, action: "purchase:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(purchaseButton)
        
        
    }
    
    func removeAddLockedLevelViews(){
        backgroundColor = UIColor.clearColor()
        startButton.userInteractionEnabled = true
        if purchaseButton != nil && lockImage != nil {
            purchaseButton.alpha = 0
            lockImage.alpha = 0
        }
    }
    
    func purchase(sender: UIButton){
        print("purchasing")
    }
}
