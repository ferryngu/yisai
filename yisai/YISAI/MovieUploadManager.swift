//
//  MovieUploadManager.swift
//  Crummy
//
//  Created by Yufate on 15/5/16.
//  Copyright (c) 2015年 Columbia University. All rights reserved.
//

import UIKit

/** 初始化上传队列 */
func initUploadQueue() {
    
    ysApplication.uploadQueue = [MovieUploadManager]()
    let uploadMovies = YSMovie.getUploadMovies()
    
    if uploadMovies == nil {
        return
    }
    
    for movie in uploadMovies! {
        if movie.progress == 1.0 {
            continue
        }
        
        let uploadManager = MovieUploadManager(key: movie.name, movieOrImage: 1, status: 0)
        ysApplication.uploadQueue.append(uploadManager!)
    }
}

/** 选择要上传的视频(不选择则默认上传第一个加入上传队列的视频) */
func uploadMovies(selectUpMovieName movieName: String?) {
    
    let dispatchHandler = { () -> Void in
        if ysApplication.uploadQueue.count < 1 {
            return
        }
        
        var movieUploadManager: MovieUploadManager?
        if movieName == nil {
            movieUploadManager = ysApplication.uploadQueue[0]
        } else {
            var findFlag = false
            for bgUpload in ysApplication.uploadQueue {
//                bgUpload.suspendFlag = true
                if movieName == bgUpload.key {
                    movieUploadManager = bgUpload
                    findFlag = true
                    bgUpload.suspendFlag = false
                    break
                }
            }
            // 找不到该视频，上传第一个加入队列的视频
            if !findFlag {
                movieUploadManager = ysApplication.uploadQueue[0]
                movieUploadManager?.suspendFlag = false
            }
        }
        
//        YSMovie.cleanAllUploadMoviesUploadStatus()
        movieUploadManager?.uploadWithProgress(nil, completionBlock: nil)
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), dispatchHandler)
//    ysApplication.backgroundID = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler(backgroundHandler)
}

/** 停止上传  */
func stopUploadMovie(movieName: String?) {
    
    // 传参为nil, 则全部停止上传
    if movieName == nil {
        for uploadManager in ysApplication.uploadQueue {
            uploadManager.suspendFlag = true
        }
        
        return
    }
    
//    for (index, uploadManager) in enumerate(ysApplication.uploadQueue) {
//        if uploadManager.key == movieName {
//            uploadManager.suspendFlag = true
//            break
//        }
//    }
    
    
    for index in 0..<ysApplication.uploadQueue.count {
        let uploadManager = ysApplication.uploadQueue[index]
        if uploadManager.key == movieName {
            uploadManager.suspendFlag = true
            break
        }
    }
    
}

/** 一个视频上传完毕操作 */
func finishUploadMovie(movieName: String) {
    
    var delIndex = 0
//    for (index, uploadManager) in enumerate(ysApplication.uploadQueue) {
//        if uploadManager.key == movieName {
//            delIndex = index
//            break
//        }
//    }
//    
    for index in 0..<ysApplication.uploadQueue.count {
        if ysApplication.uploadQueue[index].key == movieName {
            delIndex = index
            break
        }
    
    }
    
    
    ysApplication.uploadQueue.removeAtIndex(delIndex)
    
//    uploadMovies(selectUpMovieName: nil)
}

/** 添加一个上传视频 */
func addUploadMovie(movieName: String) {
    
    if let movieManager = MovieUploadManager(key: movieName, movieOrImage: 1, status: 0) {
        
        
        ysApplication.uploadQueue.append(movieManager)
    }
}

class MovieUploadManager: NSObject {
   
    var key: String!
    var suspendFlag: Bool
    
    var movieOrImage: Int // 1：Movie，0：Image
    var status: Int = 3 // 0为作品，1为家庭动态，2为头像，3为其他
    var progress: Float = 0.0 // 上传进度
    
    var token: String!
    
    var uploadManager: QNUploadManager?
    
    convenience override init() {
        self.init(key: nil, movieOrImage: 1, status: 3)!
    }
    
    init?(key: String!, movieOrImage: Int, status: Int) {
        suspendFlag = false
        self.key = key
        self.movieOrImage = movieOrImage
        self.status = status
        super.init()
//        var error: NSError?
        if !NSFileManager.defaultManager().fileExistsAtPath(NSHomeDirectory() + "/Documents/Recorder") {
//            NSFileManager.defaultManager().createDirectoryAtPath(NSHomeDirectory() + "/Documents/Recorder", withIntermediateDirectories: true, attributes: nil, error: nil)
            
            do {
                try NSFileManager.defaultManager().createDirectoryAtPath(NSHomeDirectory() + "/Documents/Recorder", withIntermediateDirectories: true, attributes: nil)
            }catch let error as NSError {
                CrashReporter.sharedInstance().reportError(error, reason: error.localizedFailureReason, extraInfo: error.userInfo)
                return nil
            }

            
            
            
            
        }
//        let recorder = QNFileRecorder(folder: NSHomeDirectory() + "/Documents/Recorder/\(key)", error: &error)
        do {
            let recorder = try QNFileRecorder(folder: NSHomeDirectory() + "/Documents/Recorder/\(key)")
            uploadManager = QNUploadManager(recorder: recorder)
            return
        }catch let error as NSError {
            CrashReporter.sharedInstance().reportError(error, reason: error.localizedFailureReason, extraInfo: error.userInfo)
            return nil
        }
        
        
//       
       
    }
    
