//
//  MovieManager.swift
//  Crummy
//
//  Created by Yufate on 15/5/14.
//  Copyright (c) 2015年 Columbia University. All rights reserved.
//

import UIKit
import AVFoundation

let movieFilesManager : MovieFilesManager = MovieFilesManager()

class MovieFilesManager: NSObject {
    
    class func getUserLocalAvatarPath() -> String? {
        
        if ysApplication == nil || ysApplication.loginUser == nil || ysApplication.loginUser.uid == nil {
            return nil
        }
        
        return  NSHomeDirectory() + "/Documents/Image/\(ysApplication.loginUser.tel)_avatar.png"
    }
    
    class func movieFilePathURL(movieName: String) -> NSURL {
        let moviePath = MovieFilesManager.movieFilesDirectory() + "/Movie/" + movieName
        return NSURL(fileURLWithPath: moviePath)
    }
    
    class func movieFilesDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let documentsDicrectory = paths[0]
        return documentsDicrectory
    }
    
    class func findAllMovieFiles() -> [String]? {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true) 
        let moviesDicrectory = paths[0] + "/Movie/"
        print(moviesDicrectory)
        let fileManager = NSFileManager.defaultManager()
        return fileManager.subpathsAtPath(moviesDicrectory)
    }
    //MARK:-
    /** 获取视频缩略图 */
    class func getImage(videoURL: NSURL) -> UIImage {
        //获取数据源
        let asset = AVURLAsset(URL: videoURL, options: nil)
        let gen = AVAssetImageGenerator(asset: asset)
        gen.appliesPreferredTrackTransform = true
        // 精确取第几帧的时间到某一时间点
//        gen.requestedTimeToleranceAfter = kCMTimeZero
//        gen.requestedTimeToleranceBefore = kCMTimeZero
        // first param = 第几帧
        //CMTimeMakeWithSeconds(Float64  seconds, int32_t  preferredTimeScale): 第1个参数代表获取第几秒的截图,第2个参数则代表每秒的帧数.
        let time = CMTimeMakeWithSeconds(0.0, 600)
//        var error: NSError?
        var actualTime: CMTime = kCMTimeZero
//        let image = gen.copyCGImageAtTime(time, actualTime: &actualTime, error: &error)
        
        do {
            let image = try gen.copyCGImageAtTime(time, actualTime: &actualTime)
            let thumb = UIImage(CGImage: image)
            return UIImage(data: UIImageJPEGRepresentation(thumb, 0.3)!)!
        }catch let error as NSError{
            CrashReporter.sharedInstance().reportError(error, reason: error.localizedFailureReason, extraInfo: error.userInfo)
            return UIImage(named: DEFAULT_IMAGE_NAME_SQUARE)!
        }
        
//        if error != nil {
//            return UIImage(named: DEFAULT_IMAGE_NAME_SQUARE)!
//        }
        
//        let thumb = UIImage(CGImage: image)!
        //返回压缩好的图片
        
    }
    
    /** 获取视频时长 */
    class func getVideoLength(videoURL: NSURL) -> Int {
        let opts = [ AVURLAssetPreferPreciseDurationAndTimingKey : false ]
        let urlAsset = AVURLAsset(URL: videoURL, options: opts)
        var second = 0
        second = Int(urlAsset.duration.value / Int64(urlAsset.duration.timescale))
        return second
    }
    
    /** 获取视频文件大小（单位KB） */
    class func getFileSize(videoPath: String!) -> CGFloat {
        if videoPath == nil {
            return 0.0
        }
        
        let fileMananger = NSFileManager.defaultManager()
        var fileSize: CGFloat = -1.0
        if fileMananger.fileExistsAtPath(videoPath) {
//            let fileDic = fileMananger.attributesOfItemAtPath(videoPath, error: nil) as! [String : AnyObject]
            do {
                let fileDic = try fileMananger.attributesOfItemAtPath(videoPath)
                let size = fileDic[NSFileSize]?.longLongValue
                fileSize = 1.0 * CGFloat(size! / 1024)
            }catch let error as NSError {
                CrashReporter.sharedInstance().reportError(error, reason: error.localizedFailureReason, extraInfo: error.userInfo)
                fileSize = 0
            }
            
            
            
//            var size = fileDic[NSFileSize]?.longLongValue
//            fileSize = 1.0 * CGFloat(size! / 1024)  
        }
        return fileSize
    }
}

