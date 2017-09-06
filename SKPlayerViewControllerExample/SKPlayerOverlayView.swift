//
//  SKPlayerOverlayView.swift
//  SKPlayerViewControllerExample
//
//  Created by Mark Lagae on 9/3/17.
//  Copyright © 2017 Mark Lagae. All rights reserved.
//

import UIKit

class SKPlayerOverlayView: UIView {

    // The webviews are for displaying SVGs.
    @IBOutlet weak var airplayImageView: UIImageView?
    @IBOutlet weak var chromecastImageView: UIImageView?
    
    @IBOutlet weak var textLabel: UILabel?
    
    @IBOutlet weak var airplayWidth: NSLayoutConstraint?
    @IBOutlet weak var chromecastWidth: NSLayoutConstraint?
    
    @IBOutlet weak var contentView: UIView!

    private var overlayBackgroundColor: UIColor = UIColor(red: 56/255, green: 58/255, blue: 70/255, alpha: 1.0)
    
    var state: SKPlayerExternalState = .none {
        didSet {
            self.loadImagesToViews()
        }
    }
    
    init() {
        super.init(frame: CGRect.zero)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("SKPlayerOverlayView", owner: self, options: nil)
        self.addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]

        self.loadImagesToViews()
    }
    
    private func loadImagesToViews() {
        
        self.backgroundColor = self.overlayBackgroundColor
        self.contentView.backgroundColor = self.overlayBackgroundColor
        
        switch state {
            case .none: updateViewForNone()
            case .airplay: updateViewForAirplay()
            case .chromecast: updateViewForChromecast()
            case .both: updateViewForBoth()
        }
    }
    
    private func airplayImage() -> UIImage {
        return #imageLiteral(resourceName: "sk_apple_tv").resizeTo(height: self.airplayImageView!.bounds.size.height)
    }
    
    private func chromecastImage() -> UIImage {
        return #imageLiteral(resourceName: "sk_chrome_logo").resizeTo(height: self.chromecastImageView!.bounds.size.height)
    }
    
    private func updateViewForNone() {
        
        self.isHidden = true
        
        self.textLabel?.text = ""
        
        self.airplayImageView?.image = nil
        self.chromecastImageView?.image = nil
        
        self.airplayWidth?.constant = 120
        self.chromecastWidth?.constant = 120
        
        UIView.animate(withDuration: 0.1) {
            self.layoutIfNeeded()
        }
    }
    
    private func updateViewForAirplay() {
        
        self.isHidden = false
        
        self.textLabel?.text = "Your content is playing on your Apple TV"
        
        self.chromecastImageView?.image = nil
        self.airplayImageView?.image = self.airplayImage()
        
        // Animate constraints
        
        self.airplayWidth?.constant = 240
        self.chromecastWidth?.constant = 0
        
        UIView.animate(withDuration: 0.1) {
            self.layoutIfNeeded()
        }
    }
    
    private func updateViewForChromecast() {
        
        self.isHidden = false
        
        self.textLabel?.text = "Your content is playing on your Chomecast Device"
        
        self.airplayImageView?.image = nil
        self.chromecastImageView?.image = self.chromecastImage()
        
        // Animate constraints
        
        self.airplayWidth?.constant = 0
        self.chromecastWidth?.constant = 240
        
        UIView.animate(withDuration: 0.1) {
            self.layoutIfNeeded()
        }
    }
    
    private func updateViewForBoth() {

        self.isHidden = false
        
        self.textLabel?.text = "Your content is playing on both your Apple TV and Chomecast Device"
        
        self.airplayImageView?.image = self.airplayImage()
        self.chromecastImageView?.image = self.chromecastImage()
        
        // Animate constraints
        
        self.airplayWidth?.constant = 120
        self.chromecastWidth?.constant = 120
        
        UIView.animate(withDuration: 0.1) {
            self.layoutIfNeeded()
        }
    }
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
