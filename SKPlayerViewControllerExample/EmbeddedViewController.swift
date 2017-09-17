//
//  EmbeddedViewController.swift
//  SKPlayerViewControllerExample
//
//  Created by Mark Lagae on 9/15/17.
//  Copyright © 2017 Mark Lagae. All rights reserved.
//

import UIKit

class EmbeddedViewController: UIViewController {

    var playerViewController: SKPlayerViewController?
    
    let video = SKVideo(title: "Academica - 10 09 2017",
                        album: "Academica", duration: 2972.300,
                        streamUrl: "http://play.streamkit.tv/content/channel/sperantatv/vod/2017/9/academica_10_09_2017.player.m3u8",
                        thumbnailUrl: "http://space.streamkit.tv/hdd7/content/channel/sperantatv/vod/2017/9/academica_10_09_2017.mp4_medium.jpg",
                        dateCreated: Date(),
                        isLiveStream: false)
    
    @IBOutlet weak var playerContainerView: UIView!
    
    // NECESSARY OVERRIDES FOR PLAYER VIEW CONTROLLER
    override var childViewControllerForStatusBarHidden: UIViewController? {
        return playerViewController
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.playerViewController = SKPlayerViewController(video: self.video)
        self.addChildViewController(self.playerViewController!)
        
        self.playerViewController?.view.frame = self.playerContainerView.bounds
        self.playerContainerView.addSubview(self.playerViewController!.view)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // PREVENT MEMORY LEAKS
        self.playerViewController?.view.removeFromSuperview()
        self.playerViewController?.removeFromParentViewController()
        self.playerViewController?.deallocPlayer()
        self.playerViewController = nil
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