class YSMovie: NSObject {
    
    var uid: String! // 作品归属用户
    var name: String // 作品文件名
    var progress: Float // 上传进度, 1.0为上传完毕
    var uploadStatus: Bool // 上传状态
    var title: String! // 作品名
    
    convenience override init() {
        self.init(uid: "", name: "", progress: 0.0, uploadStatus: false, title: nil)
    }
    
    init(uid: String, name: String, progress: Float, uploadStatus: Bool, title: String!) {
        self.name = name
        self.progress = progress
        self.uploadStatus = uploadStatus
        self.title = title
        self.uid = uid
    }
    
    class func movieWithAttributes(attributes: Dictionary<String, String>) -> YSMovie {
        return YSMovie().initWithAttributes(attributes)
    }
    
    private func initWithAttributes(attributes: Dictionary<String, String>) -> YSMovie {
        
        name = attributes["name"]!
        progress = (attributes["progress"]! as NSString).floatValue
        uploadStatus = (attributes["uploadstatus"]! as NSString).boolValue
        title = attributes["title"]!
        uid = attributes["uid"]
        
        return self
    }
    
    class func moviePropertyToDictionary(movie: YSMovie) -> Dictionary<String, String> {
        return ["uid": movie.uid, "name": movie.name, "progress": "\(movie.progress)", "uploadstatus": "\(movie.uploadStatus)", "title": "\(movie.title)"]
    }
    //取出缓存好的json 把新增加的视频添加进去
    class func addUploadMovie(movie: YSMovie) {
        let dic = fe_std_data_get_json("YSUpload", key: "uploadmovie")
        var settoDic: Dictionary<String, [Dictionary<String, String>]>? = nil
        let localDic: Dictionary<String, String> = YSMovie.moviePropertyToDictionary(movie)
        if dic == nil {
            settoDic = [ "lst_movie": [localDic]]
        } else {
            var lst_movie = dic["lst_movie"] as! [Dictionary<String, String>]
            lst_movie += [localDic]
            settoDic = [ "lst_movie" : lst_movie]
        }
        fe_std_data_set_json("YSUpload", key: "uploadmovie", jsonValue: settoDic,expire_sec: DEFAULT_EXPIRE_SEC)
    }
    
    // 获取所有上传视频
    class func getUploadMovies() -> [YSMovie]? {
        let dic = fe_std_data_get_json("YSUpload", key: "uploadmovie")
        if dic == nil {
            return nil
        }
        
        let resp_lst_movie = dic["lst_movie"] as? [Dictionary<String, String>]
        if resp_lst_movie == nil {
            return nil
        }
        
        var lst_movie = [YSMovie]()
        for attribute in resp_lst_movie! {
            let movie = YSMovie.movieWithAttributes(attribute)
            lst_movie.append(movie)
        }
        
        return lst_movie
    }
    
    // 获取所有有关当前用户的视频
    class func getUploadMoviesAboutUID() -> [YSMovie]? {
        let dic = fe_std_data_get_json("YSUpload", key: "uploadmovie")
        if dic == nil {
            return nil
        }
        
        let resp_lst_movie = dic["lst_movie"] as? [Dictionary<String, String>]
        if resp_lst_movie == nil {
            return nil
        }
        
        var lst_movie = [YSMovie]()
        for attribute in resp_lst_movie! {
            let movie = YSMovie.movieWithAttributes(attribute)
            if ysApplication == nil || ysApplication.loginUser == nil || ysApplication.loginUser.uid == nil || checkInputEmpty(movie.uid) {
                continue
            }
            if movie.uid != ysApplication.loginUser.uid {
                continue
            }
            lst_movie.append(movie)
        }
        
