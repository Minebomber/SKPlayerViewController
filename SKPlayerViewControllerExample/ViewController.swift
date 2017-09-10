//
//  ViewController.swift
//  SKPlayerViewControllerExample
//
//  Created by Mark Lagae on 8/28/17.
//  Copyright © 2017 Mark Lagae. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let playUrlString = "http://qthttp.apple.com.edgesuite.net/1010qwoeiuryfg/sl.m3u8" // Random Video
    //let playUrlString = "http://play.streamkit.tv/content/channel/sperantatv/vod/2017/9/semne_si_simboluri_0.player.m3u8" // SK Video
    //let playUrlString = "http://play.streamkit.tv/content/channel/sperantatv/live/sperantatv.player.m3u8" // SK Live
    
    let isLive = false
    
    var playerViewController: SKPlayerViewController!
    
    override var childViewControllerForStatusBarHidden: UIViewController? {
        return playerViewController
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

        let url = URL(string: playUrlString)
        playerViewController = SKPlayerViewController(url: url!, isLiveStream: isLive)
        self.present(playerViewController, animated: true, completion: nil)
        
    }
    
    func showPlayerInView() {

        let url = URL(string: playUrlString)
        playerViewController = SKPlayerViewController(url: url!, isLiveStream: isLive)
        
        self.addChildViewController(playerViewController)
        
        playerViewController.view.frame = self.playerContainer.bounds
        self.playerContainer.addSubview(playerViewController.view)
        //playerVC.view.bindFrameToSuperviewBounds()
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
