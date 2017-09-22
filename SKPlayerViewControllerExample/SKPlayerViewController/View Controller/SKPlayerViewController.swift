//
//  SKPlayerViewController.swift
//  SKPlayerViewControllerExample
//
//  Created by Mark Lagae on 8/28/17.
//  Copyright © 2017 Mark Lagae. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import MediaPlayer
import GoogleCast

class SKPlayerViewController: UIViewController, GCKSessionManagerListener, GCKRemoteMediaClientListener {
    
    // MARK: - Variables
    
    private var updateTimer: Timer?
    
    private var isShowingControls = true
    
    private var video: SKVideo!
    
    private var castMediaController = GCKUIMediaController()
    private var castSession: GCKCastSession?
    
    weak var delegate: SKPlayerViewControllerDelegate!
    
    private var playbackLikelyToKeepUpContext = 0
    
    private var playUrl: URL!
    
    private var videoIsHLS: Bool = false
    
    private var player: AVPlayer? = AVPlayer()
    private var playerLayer: AVPlayerLayer!
    
    private var timeObserver: AnyObject!
    
    private var playerRateBeforeSeek: Float = 0
    
    // New seek stuff
    private var isSeekInProgress = false
    private var chaseTime = kCMTimeZero
    private var playerCurrentItemStatus: AVPlayerItemStatus = .unknown
    
    private var volumeView = MPVolumeView()
    private var chromecastButton = GCKUICastButton()
    
    private var airplayEnabled = false {
        didSet {
            self.updateStateForIndependentExternalVars()
        }
    }
    
    private var chromecastEnabled = false {
        didSet {
            self.updateStateForIndependentExternalVars()
        }
    }
    
    private var playerExternalState: SKPlayerExternalState = .none {
        didSet {
            self.playerOverlayView?.state = self.playerExternalState
        }
    }
    
    private var hasSetLabelWidths = false
    
    // Chromecast
    private var sessionManager: GCKSessionManager!
    
    // Constants for KVO
    private let kPlaybackLikelyToKeepUp = "currentItem.playbackLikelyToKeepUp"
    private let kPlaybackBufferEmpty = "currentItem.playbackBufferEmpty"
    private let kPlaybackBufferFull = "currentItem.playbackBufferFull"
    private let kPlayerStatus = "currentItem.status"
    
    // Tap Gesture Recognizer for showing / hiding view
    private let hideTapGestureRecognizer = UITapGestureRecognizer()
    
    // Tap Gesture for zooming the player (aspect fill -> aspect fit)
    private let zoomTapGestureRecognizer = UITapGestureRecognizer()
    
    // Dismiss/Present Stuff
    private var proxyView: UIView? // View to save position of embeded self (if needed)
    