    private func localSuspendPath() -> String {
        return NSHomeDirectory() + "/Documents/Recorder/\(key)"
    }
    
    private func moviePath() -> String {
        return NSHomeDirectory() + "/Documents/Movie/\(key)"
    }
    
    private func imagePath() -> String {
        return NSHomeDirectory() + "/Documents/Image/\(key)"
    }
    
    /** 获取上传凭证 */
    func getUploadToken(block: (() -> Void)!) {
        YSUpload.getTokenWithKey(movieOrImage, status: status, key: key, respBlock: { [weak self] (token: String!, errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
            
            if errorMsg != nil {
                return
            }
            
            self!.token = token
            
            if block != nil {
                block()
            }
        })
    }
    
    
    
    func uploadWithProgress(processBlock: QNUpProgressHandler!, completionBlock: QNUpCompletionHandler!) {
        
        let upProgressHandler: QNUpProgressHandler = { [weak self]
            (key: String!, percent: Float) in
            
            if self == nil {
                return
            }
            
            let progressDic = [ "key" : key, "percent" : "\(percent)"]
            
         //   print(progressDic)
            
            
            self!.progress = percent
            
            YSUploadProgress.setUploadProgress(key, newProgress: "\(Int(percent * 100.0))")
            
            NSNotificationCenter.defaultCenter().postNotificationName(YSMovieUploadProgressNotification, object: nil, userInfo: progressDic)
            
            if processBlock != nil {
                processBlock(key, percent)
            }
        }
        
        let opt = QNUploadOption(mime: (movieOrImage == 1 ? "video/mp4" : "image/jpeg"), progressHandler: upProgressHandler, params: nil, checkCrc: true, cancellationSignal: { [weak self]
            () -> Bool in
            
            if self == nil {
                return true
            }
            
            return self!.suspendFlag
        })
        
        print("upload:" + (movieOrImage == 1 ? moviePath() : imagePath()))
        
        getUploadToken { [weak self] () -> Void in
            
            if self == nil {
                return
            }
            //图片上传
            if self!.movieOrImage == 0 {
                
                print("upload ---- \(self!.key)")
                
                if self!.uploadManager == nil{
                    return
                }
                
                self!.uploadManager!.putData(NSData(contentsOfFile: self!.imagePath()), key: self!.key, token: self!.token, complete: { (info: QNResponseInfo!, key: String!, resp: [NSObject : AnyObject]!) -> Void in
                    
                    print("info:")
                    print(info)
                    print("resp:")
                    print(resp)
                    
                    if info.ok {
                        if completionBlock != nil {
                            completionBlock(info, key, resp)
                        }
                    }
                    
                    if info.canceled {
                        if completionBlock != nil {
                            completionBlock(info, key, resp)
                        }
                    }
                    
                    if info.broken {
                        if completionBlock != nil {
                            completionBlock(info, key, resp)
                        }
                    }
                    
                    }, option: opt)
                
            } else {
                //视频上传
                if self!.status != 1 {
                    let movie = YSMovie.getMovie(movieName: self!.key)
                    if movie != nil {
                        movie?.uploadStatus = true
                        YSMovie.setMovie(movie!)
                    }
                    
                    print("self!.key = \(self!.key)" )
                    let uploadProgress = YSUploadProgress()
                    uploadProgress.progress = "0.0"
                    uploadProgress.movieName = self!.key
                
                    YSUploadProgress.addUploadProgress(uploadProgress)
                }
                if self!.uploadManager == nil {
                    return
                }
                
                self!.uploadManager!.putFile(self!.moviePath(), key: self!.key, token: self!.token, complete: { (info: QNResponseInfo!, key: String!, resp: [NSObject : AnyObject]!) -> Void in
                    
                    if self == nil {
                        return
                    }
                    
                    let dic = [ "key" : key ]
                    
                    if self!.status == 1 && completionBlock != nil {
                        completionBlock(info, key, resp)
                    }
                    
                    if info.ok {
                        
                        let movie = YSMovie.getMovie(movieName: key)
                        if movie != nil {
                            movie?.progress = 1.0
                            YSMovie.setMovie(movie!)
                            finishUploadMovie(key)
                        }
                        
                        // 上传成功
                        MobClick.event("upload_result", attributes: ["result": "success"])
                        
                        YSUploadProgress.setUploadProgress(key, newProgress: "100")
                        
                        NSNotificationCenter.defaultCenter().postNotificationName(YSMovieUploadFinishNotification, object: nil, userInfo: dic)
                    }
                    
                    if info.canceled {
                        let movie = YSMovie.getMovie(movieName: key)
                        if movie != nil {
                            movie?.uploadStatus = false
                            movie?.progress = self!.progress
                            YSMovie.setMovie(movie!)
                        }
                        NSNotificationCenter.defaultCenter().postNotificationName(YSMovieUploadCancelNotification, object: nil, userInfo: dic)
                    }
                    
                    if (info.error != nil) {
                        
                        // 上传失败
                        MobClick.event("upload_result", attributes: ["result": "failure"])
                    }
                    
                }, option: opt)
            }
        }
    }
}
