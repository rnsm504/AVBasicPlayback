//
//  Albums.swift
//  AVBasicPlayback
//
//  Created by Masanori Kuze on 2017/10/01.
//  Copyright © 2017年 Masanori Kuze. All rights reserved.
//

import UIKit
import MediaPlayer

struct Album {
    var url : URL
    var title : NSString
    var artWork : Any
}

class Albums {
    
    var ary = NSMutableArray()
    
    init() {
        let albumQuery = MPMediaQuery.songs()
        let albums = albumQuery.collections as [MPMediaItemCollection]!
        
        guard (albumQuery.collections as [MPMediaItemCollection]!) != nil else {
            return
        }
        
        for album in albums! {
            let rv = album.representativeItem?.mediaType.rawValue
            if(rv == 2049 || rv == 2048){
                if let movieId = album.representativeItem?.assetURL {
                    let title = album.representativeItem?.title != nil ? album.representativeItem?.title : ""
                    let artwork = album.representativeItem?.artwork
                    let album = Album(url: movieId, title: title! as NSString, artWork: artwork as Any)
                    ary.add(album)
                }
                
            }
        }
    }
    
}