        return lst_movie
    }
    
    class func cleanAllUploadMovies() {
        fe_std_data_set_json("YSUpload", key: "uploadmovie", jsonValue: nil, expire_sec: DEFAULT_EXPIRE_SEC)
    }
    
    class func cleanAllNotUploadMovies() {
        
        let lst_movie = YSMovie.getUploadMoviesAboutUID()
        
        if lst_movie == nil || lst_movie!.count < 1 {
            return
        }
        
        for movie in lst_movie! {
            if checkInputEmpty(movie.name) {
                continue
            }
            if movie.progress < 1.0 {
                YSMovie.cleanOneUploadMovie(movie.name)
            }
            
        }

    }
    
    class func cleanAllUploadMoviesAboutUID() {
        let lst_movie = YSMovie.getUploadMoviesAboutUID()
        
        if lst_movie == nil || lst_movie!.count < 1 {
            return
        }
        
        for movie in lst_movie! {
            if checkInputEmpty(movie.name) {
                continue
            }
            if movie.progress < 1.0 {
                continue
            }
            YSMovie.cleanOneUploadMovie(movie.name)
        }
    }
    
    class func cleanOneUploadMovie(name: String) {
        var dic = fe_std_data_get_json("YSUpload", key: "uploadmovie") as? Dictionary<String, [Dictionary<String, String>]>
        var lst_movie = dic?["lst_movie"]
        
        if lst_movie == nil || lst_movie!.count < 1{
            return
        }
        
        var cleanIndex: Int?
        
        for index in 0..<lst_movie!.count{
            if lst_movie![index]["name"] == name{
                cleanIndex = index
            }
        }
//        for (index, movie) in enumerate(lst_movie!) {
//            if movie["name"] == name {
//                cleanIndex = index
//            }
//        }
        if cleanIndex != nil {
            lst_movie!.removeAtIndex(cleanIndex!)
        }
        dic!["lst_movie"] = lst_movie
        fe_std_data_set_json("YSUpload", key: "uploadmovie", jsonValue: dic, expire_sec: DEFAULT_EXPIRE_SEC)
    }
    
    class func cleanAllUploadMoviesUploadStatus() {
        var dic = fe_std_data_get_json("YSUpload", key: "uploadmovie") as? Dictionary<String, [Dictionary<String, String>]>
        var lst_movie = dic?["lst_movie"]
        
        if lst_movie == nil || lst_movie!.count < 1{
            return
        }
        
        var re_lst_movie = [Dictionary<String, String>]()
//        for (index, movie) in enumerate(lst_movie!) {
//            var aMovie = movie
//            aMovie["uploadstatus"] = "\(false)"
//            re_lst_movie.append(aMovie)
//        }
        for index in 0..<lst_movie!.count{
            var aMovie = lst_movie![index]
            aMovie["uploadstatus"] = "\(false)"
            re_lst_movie.append(aMovie)
        }
        
        
        
        dic!["lst_movie"] = re_lst_movie
        fe_std_data_set_json("YSUpload", key: "uploadmovie", jsonValue: dic, expire_sec: DEFAULT_EXPIRE_SEC)
    }
    
    class func setMovie(movie: YSMovie) {
        var dic = fe_std_data_get_json("YSUpload", key: "uploadmovie") as? Dictionary<String, [Dictionary<String, String>]>
        var lst_movie = dic?["lst_movie"]
        
        if lst_movie == nil{
            YSMovie.addUploadMovie(movie)
            return
        } else {
//            for (index, lmovie) in enumerate(lst_movie!) {
//                if lmovie["name"]! == movie.name {
//                    lst_movie![index] = YSMovie.moviePropertyToDictionary(movie)
//                    break
//                }
//            }
            for index in 0..<lst_movie!.count{
                if lst_movie![index]["name"] == movie.name {
                    lst_movie![index] = YSMovie.moviePropertyToDictionary(movie)
                    break
                }
            }
            
            
            
            
            dic!["lst_movie"] = lst_movie
            fe_std_data_set_json("YSUpload", key: "uploadmovie", jsonValue: dic, expire_sec: DEFAULT_EXPIRE_SEC)
        }
    }
    
