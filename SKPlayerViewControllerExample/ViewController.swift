//
//  ViewController.swift
//  SKPlayerViewControllerExample
//
//  Created by Mark Lagae on 8/28/17.
//  Copyright © 2017 Mark Lagae. All rights reserved.
//

import UIKit

class ViewController: UIViewController, SKPlayerViewControllerDelegate {
    
    var playerViewController: SKPlayerViewController!
    
    var hasPresentedPlayer = false
    
    let video = SKVideo(title: "Academica - 10 09 2017",
                        album: "Academica", duration: 2972.300,
                        streamUrl: "http://play.streamkit.tv/content/channel/sperantatv/vod/2017/9/academica_10_09_2017.player.m3u8",
                        thumbnailUrl: "http://space.streamkit.tv/hdd7/content/channel/sperantatv/vod/2017/9/academica_10_09_2017.mp4_medium.jpg",
                        isLiveStream: false)
    
    override var childViewControllerForStatusBarHidden: UIViewController? {
        return playerViewController
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBOutlet weak var playerContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //self.presentPlayer()
        self.showPlayerInView()
    }
    
    func presentPlayer() {
        self.playerViewController = SKPlayerViewController(video: self.video)
        self.playerViewController.delegate = self
        self.present(self.playerViewController, animated: true, completion: nil)
    }
    
    func showPlayerInView() {
        self.playerViewController = SKPlayerViewController(video: self.video)
        
        self.addChildViewController(self.playerViewController)
        
        self.playerViewController.view.frame = self.playerContainer.bounds
        self.playerContainer.addSubview(self.playerViewController.view)
        //playerVC.view.bindFrameToSuperviewBounds()
    }
    
    // MARK: SKPlayerViewControlerDelegate methods
    
    func playerViewControllerDidDismissCompletely(_ controller: SKPlayerViewController) {
        self.playerViewController.deallocPlayer()
        self.playerViewController = nil
    }
    
    @IBAction func presentPlayerAction() {
        self.presentPlayer()
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}
