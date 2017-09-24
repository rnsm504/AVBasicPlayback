//
//  ViewController.swift
//  AVBasicPlayback
//
//  Created by Masanori Kuze on 2017/09/24.
//  Copyright © 2017年 Masanori Kuze. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import MediaPlayer

class ViewController: UIViewController {
    
    var movieId : URL!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let albumQuery = MPMediaQuery.songs()
        let albums = albumQuery.collections as [MPMediaItemCollection]!
        
        guard (albumQuery.collections as [MPMediaItemCollection]!) != nil else {
            return
        }
        
        for album in albums! {
            let rv = album.representativeItem?.mediaType.rawValue
            if(rv == 2049 || rv == 2048){
                movieId = album.representativeItem?.assetURL
            }
//            print(album.representativeItem?.title ?? "")
//            print(album.representativeItem?.mediaType ?? "")
        }
        
        UIApplication.shared.beginReceivingRemoteControlEvents()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func playVideo(_ sender: Any) {
    
//        guard let url = URL(string: "https://devimages.apple.com.edgekey.net/samplecode/avfoundationMedia/AVFoundationQueuePlayer_HLS2/master.m3u8") else {
//            return
//        }
        
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("fatalError")
            fatalError()
        }
        
        // Create an AVPlayer, passing it the HTTP Live Streaming URL.
        let player = AVPlayer(url: movieId)
        let playerItem = player.currentItem

        let tracks = playerItem?.tracks
        for playerItemTrack in tracks! {
            if playerItemTrack.assetTrack.hasMediaCharacteristic(AVMediaCharacteristic.visual) {
                playerItemTrack.isEnabled = false
            }
        }
        
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let playerView = PlayerView()
        
        
        self.view = playerView
        (self.view.layer as! AVPlayerLayer).player = player
        
        appDelegate.player = player
        appDelegate.playerView = playerView

        player.play()
        
        // Create a new AVPlayerViewController and pass it a reference to the player.
//        let controller = AVPlayerViewController()
//        controller.player = player
//
//        // Modally present the player and call the player's play() method when complete.
//        present(controller, animated: true) {
//            player.play()
//        }
    }
}