    class func getMovie(movieName name: String) -> YSMovie? {
        var dic = fe_std_data_get_json("YSUpload", key: "uploadmovie") as? Dictionary<String, [Dictionary<String, String>]>
        if dic == nil {
            return nil
        }
        
        let lst_movie = dic!["lst_movie"]
        if lst_movie == nil {
            return nil
        }
        
        for movie in lst_movie! {
            if movie["name"] == name {
                return YSMovie.movieWithAttributes(movie)
            }
        }
        
        return nil
    }
}

class YSFindwork: NSObject {
    
    var uid: String! // 用户ID
    var crid: String! // 作品ID
    var title: String! // 作品名
    var movieName: String! // 视频名
    var categoryName: String! // 类别名
    var categoryId: String! // 类别ID
    var teacherName: String! // 指导老师名
    var teacherTel: String! // 指导老师联系电话
    var cpid: String! // 赛事ID
    
    override init() {
        uid = ysApplication.loginUser.uid == nil ? "" : ysApplication.loginUser.uid
        crid = ""
        movieName = ""
        title = ""
        categoryName = ""
        categoryId = ""
        teacherName = ""
        teacherTel = ""
        cpid = ""
    }
    
    class func findworkWithAttributes(attributes: Dictionary<String, String>) -> YSFindwork {
        return YSFindwork().initWithAttributes(attributes)
    }
    
    private func initWithAttributes(attributes: Dictionary<String, String>) -> YSFindwork {
        
        uid = attributes["uid"]
        crid = attributes["crid"]
        title = attributes["title"]
        movieName = attributes["movieName"]
        categoryName = attributes["categoryName"]
        categoryId = attributes["categoryId"]
        teacherName = attributes["teacherName"]
        teacherTel = attributes["teacherTel"]
        cpid = attributes["cpid"]
        
        return self
    }
    
    class func findworkPropertyToDictionary(findwork: YSFindwork) -> Dictionary<String, String> {
        return ["uid" : findwork.uid, "crid": findwork.crid, "title": findwork.title, "movieName": findwork.movieName, "categoryName": findwork.categoryName, "categoryId": findwork.categoryId, "teacherName": findwork.teacherName, "teacherTel": findwork.teacherTel, "cpid": findwork.cpid]
    }
    
    class func addFindwork(findwork: YSFindwork) {
        let dic = fe_std_data_get_json("YSFindwork", key: "findwork")
        var settoDic: Dictionary<String, [Dictionary<String, String>]>? = nil
        let localDic: Dictionary<String, String> = YSFindwork.findworkPropertyToDictionary(findwork)
        if dic == nil {
            settoDic = [ "lst_findwork" : [localDic]]
        } else {
            var lst_findwork = dic["lst_findwork"] as! [Dictionary<String, String>]
            lst_findwork += [localDic]
            settoDic = [ "lst_findwork" : lst_findwork]
        }
        fe_std_data_set_json("YSFindwork", key: "findwork", jsonValue: settoDic, expire_sec: DEFAULT_EXPIRE_SEC)
    }
    
    class func getAllFindworks() -> [YSFindwork]? {
        let dic = fe_std_data_get_json("YSFindwork", key: "findwork")
        if dic == nil {
            return nil
        }
        
        let resp_lst_findwork = dic["lst_findwork"] as! [Dictionary<String, String>]
        var lst_findwork = [YSFindwork]()
        for attribute in resp_lst_findwork {
            
            let uid = attribute["uid"]
            if uid == nil || uid == "" || ysApplication.loginUser.uid == nil {
                continue
            }
            
            if uid == ysApplication.loginUser.uid {
                let findwork = YSFindwork.findworkWithAttributes(attribute)
                lst_findwork.append(findwork)
            }
        }
        
