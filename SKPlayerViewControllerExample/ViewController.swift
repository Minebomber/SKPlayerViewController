//
//  ViewController.swift
//  SKPlayerViewControllerExample
//
//  Created by Mark Lagae on 8/28/17.
//  Copyright © 2017 Mark Lagae. All rights reserved.
//

import UIKit

class ViewController: UIViewController, SKPlayerViewControllerDelegate {
    
    let playUrlString = "http://qthttp.apple.com.edgesuite.net/1010qwoeiuryfg/sl.m3u8" // Random Video
    //let playUrlString = "http://play.streamkit.tv/content/channel/sperantatv/vod/2017/9/semne_si_simboluri_0.player.m3u8" // SK Video
    //let playUrlString = "http://play.streamkit.tv/content/channel/sperantatv/live/sperantatv.player.m3u8" // SK Live
    
    let isLive = false
    
    var playerViewController: SKPlayerViewController!
    
    var hasPresentedPlayer = false
    
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
        //        self.showPlayerInView()
    }
    
    func presentPlayer() {
            let url = URL(string: playUrlString)
            self.playerViewController = SKPlayerViewController(url: url!, isLiveStream: isLive)
            self.playerViewController.delegate = self
            self.present(self.playerViewController, animated: true, completion: nil)
    }
    
    func showPlayerInView() {
        
        let url = URL(string: playUrlString)
        self.playerViewController = SKPlayerViewController(url: url!, isLiveStream: isLive)
        
        self.addChildViewController(self.playerViewController)
        
        self.playerViewController.view.frame = self.playerContainer.bounds
        self.playerContainer.addSubview(self.playerViewController.view)
        //playerVC.view.bindFrameToSuperviewBounds()
    }
    
    // MARK: SKPlayerViewControlerDelegate methods
    
    func playerViewControllerDidDismissCompletely(_ controller: SKPlayerViewController) {
        self.playerViewController.deallocPlayer()
        self.playerViewController = nil
        print(self.playerViewController)
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
