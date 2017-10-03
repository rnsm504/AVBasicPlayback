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


extension UIColor {
    struct orgClr {
        private init() {}
        static let loopOf = #colorLiteral(red: 0.5738074183, green: 0.5655357838, blue: 0, alpha: 1)
    }
}

enum playerStateType {
    case play
    case pause
    case next
    case loop
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
    var playerItem : AVPlayerItem!
    var timeObserverToken: AnyObject?
    var loopFlg : Bool = false
    
    @IBOutlet weak var playerView: PlayerView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var videoSeekBar: UISlider!
    @IBOutlet weak var maxTimeLbl: UILabel!
    @IBOutlet weak var nowTimeLbl: UILabel!
    @IBOutlet weak var loopButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // 初期化
        mvm = MusicVideosManager()
        playerState = PlayerState()
        
        maxTimeLbl.text = ""
        nowTimeLbl.text = ""
        
        loopFlg = false
        
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
    
    
    /// 初期設定
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
        
        // 最初の動画を準備
        let url = (mvm.musicVideos[0] as! Album).url as URL
        let player = AVPlayer(url: url)

        let title = (mvm.musicVideos[0] as! Album).title as String
        playerView.player = player
        titleLbl.text = title
        
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.player = player
        appDelegate.playerView = playerView
        
        sliderSet()
    }
    

    @IBAction func playVideo(_ sender: Any) {
        
        play(sender as AnyObject)
        
    }
    
    
    @IBAction  func onClickNext(_ sender : AnyObject) {

        nextTrack(sender as AnyObject)
    }
    
 
    @IBAction func onClickBack(_ sender : AnyObject) {
        
       backTrack(sender as AnyObject)
    }

    
    @IBAction func onClickLoop(_ sender: Any) {
        
        let button = sender as! UIButton
        
        loopFlg = !loopFlg
        
        if(loopFlg) {
            button.titleLabel?.textColor = UIColor.yellow
            button.setTitleColor(UIColor.yellow, for: UIControlState.normal)
        } else {
            button.titleLabel?.textColor = UIColor.orgClr.loopOf
            button.setTitleColor(UIColor.orgClr.loopOf, for: UIControlState.normal)
        }
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
    
    
    /// ロジック部分
    ///
    /// - Parameter action: playerStateType
    private func viewSet(action : playerStateType) {

        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate

        switch action {
        case .next:
            //次（前）の動画再生
            appDelegate.player.pause()
            
            playerView.player = mvm.player
            let title = (mvm.musicVideos[mvm.index] as! Album).title as String
            titleLbl.text = title
            appDelegate.player = playerView.player
            
            sliderSet()
            
            playerView.player?.play()
            self.playerState.state = .play
            
            playButton.setTitle("pause", for: .normal)
            break;
        case .pause:
            // 動画停止
            appDelegate.player?.pause()
            self.playerState.state = .pause
            playButton.setTitle("play", for: .normal)
            break;
        case .play:
            // 再生
            appDelegate.player?.play()
            self.playerState.state = .play
            playButton.setTitle("pause", for: .normal)
            break;
        case .loop:
            // 同じ動画のリピート
            appDelegate.player.pause()
            
            playerView.player = mvm.player
            let title = (mvm.musicVideos[mvm.index] as! Album).title as String
            titleLbl.text = title
            appDelegate.player = playerView.player
            
            sliderSet()
            
            playerView.player?.play()
            self.playerState.state = .play
            
            playButton.setTitle("pause", for: .normal)
            break;
        }
    }

    /// 動画の再生時間に合わせてsliderを初期化
    func sliderSet() {
        //画面初期化
        self.videoSeekBar.value = self.videoSeekBar.minimumValue
        self.view.setNeedsDisplay()
        
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let player = appDelegate.player
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.onVideoEnd(_:)), name:NSNotification.Name.AVPlayerItemDidPlayToEndTime , object: player?.currentItem)
        
        // 時間
        let duration = player?.currentItem?.asset.duration
        let maxTime = CMTimeGetSeconds(duration!)
        
        videoSeekBar.minimumValue = 0.0
        videoSeekBar.maximumValue = Float(maxTime)
        let interval = Double(videoSeekBar.maximumValue)/Double(videoSeekBar.bounds.maxX)
        let time : CMTime = CMTimeMakeWithSeconds(interval, Int32(NSEC_PER_SEC))
       
        // 時分に直す
        let date = Date(timeIntervalSince1970: maxTime)
        let format = DateFormatter()
        format.timeZone =  NSTimeZone(name: "GMT")! as TimeZone
        format.dateFormat = "HH:mm:ss"
        maxTimeLbl.text = format.string(from: date)
        
        // timeごとに呼び出す
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: time, queue: nil) { (time) in
            let time = CMTimeGetSeconds((player?.currentTime())!)
            let value = Float(self.videoSeekBar.maximumValue) * Float(time)/Float(maxTime)
            self.videoSeekBar.value = value
            let date = Date(timeIntervalSince1970: time)
            //再生中時間
            self.nowTimeLbl.text = format.string(from: date)
            } as AnyObject
    }
    
    /// 動画の終わりに呼び出される
    ///
    /// - Parameter sender: AnyObject
    @objc func onVideoEnd(_ sender: AnyObject) {
        
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate

        if let _timeObserverToken = timeObserverToken {
            appDelegate.player?.removeTimeObserver(_timeObserverToken)
            self.timeObserverToken = nil
        }
        
        // 無限ループが立ってるなら同じ動画を再生
        if(loopFlg) {
            mvm.loop()
            viewSet(action: .loop)
            
        } else {
            // 次の動画
            mvm.next()
            viewSet(action: .next)
        }
    }
    
    /// スライドを動かした時に呼び出される
    ///
    /// - Parameter sender: UISliser
    @IBAction func slide(_ sender: UISlider) {
        
        self.videoSeekBar.value = sender.value
        let time = CMTimeMakeWithSeconds(Float64(sender.value), Int32(NSEC_PER_SEC))
        
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        // スライダーの位置で動画を再生
        appDelegate.player.seek(to: time, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        
    }
}