        return lst_findwork
    }
    
    class func cleanAllFindworks() {
        fe_std_data_set_json("YSFindwork", key: "findwork", jsonValue: nil, expire_sec: DEFAULT_EXPIRE_SEC)
    }
    /*
    class func cleanOneFindwork(cpid: String) {
        var dic = fe_std_data_get_json("YSFindwork", "findwork") as? Dictionary<String, [Dictionary<String, String>]>
        var lst_findwork = dic?["lst_findwork"]
        
        if lst_findwork == nil || lst_findwork!.count < 1{
            return
        }
        
        var cleanIndex: Int?
        for (index, findwork) in enumerate(lst_findwork!) {
            if findwork["cpid"] == cpid {
                cleanIndex = index
            }
        }
        if cleanIndex != nil {
            lst_findwork!.removeAtIndex(cleanIndex!)
        }
        dic!["lst_findwork"] = lst_findwork
        fe_std_data_set_json("YSFindwork", "findwork", dic)
    }
*/
    
    class func setFindwork(findwork: YSFindwork) {
        var dic = fe_std_data_get_json("YSFindwork", key: "findwork") as? Dictionary<String, [Dictionary<String, String>]>
        var lst_findwork = dic?["lst_findwork"]
        
        if lst_findwork == nil{
            YSFindwork.addFindwork(findwork)
            return
        } else {
            var fIndex = 0
            
//            for (index, lfindwork) in enumerate(lst_findwork!) {
//                if lfindwork["cpid"]! == findwork.cpid && lfindwork["uid"]! == findwork.uid {
//                    lst_findwork![index] = YSFindwork.findworkPropertyToDictionary(findwork)
//                    break
//                }
//            
//            
//            
//                fIndex++
//                if fIndex == lst_findwork!.count {
//                    lst_findwork!.append(YSFindwork.findworkPropertyToDictionary(findwork))
//                }
//            }
            
            for index in 0..<lst_findwork!.count {
                if lst_findwork![index]["cpid"] == findwork.cpid && lst_findwork![index]["uid"]! == findwork.uid {
                    lst_findwork![index] = YSFindwork.findworkPropertyToDictionary(findwork)
                    break
                }
                
                fIndex++
                if fIndex == lst_findwork!.count {
                    lst_findwork!.append(YSFindwork.findworkPropertyToDictionary(findwork))
                }
            
            }
            
            dic!["lst_findwork"] = lst_findwork
            fe_std_data_set_json("YSFindwork", key: "findwork", jsonValue: dic, expire_sec: DEFAULT_EXPIRE_SEC)
        }
    }
    
    class func getFindwork(cpid: String) -> YSFindwork? {
        var dic = fe_std_data_get_json("YSFindwork", key: "findwork") as? Dictionary<String, [Dictionary<String, String>]>
        if dic == nil {
            return nil
        }
        
        let lst_findwork = dic!["lst_findwork"]
        if lst_findwork == nil {
            return nil
        }
        
        for findwork in lst_findwork! {
            
            let uid = findwork["uid"]
            let tCpid = findwork["cpid"]
            
            if uid == nil || tCpid == nil {
                continue
            }
            
            if tCpid == cpid && findwork["uid"] == ysApplication.loginUser.uid {
                return YSFindwork.findworkWithAttributes(findwork)
            }
        }
        
        return nil
    }
}

/** 作品指导老师 */
class YSFindworkTutor: NSObject {
    
    var teacherName: String! // 指导老师名
    var teacherTel: String! // 指导老师联系电话
    var isChange: Int64! // 切换老师
    
    override convenience init() {
        self.init(teacherName: nil, teacherTel: nil)
    }
    
    init(teacherName name: String!, teacherTel tel: String!) {
        teacherName = name
        teacherTel = tel
    }
    
    class func setTutor(tutor: YSFindworkTutor) {
        
        let teacherName = feGetAttrib("FindworkTutor", key: "teacherName")
        let teacherTel = feGetAttrib("FindworkTutor", key: "teacherTel")
        
