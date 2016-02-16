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
    func play(sender: UIButton)
    func resetTimer()
    func stopMotion()
}

class OverlayView: UIView {
    
    var delegate:overlayDelegate!
    
    var backButton:UIButton!
    var nextButton:UIButton!
    var startButton:UIButton!
    
    var resetButton:UIButton!
    var backOrNextButton:UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Initialize Game Center
    func initGameCenter() {
        // Check if user is already authenticated in game center
        if GKLocalPlayer.localPlayer().authenticated == false {
            
            // Show the Login Prompt for Game Center
            GKLocalPlayer.localPlayer().authenticateHandler = {(viewController, error) -> Void in
                if viewController != nil {
                    self.delegate.showGameCenterLogin(viewController!)
                }
            }
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
        
        backButton = UIButton(frame: CGRectMake(0, 0, oneThirdWidth, frame.height))
        backButton.setTitle("Back", forState: .Normal)
        backButton.backgroundColor = UIColor.purpleColor()
        backButton.addTarget(self, action: "backActionMainMenu:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(backButton)
        
        startButton = UIButton(frame: CGRectMake(oneThirdWidth, 0, oneThirdWidth, frame.height))
        startButton.setTitle("Start", forState: .Normal)
        startButton.backgroundColor = UIColor.greenColor()
        startButton.addTarget(self, action: "startActionMainMenu:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(startButton)
        
        nextButton = UIButton(frame: CGRectMake(oneThirdWidth*2, 0, oneThirdWidth, frame.height))
        nextButton.setTitle("Next", forState: .Normal)
        nextButton.backgroundColor = UIColor.blueColor()
        nextButton.addTarget(self, action: "nextActionMainMenu:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(nextButton)
        
    }

    func backActionMainMenu(sender: UIButton){
        delegate.updateLevel(-1)
    }
    
    func nextActionMainMenu(sender: UIButton){
        delegate.updateLevel(1)
    }
    
    func startActionMainMenu(sender: UIButton){
        delegate.play(sender)
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
        
        backOrNextButton = UIButton(frame: CGRectMake(0, 0, oneHalfWidth, frame.height))
        backOrNextButton.setTitle("Back", forState: .Normal)
        backOrNextButton.backgroundColor = UIColor.purpleColor()
        backOrNextButton.addTarget(self, action: "backActionInGame:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(backOrNextButton)
        
        resetButton = UIButton(frame: CGRectMake(oneHalfWidth, 0, oneHalfWidth, frame.height))
        resetButton.setTitle("Reset", forState: .Normal)
        resetButton.backgroundColor = UIColor.greenColor()
        resetButton.addTarget(self, action: "resetActionInGame:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(resetButton)
        
    }
    
    func backActionInGame(sender: UIButton){
        print("back InGame")
        delegate.stopMotion()
        delegate.updateLevel(0)
        hideInGameMenu()
        loadMainGameMenu()
    }
    
    func resetActionInGame(sender: UIButton){
        print("reset InGame")
        delegate.updateLevel(0)
        delegate.resetTimer()
    }
    
    func hideInGameMenu(){
        backOrNextButton.alpha = 0
        resetButton.alpha = 0
    }
}
