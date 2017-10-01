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

enum playerStateType {
    case play
    case pause
    case next
}

class PlayerState {
    var state : playerStateType
    
    init() {
        state = playerStateType.pause
    }
}

class ViewController: UIViewController {
    
    var playerState : PlayerState!
    var mvm : MusicVideosManager!
    
    @IBOutlet weak var playerView: PlayerView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // 初期化
        mvm = MusicVideosManager()
        playerState = PlayerState()
        
        //行数制御なし
        titleLbl.numberOfLines = 0
        // 自動的に改行
        titleLbl.sizeToFit()
    
        if(mvm.musicVideos.count > 0) {
            initilize()
        } else {
            //ビデオがない場合は操作不能
            playButton.isEnabled = false
            nextButton.isEnabled = false
            backButton.isEnabled = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    func initilize() {
        // ロック画面でのボタン操作と処理
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.addTarget(self, action: #selector(ViewController.play(_:)))
        commandCenter.playCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget(self, action: #selector(ViewController.play(_:)))
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.nextTrackCommand.addTarget(self, action: #selector(ViewController.nextTrack(_:)))
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.addTarget(self, action: #selector(ViewController.backTrack(_:)))
        commandCenter.previousTrackCommand.isEnabled = true
        
        let url = (mvm.musicVideos[0] as! Album).url as URL
        let player = AVPlayer(url: url)
        let title = (mvm.musicVideos[0] as! Album).title as String
        playerView.player = player
        titleLbl.text = title
        
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.player = player
        appDelegate.playerView = playerView
    }
    

    @IBAction func playVideo(_ sender: Any) {
        
        play(sender as AnyObject)
        
    }
    
    
    @IBAction  func onClickNext(_ sender : AnyObject) {

        self.nextTrack(sender as AnyObject)
    }
    
 
    @IBAction func onClickBack(_ sender : AnyObject) {
        
       self.backTrack(sender as AnyObject)
    }

    
    
    @objc func play(_ sender : AnyObject) {
        
        if(self.playerState.state == .play) {
            viewSet(action: .pause)
        } else if(self.playerState.state == .pause) {
            viewSet(action: .play)
        }
    }
    
    
    @objc func nextTrack(_ sender: AnyObject) {
        
        mvm.next()
        
        viewSet(action: .next)
    }
    
    @objc func backTrack(_ sender: AnyObject) {
        
        mvm.back()
        
        viewSet(action: .next)
    }
    
    private func viewSet(action : playerStateType) {

        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate

        switch action {
        case .next:
            appDelegate.player.pause()
            
            playerView.player = mvm.player
            let title = (mvm.musicVideos[mvm.index] as! Album).title as String
            titleLbl.text = title
            
            playerView.player?.play()
            self.playerState.state = .play
            
            appDelegate.player = playerView.player
            playButton.setTitle("pause", for: .normal)
            break;
        case .pause:
            appDelegate.player?.pause()
            self.playerState.state = .pause
            playButton.setTitle("play", for: .normal)
            break;
        case .play:
            appDelegate.player?.play()
            self.playerState.state = .play
            playButton.setTitle("pause", for: .normal)
            break;
        }
        
        
    }
    
}