        if teacherName != tutor.teacherName || teacherTel != tutor.teacherTel {
            fe_std_data_set("FindworkTutor", key: "teacherChange", value: String(1), expire_sec: DEFAULT_EXPIRE_SEC)
        } else {
            fe_std_data_set("FindworkTutor", key: "teacherChange", value: String(0), expire_sec: DEFAULT_EXPIRE_SEC)
        }
        
        feSetAttrib("FindworkTutor", key: "teacherName", value: tutor.teacherName)
        feSetAttrib("FindworkTutor", key: "teacherTel", value: tutor.teacherTel)
    }
    
    class func getTutor() -> YSFindworkTutor? {
        
        let name = feGetAttrib("FindworkTutor", key: "teacherName")
        let tel = feGetAttrib("FindworkTutor", key: "teacherTel")
        let isChange = feGetAttrib("FindworkTutor", key: "teacherChange")
        
        if name == nil || tel == nil {
            // 不存在指导老师
            return nil
        } else {
            let findWork = YSFindworkTutor(teacherName: name, teacherTel: tel)
            findWork.isChange = Int64(isChange)
            return findWork
        }
    }
}

/** 推送红点 */
class YSBudge: NSObject {
    
    var uid: String! // 用户ID
    // 1: True, 0: False
    // 用户：
    var isEnterCompetition: String! // 参赛状态/比赛开始/比赛排名发布更改
    var isChangeTeacher: String! // 更改老师
    // 老师：
    var isBindTutor: String! // 学生绑定
    // 评委：
    var isInstitutionInvitation: String! // 主办方邀请
    var isMarked: String! // 收到作品评分通知/比赛评分开始/比赛评分结束
    // 通用：
    var isConcerned: String! // 被其他用户关注
    var isReceivedMsg: String! // 新私信
    
    override init() {
        uid = (ysApplication.loginUser.uid == nil ? "" : ysApplication.loginUser.uid)
        isEnterCompetition = "0"
        isChangeTeacher = "0"
        isBindTutor = "0"
        isInstitutionInvitation = "0"
        isMarked = "0"
        isConcerned = "0"
        isReceivedMsg = "0"
    }
    
    class func budgeWithAttributes(attributes: Dictionary<String, String>) -> YSBudge {
        return YSBudge().initWithAttributes(attributes)
    }
    
    private func initWithAttributes(attributes: Dictionary<String, String>) -> YSBudge {
        
        uid = ysApplication.loginUser.uid == nil ? "" : ysApplication.loginUser.uid
        isEnterCompetition = attributes["isEnterCompetition"]
        isChangeTeacher = attributes["isChangeTeacher"]
        isBindTutor = attributes["isBindTutor"]
        isInstitutionInvitation = attributes["isInstitutionInvitation"]
        isMarked = attributes["isMarked"]
        isConcerned = attributes["isConcerned"]
        isReceivedMsg = attributes["isReceivedMsg"]
        
        return self
    }
    
    class func budgePropertyToDictionary(budge: YSBudge) -> Dictionary<String, String> {
        return ["isEnterCompetition": budge.isEnterCompetition, "isChangeTeacher": budge.isChangeTeacher, "isBindTutor": budge.isBindTutor, "isInstitutionInvitation": budge.isInstitutionInvitation, "isMarked": budge.isMarked, "isConcerned": budge.isConcerned, "isReceivedMsg": budge.isReceivedMsg,]
    }
    
    private class func addBudge(budge: YSBudge) {
        
        if ysApplication.loginUser.uid == nil {
            return
        }
        
        let uid = ysApplication.loginUser.uid
        
        let dic = fe_std_data_get_json("YSBudge", key: uid) as? Dictionary<String, String>
        var settoDic: Dictionary<String, String>? = nil
        let localDic: Dictionary<String, String> = YSBudge.budgePropertyToDictionary(budge)
        if dic == nil {
            settoDic = localDic
        } else {
            settoDic = dic
        }
        fe_std_data_set_json("YSBudge", key: uid, jsonValue: settoDic, expire_sec: DEFAULT_EXPIRE_SEC)
    }
    
