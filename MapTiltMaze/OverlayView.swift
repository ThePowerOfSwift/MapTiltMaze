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
    func play()
}

class OverlayView: UIView {
    
    var delegate:overlayDelegate!
    
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
                    //self.scene!.gamePaused = true
                    self.delegate.showGameCenterLogin(viewController!)
                }
            }
        }
    }
    
    func loadMainGameMenu(){
        var backButton:UIButton!
        var nextButton:UIButton!
        var startButton:UIButton!
        
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
        delegate.play()
    }
    
    func loadInGameMenu(){
        var resetButton:UIButton!
        var backButton:UIButton!
        
        let oneHalfWidth = frame.width / 2.0
        
        backButton = UIButton(frame: CGRectMake(0, 0, oneHalfWidth, frame.height))
        backButton.setTitle("Back", forState: .Normal)
        backButton.backgroundColor = UIColor.purpleColor()
        backButton.addTarget(self, action: "backActionInGame:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(backButton)
        
        resetButton = UIButton(frame: CGRectMake(oneHalfWidth, 0, oneHalfWidth, frame.height))
        resetButton.setTitle("Reset", forState: .Normal)
        resetButton.backgroundColor = UIColor.greenColor()
        resetButton.addTarget(self, action: "resetActionInGame:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(resetButton)
        
    }
    
    func backActionInGame(sender: UIButton){
        print("back InGame")
    }
    
    func startActionInGame(sender: UIButton){
        print("reset InGame")
    }
}