    private var isEmbeded = false // default value
    private var isFullscreen = false { // default value
        didSet {
            self.updateFullscreenImage()
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return isFullscreen || (UIApplication.shared.statusBarOrientation == .landscapeLeft || UIApplication.shared.statusBarOrientation == .landscapeRight)
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    private var statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height != 0 ? UIApplication.shared.statusBarFrame.height : 20.0
    
    // MARK: Interface Builder Connections
    @IBOutlet weak var airplayContainer: UIView?
    @IBOutlet weak var chromecastContainer: UIView?
    
    @IBOutlet weak var playPauseButton: UIButton?
    
    @IBOutlet weak var timeElapsedLabel: UILabel?
    @IBOutlet weak var timeRemainingLabel: UILabel?
    
    @IBOutlet weak var seekSlider: UISlider?
    
    @IBOutlet weak var fullscreenButton: UIButton?
    
    @IBOutlet weak var bottomBarContainer: UIView?
    @IBOutlet weak var topBarContainer: UIView?
    @IBOutlet weak var statusBarBacking: UIView?
    
    @IBOutlet weak var bufferingIndicator: UIActivityIndicatorView?
    
    @IBOutlet weak var hlsLabel: UILabel?
    
    @IBOutlet weak var playerOverlayView: SKPlayerOverlayView?
    
    @IBOutlet weak var timeElapsedWidth: NSLayoutConstraint?
    @IBOutlet weak var timeRemainingWidth: NSLayoutConstraint?
    
    // MARK: Config
    let playImageName: String = "sk_play"
    let playColor: UIColor = UIColor.white
    let playHighlightedColor: UIColor = UIColor(white: 0.75, alpha: 1.0)
    
    let pauseImageName: String = "sk_pause"
    let pauseColor: UIColor = UIColor.white
    let pauseHighlightedColor: UIColor = UIColor(white: 0.75, alpha: 1.0)
    
    let airplayOffImageName: String = "sk_airplay_off"
    let airplayOnImageName: String = "sk_airplay_on"
    let airplayHighlightedColor: UIColor = UIColor(white: 0.75, alpha: 1.0)
    
    let chromecastTintColor: UIColor = UIColor.white
    
    let fullScreenImageName: String = "sk_fullscreen"
    let fullScreenColor: UIColor = UIColor.white
    let fullScreenHighlightedColor: UIColor = UIColor.white
    
    let normalScreenImageName: String = "sk_normalscreen"
    let normalScreenColor: UIColor = UIColor.white
    let normalScreenHighlightedColor: UIColor = UIColor.white
    
    let controlsFadeTime: TimeInterval = 0.25
    let controlsFadeAnimationCurve: UIViewAnimationOptions = .curveLinear
    
    let fullscreenTransitionTime: TimeInterval = 0.25
    let fullscreenTransitionAnimationCurve: UIViewAnimationOptions = .curveEaseOut
    
    // MARK: -
    
    // MARK: Inits
    
    init(video: SKVideo) {
        super.init(nibName: "SKPlayerViewController", bundle: nil)
        
        self.video = video
        
        self.playUrl = URL(string: self.video.streamUrl)
        self.videoIsHLS = self.video.isLiveStream
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black
        
        // setup UI actions
        self.addActionsToOutlets()
        
        // Setup the playerLayer
        self.playerLayer = AVPlayerLayer(player: player)
        view.layer.insertSublayer(playerLayer, at: 0)
        
        let playerItem = AVPlayerItem(url: self.playUrl)
        self.player?.replaceCurrentItem(with: playerItem)
        
        // Setup KVO
        self.player?.addObserver(self, forKeyPath: kPlaybackLikelyToKeepUp, options: .new, context: nil)
        self.player?.addObserver(self, forKeyPath: kPlaybackBufferFull, options: .new, context: nil)
        self.player?.addObserver(self, forKeyPath: kPlaybackBufferEmpty, options: .new, context: nil)
        self.player?.addObserver(self, forKeyPath: kPlayerStatus, options: [.new, .initial], context: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SKPlayerViewController.updateLocalStatusBarFrameHeight), name: .UIApplicationDidChangeStatusBarFrame, object: nil)
        
        self.setSeekSliderThumbImage()
        
        // Set target for tap gesture recognizer
        self.hideTapGestureRecognizer.addTarget(self, action: #selector(SKPlayerViewController.toggleControlsHidden(sender:)))
        self.view.addGestureRecognizer(self.hideTapGestureRecognizer)
        
        self.zoomTapGestureRecognizer.numberOfTapsRequired = 2
        self.zoomTapGestureRecognizer.addTarget(self, action: #selector(SKPlayerViewController.toggleVideoGravityOfPlayer))
        self.view.addGestureRecognizer(self.zoomTapGestureRecognizer)
        
        self.hideTapGestureRecognizer.require(toFail: self.zoomTapGestureRecognizer)
        
        self.updateUIForHLSIfNeeded()
        
        self.addExternalPlayerButtons()
        
        self.sessionManager = GCKCastContext.sharedInstance().sessionManager
        self.sessionManager.add(self)
        
        // Add top layout guide constraint
        let topGuide = self.topLayoutGuide
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[topGuide]-0-[topView]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["topGuide" : topGuide, "topView" : self.topBarContainer!]))
        
        // Disconnect if new video (to prevent wierd glitches with different videos)
        if self.sessionManager.connectionState == .connected || self.sessionManager.connectionState == GCKConnectionState.connecting {
            self.sessionManager.endSessionAndStopCasting(true)
        }
        
        if self.parent != nil && self.presentingViewController == nil {
            self.isEmbeded = true
            self.isFullscreen = false
        } else {
            self.isEmbeded = false
            self.isFullscreen = true
        }
        
        self.setNeedsStatusBarAppearanceUpdate()
        
        // Setup the timer for updating slider and time labels
        self.updateTimer = Timer.scheduledTimer(timeInterval: 0.8, target: self, selector: #selector(SKPlayerViewController.updateTimesInUI), userInfo: nil, repeats: true)
        
        self.playPlayer() // Start playback
        self.hideControls()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.parent != nil && self.presentingViewController == nil {
            self.isEmbeded = true
            self.isFullscreen = false
        } else {
            self.isEmbeded = false
            self.isFullscreen = true
        }
        
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.playerLayer.frame = self.view.bounds
    }
    
    // MARK: - Chromecast Methods
    func sessionManager(_ sessionManager: GCKSessionManager, didStart session: GCKSession) {
        self.switchChromecastToRemotePlayback()
    }
    
    func sessionManager(_ sessionManager: GCKSessionManager, didResumeSession session: GCKSession) {
        self.switchChromecastToRemotePlayback()
    }
    
    func sessionManager(_ sessionManager: GCKSessionManager, didEnd session: GCKSession, withError error: Error?) {
        self.switchChromecastToLocalPlayback()
    }
    
    func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
        if mediaStatus?.playerState == .buffering || mediaStatus?.playerState == .loading {
            if self.playerExternalState == .chromecast {
                self.addBufferingIndiciator()
            }
        } else {
            if self.playerExternalState == .chromecast {
                self.removeBufferingIndicator()
            }
        }
    }
    
    private func generateMediaInformation() -> GCKMediaInformation {
        let metadata = GCKMediaMetadata(metadataType: .movie)
        metadata.setString(self.video.title, forKey: kGCKMetadataKeyTitle)
        metadata.setString(self.video.album, forKey: kGCKMetadataKeyAlbumTitle)
        
        metadata.addImage(GCKImage(url: URL(string: self.video.thumbnailUrl)!, width: 480, height: 720))
        
        let mediaInfo = GCKMediaInformation(contentID: self.video.streamUrl, streamType: .buffered, contentType: "video/mp4", metadata: metadata, streamDuration: self.video.duration, mediaTracks: nil, textTrackStyle: nil, customData: nil)
        
        return mediaInfo
    }
    
    private func playOnChromecastRemotely(url: String) {
        let castSession = GCKCastContext.sharedInstance().sessionManager.currentCastSession
        if castSession != nil {
            castSession?.remoteMediaClient?.loadMedia(self.generateMediaInformation(), autoplay: true)
        } else {
            NSLog("no cast session")
        }
    }
    
    private func switchChromecastToLocalPlayback() {
        if self.chromecastEnabled == false { return }
        
        if self.playerExternalState == .chromecast {
            let position = self.castMediaController.lastKnownStreamPosition
            
            let newTime = CMTimeMakeWithSeconds(position, self.player!.currentItem!.duration.timescale)
            
            self.chromecastEnabled = false
            
            if newTime.isValid { // Time might not be valid if livestream
                self.stopPlayingAndSeekSmoothlyToTime(newChaseTime: newTime)
            }
        }
        
        self.castSession?.remoteMediaClient?.remove(self)
        self.castSession = nil
    }
    
    private func switchChromecastToRemotePlayback() {
        if self.chromecastEnabled == true { return }
        
        self.castSession = self.sessionManager.currentCastSession
        
        let builder = GCKMediaQueueItemBuilder()
        builder.mediaInformation = self.generateMediaInformation()
        if self.player != nil {
            builder.autoplay = self.player!.rate > Float(0.0)
        }
        builder.preloadTime = 0
        
        let item = builder.build()
        
        if self.player != nil {
            
            let playPosition = self.player?.currentItem?.currentTime()
            
            self.castSession?.remoteMediaClient?.queueLoad([item], start: 0, playPosition: CMTimeGetSeconds(playPosition!), repeatMode: .off, customData: nil)
        }
        self.pausePlayer()
        self.chromecastEnabled = true
        
        self.castSession?.remoteMediaClient?.add(self)
    }
    
    // MARK: - UI Initial Config Functions
    
    private func setSeekSliderThumbImage() {
        self.seekSlider?.setThumbImage(#imageLiteral(resourceName: "sk_seek_thumb_image"), for: .normal)
    }
    
    private func setWidthOfTimeLabelsBasedOnDuration(_ duration: Float) {
        
        if !hasSetLabelWidths && duration > 0.0 {
            
            let durationString = "-\(hmsToString(hms: secondsToHoursMinutesSeconds(seconds: Int(roundf(duration)))))"
            
            let font = self.timeRemainingLabel!.font!
            
            let attributes = [NSAttributedStringKey.font : font as Any]
            
            let durationWidth = ceil(durationString.size(withAttributes: attributes).width)
            
            self.timeElapsedWidth?.constant = durationWidth
            self.timeRemainingWidth?.constant = durationWidth
            
            UIView.animate(withDuration: 0.1, animations: {
                self.view.layoutIfNeeded()
            }, completion: { (_) in
                self.hasSetLabelWidths = true
            })
            
        }
    }
    
    // MARK: - Outlet Functions
    
    private func addActionsToOutlets() {
        // In this function we will programmatically add all the actions to buttons and sliders.
        
        // Playpause button
        self.playPauseButton?.addTarget(self, action: #selector(SKPlayerViewController.playPause), for: .touchUpInside)
        
        // Seek slider
        self.seekSlider?.addTarget(self, action: #selector(SKPlayerViewController.sliderBeganTracking), for: .touchDown)
        self.seekSlider?.addTarget(self, action: #selector(SKPlayerViewController.sliderEndedTracking), for: .touchUpInside)
        self.seekSlider?.addTarget(self, action: #selector(SKPlayerViewController.sliderEndedTracking), for: .touchUpOutside)
        self.seekSlider?.addTarget(self, action: #selector(SKPlayerViewController.sliderValueChanged), for: .valueChanged)
        
        self.fullscreenButton?.addTarget(self, action: #selector(SKPlayerViewController.toggleFullScreen), for: .touchUpInside)
    }
    
    private func addExternalPlayerButtons() {
        self.addAirplayButton()
        self.addChromecastButton()
    }
    
    private func addAirplayButton() {
        self.volumeView.showsVolumeSlider = false
        self.volumeView.sizeToFit()
        
        self.volumeView.frame = self.airplayContainer!.bounds
        
        // Customization
        let airplayOffImage = UIImage(named: airplayOffImageName)
        self.volumeView.setRouteButtonImage(airplayOffImage, for: .normal)
        
        let airplayHighlightedImage = airplayOffImage?.maskWith(color: airplayHighlightedColor)
        self.volumeView.setRouteButtonImage(airplayHighlightedImage, for: .highlighted)
        
        let airplayOnImage = UIImage(named: airplayOnImageName)
        self.volumeView.setRouteButtonImage(airplayOnImage, for: .selected)
        
        self.airplayContainer?.addSubview(self.volumeView)
        self.airplayContainer?.backgroundColor = UIColor.clear
        
        NotificationCenter.default.addObserver(self, selector: #selector(SKPlayerViewController.wirelessRouteActiveChanged), name: .MPVolumeViewWirelessRouteActiveDidChange, object: nil)
    }
    
    private func addChromecastButton() {
        
        self.chromecastButton.frame = self.chromecastContainer!.bounds
        self.chromecastButton.tintColor = self.chromecastTintColor
        
        self.chromecastContainer?.addSubview(self.chromecastButton)
        self.chromecastContainer?.backgroundColor = UIColor.clear
    }
    
    
    @objc private func playPause() {
        if self.player != nil {
            let isPlaying = self.player!.rate > 0
            if isPlaying {
                self.pausePlayer()
            } else {
                self.playPlayer()
            }
        }
    }
    
    private func playPlayer() {
        
        let pauseBaseImage = UIImage(named: pauseImageName)!
        
        let pauseImage = pauseBaseImage.maskWith(color: pauseColor)
        self.playPauseButton?.setImage(pauseImage, for: .normal)
        
        let pauseHighlightedImage = pauseBaseImage.maskWith(color: pauseHighlightedColor)
        self.playPauseButton?.setImage(pauseHighlightedImage, for: .highlighted)
        self.playPauseButton?.setImage(pauseHighlightedImage, for: .selected)
        
        self.player?.play()
        
        if self.chromecastEnabled {
            self.castSession?.remoteMediaClient?.play()
        }
    }
    
    private func pausePlayer() {
        
        let playBaseImage = UIImage(named: playImageName)!
        
        let playImage = playBaseImage.maskWith(color: playColor)
        self.playPauseButton?.setImage(playImage, for: .normal)
        
        let playHighlightedImage = playBaseImage.maskWith(color: playHighlightedColor)
        self.playPauseButton?.setImage(playHighlightedImage, for: .highlighted)
        self.playPauseButton?.setImage(playHighlightedImage, for: .selected)
        
        self.player?.pause()
        
        if self.chromecastEnabled {
            self.castSession?.remoteMediaClient?.pause()
        }
    }
    
    @objc private func sliderBeganTracking() {
        if self.player != nil {
            self.playerRateBeforeSeek = self.player!.rate
            self.pausePlayer()
        }
    }
    
    @objc private func sliderEndedTracking() {
        if self.player != nil {
            let videoDuration = Float(CMTimeGetSeconds(self.player!.currentItem!.duration))
            let elapsedTime = videoDuration * seekSlider!.value
            
            self.updateTimeLabelsWith(elapsedTime: elapsedTime, duration: videoDuration)
            
            let timescale = self.player!.currentItem!.asset.duration.timescale
            
            let newSeekTime = CMTimeMakeWithSeconds(Float64(elapsedTime), timescale)
            self.stopPlayingAndSeekSmoothlyToTime(newChaseTime: newSeekTime)
        }
    }
    
    @objc private func sliderValueChanged() {
        if self.player != nil {
            let videoDuration = Float(CMTimeGetSeconds(self.player!.currentItem!.duration))
            let elapsedTime = videoDuration * seekSlider!.value
            
            self.updateTimeLabelsWith(elapsedTime: elapsedTime, duration: videoDuration)
            
            let timescale = self.player!.currentItem!.asset.duration.timescale
            
            let newSeekTime = CMTimeMakeWithSeconds(Float64(elapsedTime), timescale)
            self.stopPlayingAndSeekSmoothlyToTime(newChaseTime: newSeekTime)
        }
    }
    
    @objc private func toggleFullScreen() {
        if isEmbeded {
            if isFullscreen {
                self.exitFullScreenToEmbed()
            } else {
                self.enterFullScreenFromEmbed()
            }
        } else {
            self.dismissCompletely()
        }
    }
    
    // MARK: - UI Update Functions
    
    @objc private func updateTimesInUI() {
        
        if self.player == nil { return }
        
        let elapsedTime = self.player!.currentTime()
        
        if self.playerExternalState != .chromecast {
            
            let elapsedTimeSeconds = Float(CMTimeGetSeconds(elapsedTime))
            let duration = Float(CMTimeGetSeconds(self.player!.currentItem!.duration))
            
            self.updateTimeLabelsWith(elapsedTime: elapsedTimeSeconds, duration: duration)
            self.updateSeekSliderWith(elapsedTime: elapsedTimeSeconds, duration: Float(CMTimeGetSeconds(self.player!.currentItem!.duration)))
            self.setWidthOfTimeLabelsBasedOnDuration(duration)
            
        } else {
            
            if self.castSession != nil && self.castSession!.remoteMediaClient != nil {
                
                let elapsedTimeSeconds = Float(self.castSession!.remoteMediaClient!.approximateStreamPosition())
                let duration = Float(CMTimeGetSeconds(self.player!.currentItem!.duration))
                
                self.updateTimeLabelsWith(elapsedTime: elapsedTimeSeconds, duration: duration)
                self.updateSeekSliderWith(elapsedTime: elapsedTimeSeconds, duration: duration)
                self.setWidthOfTimeLabelsBasedOnDuration(duration)
            }
        }
    }
    
    @objc private func toggleVideoGravityOfPlayer() {
        if self.playerLayer.videoGravity == AVLayerVideoGravity.resizeAspect {
            self.playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            self.player?.externalPlaybackVideoGravity = AVLayerVideoGravity.resizeAspectFill
        } else {
            self.playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
            self.player?.externalPlaybackVideoGravity = AVLayerVideoGravity.resizeAspect
        }
    }
    
    private func updateUIForHLSIfNeeded() {
        if self.videoIsHLS {
            self.seekSlider?.isHidden = true
            self.timeElapsedLabel?.isHidden = true
            self.timeRemainingLabel?.isHidden = true
            
            self.hlsLabel?.isHidden = false
        } else {
            self.seekSlider?.isHidden = false
            self.timeElapsedLabel?.isHidden = false
            self.timeRemainingLabel?.isHidden = false
            
            self.hlsLabel?.isHidden = true
        }
    }
    
    private func updateTimeLabelsWith(elapsedTime: Float, duration: Float) {
        
        if !self.videoIsHLS {
            if elapsedTime.isFinite {
                self.timeElapsedLabel?.text = hmsToString(hms: secondsToHoursMinutesSeconds(seconds: Int(roundf(elapsedTime)))) // Basically convert seconds to the time string
            }
            
            let timeRemaining = duration - elapsedTime
            
            if timeRemaining.isFinite {
                self.timeRemainingLabel?.text = "-\(hmsToString(hms: secondsToHoursMinutesSeconds(seconds: Int(roundf(Float(timeRemaining))))))"
            }
        }
    }
    
    private func updateSeekSliderWith(elapsedTime: Float, duration: Float) {
        
        if !self.videoIsHLS {
            
            if !self.isSeekInProgress {
                let progress = elapsedTime / duration
                self.seekSlider?.setValue(progress, animated: true)
            } else {
                let chaseTimeInSeconds = CMTimeGetSeconds(self.chaseTime)
                let progress = Float(chaseTimeInSeconds) / duration
                self.seekSlider?.setValue(progress, animated: true)
            }
        }
    }
    
    @objc private func toggleControlsHidden(sender: UITapGestureRecognizer) {
        
        let point = sender.location(in: self.view)
        let tappedView = self.view.hitTest(point, with: nil)
        if tappedView == self.view || tappedView?.restorationIdentifier == "overlayView" {
            
            if self.topBarContainer!.isHidden || self.bottomBarContainer!.isHidden {
                // Show
                self.showControls()
            } else {
                // Hide
                self.hideControls()
            }
        }
    }
    
    func showBufferingIndicator() {
        self.bufferingIndicator?.alpha = 1
    }
    
    func hideBufferingIndicator() {
        self.bufferingIndicator?.alpha = 0
    }
    
    func hideControls() {
        
        UIView.animate(withDuration: self.controlsFadeTime, delay: 0.0, options: self.controlsFadeAnimationCurve, animations: {
            self.topBarContainer?.alpha = 0
            self.bottomBarContainer?.alpha = 0
            self.statusBarBacking?.alpha = 0
            self.playPauseButton?.alpha = 0
        }) { (_) in
            self.topBarContainer?.isHidden = true
            self.bottomBarContainer?.isHidden = true
            self.statusBarBacking?.isHidden = true
            self.playPauseButton?.isHidden = true
        }
        
        self.isShowingControls = false
    }
    
    func showControls() {
        
        self.topBarContainer?.isHidden = false
        self.bottomBarContainer?.isHidden = false
        self.statusBarBacking?.isHidden = false
        
        // Only if not buffering show play button
        if self.bufferingIndicator!.isHidden {
            self.playPauseButton?.isHidden = false
        }
        
        UIView.animate(withDuration: self.controlsFadeTime, delay: 0.0, options: self.controlsFadeAnimationCurve, animations: {
            self.topBarContainer?.alpha = 1
            self.bottomBarContainer?.alpha = 1
            self.statusBarBacking?.alpha = 1
            
            if self.bufferingIndicator!.isHidden {
                self.playPauseButton?.alpha = 1
            }
        }, completion: nil)
        
        self.isShowingControls = true
    }
    
    private func updateBufferingIndicatorIfNeeded() {
        
        if self.player != nil {
            
            let likelyToKeepUp = self.player!.currentItem!.isPlaybackLikelyToKeepUp
            let bufferFull = self.player!.currentItem!.isPlaybackBufferFull
            let bufferEmpty = self.player!.currentItem!.isPlaybackBufferEmpty
            
            if (likelyToKeepUp || bufferFull) && !self.bufferingIndicator!.isHidden && self.playerExternalState != .chromecast {
                self.removeBufferingIndicator()
            }
            
            if bufferEmpty && self.bufferingIndicator!.isHidden && self.playerExternalState != .chromecast {
                self.addBufferingIndiciator()
            }
        }
    }
    
    private func addBufferingIndiciator() {
        
        DispatchQueue.main.async {
            self.playPauseButton?.isHidden = true
            
            self.bufferingIndicator?.startAnimating()
            self.bufferingIndicator?.isHidden = false
        }
    }
    
    private func removeBufferingIndicator() {
        
        DispatchQueue.main.async {
            self.bufferingIndicator?.stopAnimating()
            
            if self.isShowingControls {
                self.playPauseButton?.isHidden = false
                self.playPauseButton?.alpha = 1
            }
        }
    }
    
    // Fullscreen stuff.
    
    private func enterFullScreenFromEmbed() {
        
        self.proxyView = UIView(frame: self.view.frame)
        self.proxyView?.isHidden = true
        self.proxyView?.autoresizingMask = self.view.autoresizingMask
        self.view.superview?.addSubview(self.proxyView!)
        
        // Now set the frame to the screen frame
        let frame = self.view.window?.convert(self.view.frame, from: self.proxyView?.superview)
        self.view.window?.addSubview(self.view)
        self.view.frame = frame!
        
        self.isFullscreen = true
        
        UIView.animate(withDuration: self.fullscreenTransitionTime, delay: 0.0, options: self.fullscreenTransitionAnimationCurve, animations: {
            self.view.frame = self.view.window!.bounds
            self.view.layoutIfNeeded()
            self.setNeedsStatusBarAppearanceUpdate()
        }, completion: nil)
    }
    
    private func exitFullScreenToEmbed() {
        
        var frame = self.view.window?.convert(self.proxyView!.frame, from: self.proxyView?.superview)
        
        if !(UIApplication.shared.statusBarOrientation == .landscapeRight || UIApplication.shared.statusBarOrientation == .landscapeLeft) {
            frame?.origin.y += self.statusBarHeight
        }
        
        self.isFullscreen = false
        
        UIView.animate(withDuration: self.fullscreenTransitionTime, delay: 0.0, options: self.fullscreenTransitionAnimationCurve, animations: { 
            self.view.frame = frame!
            self.view.layoutIfNeeded()
            self.setNeedsStatusBarAppearanceUpdate()
        }) { (_) in
            // Now convert back to superview
            self.view.frame = self.proxyView!.frame
            self.proxyView?.superview?.addSubview(self.view)
            
            self.proxyView?.removeFromSuperview()
            self.proxyView = nil
        }
    }
    
    private func dismissCompletely() {
        self.dismiss(animated: true) {
            self.delegate.playerViewControllerDidDismissCompletely(self)
        }
    }
    
    private func updateFullscreenImage() {
        
        if self.isFullscreen {
            
            let baseNormalScreenImage = UIImage(named: normalScreenImageName)
            let normalscreenImage = baseNormalScreenImage?.maskWith(color: normalScreenColor)
            let highlightedNormalscreenImage = baseNormalScreenImage?.maskWith(color: normalScreenHighlightedColor)
            
            self.fullscreenButton?.setImage(normalscreenImage, for: .normal)
            self.fullscreenButton?.setImage(highlightedNormalscreenImage, for: .selected)
            self.fullscreenButton?.setImage(highlightedNormalscreenImage, for: .highlighted)
            
        } else {
            
            let baseFullScreenImage = UIImage(named: fullScreenImageName)
            let fullscreenImage = baseFullScreenImage?.maskWith(color: fullScreenColor)
            let highlightedFullscreenImage = baseFullScreenImage?.maskWith(color: fullScreenHighlightedColor)
            
            self.fullscreenButton?.setImage(fullscreenImage, for: .normal)
            self.fullscreenButton?.setImage(highlightedFullscreenImage, for: .selected)
            self.fullscreenButton?.setImage(highlightedFullscreenImage, for: .highlighted)
        }
    }
    
    @objc private func wirelessRouteActiveChanged() {
        self.airplayEnabled = self.volumeView.isWirelessRouteActive
        
        DispatchQueue.main.async {
            if self.airplayEnabled {
                let airplayHighlightedImage = UIImage(named: self.airplayOnImageName)?.maskWith(color: self.airplayHighlightedColor)
                self.volumeView.setRouteButtonImage(airplayHighlightedImage, for: .highlighted)
            } else {
                let airplayHighlightedImage = UIImage(named: self.airplayOffImageName)?.maskWith(color: self.airplayHighlightedColor)
                self.volumeView.setRouteButtonImage(airplayHighlightedImage, for: .highlighted)
            }
        }
    }
    
    // MARK: - Utility Functions
    
    func deallocPlayer() {
        self.pausePlayer()
        self.playerLayer.removeFromSuperlayer()
        self.player = nil
        
        NotificationCenter.default.removeObserver(self)
    }
    
    private func updateStateForIndependentExternalVars() {
        
        // Update the state for airplay and chromecast states
        
        if self.airplayEnabled && self.chromecastEnabled {
            
            self.playerExternalState = .both
            self.player?.isMuted = false
            return
            
        } else if self.airplayEnabled {
            
            self.playerExternalState = .airplay
            self.player?.isMuted = false
            return
            
        } else if self.chromecastEnabled {
            
            self.playerExternalState = .chromecast
            self.player?.isMuted = true
            return
            
        } else {
            
            self.playerExternalState = .none
            self.player?.isMuted = false
            return
            
        }
    }
    
    // HMS
    private func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    private func hmsToString(hms: (Int, Int, Int)) -> String {
        
        let (h, m, s) = hms
        
        var stringTime = ""
        
        if h > 0 {
            // Add the hour to the result string
            
            stringTime += String(h)
            stringTime += ":"
            stringTime += String(format: "%02d", m) // Add leading zeroes if hour is > 0
            
        } else {
            // Only keep the minute and second
            stringTime += String(m)
        }
        
        // Add seconds
        stringTime += ":"
        stringTime += String(format: "%02d", s) // Add leading zeroes for seconds
        
        return stringTime
    }
    
    @objc private func updateLocalStatusBarFrameHeight() {
        let height = UIApplication.shared.statusBarFrame.height
        if height > 0 {
            self.statusBarHeight = height
        }
    }
    
    // Seeking stuff: https://developer.apple.com/library/content/qa/qa1820/_index.html
    private func stopPlayingAndSeekSmoothlyToTime(newChaseTime: CMTime) {
        if self.playerExternalState != .chromecast {
            self.addBufferingIndiciator()
        }
        
        self.pausePlayer()
        
        if CMTimeCompare(newChaseTime, self.chaseTime) != 0 {
            self.chaseTime = newChaseTime
            
            if !self.isSeekInProgress {
                self.tryToSeekToChaseTime()
            }
        }
    }
    
    private func tryToSeekToChaseTime() {
        if self.playerCurrentItemStatus == .unknown {
            // wait for to be ready
            return
        } else if self.playerCurrentItemStatus == .readyToPlay {
            self.actuallySeekToTime()
        }
    }
    
    private func actuallySeekToTime() {
        if self.player != nil {
            
            self.isSeekInProgress = true
            let seekTimeInProgress = self.chaseTime
            self.player!.seek(to: seekTimeInProgress, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero) { (completed) in
                
                if CMTimeCompare(seekTimeInProgress, self.chaseTime) == 0 {
                    self.isSeekInProgress = false
                    if self.playerExternalState != .chromecast  {
                        self.removeBufferingIndicator()
                    }
                    if self.playerRateBeforeSeek > 0 {
                        self.playPlayer()
                    }
                } else {
                    self.tryToSeekToChaseTime()
                }
            }
            
            // Also seek in chromecast if needed
            if self.castSession != nil {
                self.castSession!.remoteMediaClient?.seek(toTimeInterval: CMTimeGetSeconds(self.player!.currentTime()) * 1000, resumeState: .unchanged)
            }
        }
    }
    
    // MARK: -
    
    // MARK: KVO
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        self.updateBufferingIndicatorIfNeeded()
        switch keyPath! {
        case kPlaybackLikelyToKeepUp:
            self.playPlayer()
        case kPlaybackBufferFull:
            self.playPlayer()
        case kPlaybackBufferEmpty: break
        case kPlayerStatus:
            if self.player != nil {
                self.playerCurrentItemStatus = self.player!.currentItem!.status
                
                if self.playerCurrentItemStatus == .readyToPlay && self.isSeekInProgress {
                    // kvo done waiting
                    self.tryToSeekToChaseTime()
                }
            }
        default:
            break
        }
    }
    
    deinit {
        // clear timer
        self.updateTimer?.invalidate()
        self.updateTimer = nil
        
        // remove observers
        self.player?.removeObserver(self, forKeyPath: kPlaybackLikelyToKeepUp)
        self.player?.removeObserver(self, forKeyPath: kPlaybackBufferFull)
        self.player?.removeObserver(self, forKeyPath: kPlaybackBufferEmpty)
        self.player?.removeObserver(self, forKeyPath: kPlayerStatus)
        
        self.deallocPlayer()
    }
    
    // MARK: -
}