    /** 参赛 / 比赛开始 / 比赛排名发布 */
    class func setEnterCompetition(flag: String) {
        
        if ysApplication.loginUser.uid == nil || (flag != "0" && flag != "1") {
            return
        }
        
        let uid = ysApplication.loginUser.uid
        
        var budge = YSBudge.getBudge()
        if budge == nil {
            
            budge = YSBudge()
            budge!.isEnterCompetition = flag
            
            YSBudge.addBudge(budge!)
            
        } else {
            
            budge!.isEnterCompetition = flag
            
            let dic = YSBudge.budgePropertyToDictionary(budge!)
            
            fe_std_data_set_json("YSBudge", key: uid, jsonValue: dic, expire_sec: DEFAULT_EXPIRE_SEC)
        }
    }
    
    /** 学生绑定 */
    class func setBindTutor(flag: String) {
        
        if ysApplication.loginUser.uid == nil || (flag != "0" && flag != "1") {
            return
        }
        
        let uid = ysApplication.loginUser.uid
        var budge = YSBudge.getBudge()
        if budge == nil {
            
            budge = YSBudge()
            budge!.isBindTutor = flag
            
            YSBudge.addBudge(budge!)
            
        } else {
            
            budge!.isBindTutor = flag
            
            let dic = YSBudge.budgePropertyToDictionary(budge!)
            
            fe_std_data_set_json("YSBudge", key: uid, jsonValue: dic, expire_sec: DEFAULT_EXPIRE_SEC)
        }
    }
    
    /** 收到作品评分通知 */
    class func setInstitutionInvitation(flag: String) {
        
        if ysApplication.loginUser.uid == nil || (flag != "0" && flag != "1") {
            return
        }
        
        let uid = ysApplication.loginUser.uid
        var budge = YSBudge.getBudge()
        if budge == nil {
            
            budge = YSBudge()
            budge!.isInstitutionInvitation = flag
            
            YSBudge.addBudge(budge!)
            
        } else {
            
            budge!.isInstitutionInvitation = flag
            
            let dic = YSBudge.budgePropertyToDictionary(budge!)
            
            fe_std_data_set_json("YSBudge", key: uid, jsonValue: dic, expire_sec: DEFAULT_EXPIRE_SEC)
        }
    }
    
    /** 收到作品评分通知 / 比赛评分开始 / 比赛评分结束 */
    class func setMarked(flag: String) {
        
        if ysApplication.loginUser.uid == nil || (flag != "0" && flag != "1") {
            return
        }
        
        let uid = ysApplication.loginUser.uid
        var budge = YSBudge.getBudge()
        if budge == nil {
            
            budge = YSBudge()
            budge!.isMarked = flag
            
            YSBudge.addBudge(budge!)
            
        } else {
            
            budge!.isMarked = flag
            
            let dic = YSBudge.budgePropertyToDictionary(budge!)
            
            fe_std_data_set_json("YSBudge", key: uid, jsonValue: dic, expire_sec: DEFAULT_EXPIRE_SEC)
        }
    }
    
    /** 被其他用户关注 */
    class func setConcerned(flag: String) {
        
        if ysApplication.loginUser.uid == nil || (flag != "0" && flag != "1") {
            return
        }
        
        let uid = ysApplication.loginUser.uid
        var budge = YSBudge.getBudge()
        if budge == nil {
            
            budge = YSBudge()
            budge!.isConcerned = flag
            
            YSBudge.addBudge(budge!)
            
        } else {
            
            budge!.isConcerned = flag
            
            let dic = YSBudge.budgePropertyToDictionary(budge!)
            
            fe_std_data_set_json("YSBudge", key: uid, jsonValue: dic, expire_sec: DEFAULT_EXPIRE_SEC)
        }
    }
    
    /** 新私信 */
    class func setReceivedMsg(flag: String) {
        
