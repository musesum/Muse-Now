//
//  BubbleVideo.swift
//  MuseNow
//
//  Created by warren on 12/16/17.
//  Copyright © 2017 Muse. All rights reserved.

import Foundation
import UIKit
import AVFoundation

class BubbleVideo: BubbleBase {

    var player: AVPlayer?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    convenience init(_ bubble:Bubble) {
        self.init(frame:CGRect.zero)
        makeBubble(bubble)
    }

    deinit {
         NotificationCenter.default.removeObserver(self)
        Log(bubble.logString("💬 Video::deinit !!! "))
    }
    
    override func makeBubble(_ bubble:Bubble) {

        super.makeBubble(bubble)

        if  let fileName = bubble.items.first?.str,
            let videoURL = Bundle.main.url(forResource: fileName, withExtension: "") as NSURL? {

            player = AVPlayer(url: videoURL as URL)
            player?.actionAtItemEnd = .none
            player?.isMuted = true // Hear.shared.hearSet.isEmpty

            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.videoGravity = .resizeAspect
            playerLayer.zPosition = -1
            playerLayer.frame = contentFrame
            playerLayer.frame.origin = .zero

            let contentView = UIView(frame:contentFrame)
            contentView.layer.addSublayer(playerLayer)
            contentView.layer.cornerRadius = radius
            contentView.layer.masksToBounds = true
            contentViews.append(contentView)
        }
    }

    /**
     animate bubble onto screen and execute player
     */
    override func goBubble(_ gotoNext_: @escaping (()->())) {

        /// Continue with video after popping out bubble
        func playVideo() {

            // nowait, continue with  next bubble
            if bubble.options.contains(.nowait) && contenti == 0 {
                Log(bubble.logString("💬 Video::playVideo⟶gotoNext"))
                gotoNext?()
            }
            // set time limit
            if contenti < bubble.items.count {
                setTimeOut()
            }
            // start playing
            Log(bubble.logString("💬 Video::player?.play()"))
            player?.play()

            // finished video notification
            if contenti == 0 {
                NotificationCenter.default.addObserver(self, selector:#selector(self.videoFinishedPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
            }
        }

        // begin ------------------------

        gotoNext = gotoNext_
        Log(bubble.logString("💬 Video::goBubble"))
        popOut() {
            playVideo()
        }
    }
    /**
     timer for duration has expired
     */
    @objc override func timedOut() {

        if cancelling { return }
        NotificationCenter.default.removeObserver(self)
        Log(bubble.logString("💬 Video::timedOut"))
        killTime()
        player?.pause()
        tuckIn(timeout:true)
    }

    /**
     Process notification that video has finished
     */
    @objc func videoFinishedPlaying() {
       
        if cancelling { return }
         NotificationCenter.default.removeObserver(self)

        // with duration > 0,  timer completes.
        if contenti < bubble.items.count {
            let item = bubble.items[contenti]
            if item.duration > 0, timer.isValid {
                Log(bubble.logString("💬 Video::videoFinished CONTINUE"))
                return
            }
        }
        Log(bubble.logString("💬 Video::videoFinished DONE"))
        killTime()
        tuckIn(timeout:false)
    }
    func killTime() {
        cancelling = true
        NotificationCenter.default.removeObserver(self)
        timer.invalidate()
    }
    override func cancelBubble() {
        killTime()

        player?.pause()
        player = nil
        animateIn(duration: 0.5, delay: 0, finished:{})
    }

}
