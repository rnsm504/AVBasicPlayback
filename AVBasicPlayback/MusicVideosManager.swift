//
//  MusicVideos.swift
//  AVBasicPlayback
//
//  Created by Masanori Kuze on 2017/09/26.
//  Copyright © 2017年 Masanori Kuze. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer


class MusicVideosManager {
    
    public var musicVideos : NSMutableArray
    public var index : Int = 0
    public var player : AVPlayer!
  
    init() {
        musicVideos = Albums().ary
        
        if(musicVideos.count > 0) {
            avset(index: 0)
        }
        
        //コントロールセンターやロック画面の再生ボタンを表示
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("fatalError")
            fatalError()
        }
    }
    
    public func next() {
        if(musicVideos.count > 0) {
            index = musicVideos.count - 1 > index ? index + 1 : 0
            avset(index: index)
        }
    }
    
    public func back() {
        if(musicVideos.count > 0) {
            index = index - 1 < 0 ? musicVideos.count - 1 : index - 1
            avset(index: index)
        }
    }
    
    private func avset(index : Int) {
        let url = (musicVideos[index] as! Album).url
        player = AVPlayer(url: url)
        
        // ロック画面
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyTitle : (musicVideos[index] as! Album).title,
            MPMediaItemPropertyArtwork : (musicVideos[index] as! Album).artWork
        ]
        
        
    }
}