        if ysApplication.loginUser.uid == nil || (flag != "0" && flag != "1") {
            return
        }
        
        let uid = ysApplication.loginUser.uid
        var budge = YSBudge.getBudge()
        if budge == nil {
            
            budge = YSBudge()
            budge!.isReceivedMsg = flag
            
            YSBudge.addBudge(budge!)
            
        } else {
            
            budge!.isReceivedMsg = flag
            
            let dic = YSBudge.budgePropertyToDictionary(budge!)
            
            fe_std_data_set_json("YSBudge", key: uid, jsonValue: dic, expire_sec: DEFAULT_EXPIRE_SEC)
        }
    }
    
    class func getBudgeShowState() -> Bool {
        
        let budge = YSBudge.getBudge()
        
        if budge == nil {
            return false
        }
        
        if ysApplication.loginUser.role_type == nil {
            return false
        }
        
        switch ysApplication.loginUser.role_type {
        case "1":
            
            if budge!.isChangeTeacher == nil || budge!.isEnterCompetition == nil {
                break
            }
            
            if budge!.isChangeTeacher == "1" || budge!.isEnterCompetition == "1" {
                return true
            }
            
        case "2":
            
            if budge!.isBindTutor == nil {
                break
            }
            
            if budge!.isBindTutor == "1" {
                return true
            }
            
        case "3":
            
            if budge!.isInstitutionInvitation == nil || budge!.isMarked == nil {
                break
            }
            
            if budge!.isInstitutionInvitation == "1" || budge!.isMarked == "1" {
                return true
            }
            
        case "4":
            
            if budge!.isBindTutor == nil || budge!.isInstitutionInvitation == nil || budge!.isMarked == nil {
                break
            }
            
            if budge!.isBindTutor == "1" || budge!.isInstitutionInvitation == "1" || budge!.isMarked == "1" {
                return true
            }

        default:
            break
        }
        
        if budge!.isConcerned == nil || budge!.isReceivedMsg == nil {
            return false
        }
        
        if budge!.isConcerned == "1" || budge!.isReceivedMsg == "1" {
            return true
        }
        
        return false
    }
    
    class func getBudge() -> YSBudge? {
        
        if ysApplication.loginUser.uid == nil {
            return nil
        }
        
        let uid = ysApplication.loginUser.uid
        
        let dic = fe_std_data_get_json("YSBudge", key: uid) as? Dictionary<String, String>
        if dic == nil {
            return nil
        }

        return YSBudge.budgeWithAttributes(dic!)
    }
}

/** 上传进度 */
class YSUploadProgress: NSObject {
    
    var movieName: String! // 视频名
    var progress: String! // 参赛状态更改
    
    override init() {
        movieName = ""
        progress = ""
    }
    
    class func addUploadProgress(uploadProgress: YSUploadProgress) {
        
        if checkInputEmpty(uploadProgress.movieName) {
            return
        }
        
        if checkInputEmpty(uploadProgress.progress) {
            feSetAttrib("YSUploadProgress", key: uploadProgress.movieName, value: "0.0")
        } else {
            feSetAttrib("YSUploadProgress", key: uploadProgress.movieName, value: uploadProgress.progress)
        }
    }
    
    class func setUploadProgress(movieName: String!, newProgress: String!) {
        
        if movieName == nil || newProgress == nil {
            return
        }
        
        let progress = YSUploadProgress.getProgress(movieName)
        if progress == nil {
            
            let uploadProgress = YSUploadProgress()
            
            uploadProgress.movieName = movieName
            uploadProgress.progress = newProgress
            
            YSUploadProgress.addUploadProgress(uploadProgress)
            
        } else {
            
            feSetAttrib("YSUploadProgress", key: movieName, value: newProgress)
        }
    }
    
    class func getProgress(movieName: String!) -> String? {
        
        if movieName == nil {
            return nil
        }
        
        let uploadProgress = feGetAttrib("YSUploadProgress", key: movieName)
        
        if uploadProgress == nil {
            return nil
        }
        
        return uploadProgress!
    }
}
