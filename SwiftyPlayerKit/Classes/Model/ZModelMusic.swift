
import UIKit

/// 音乐对象
public struct ZModelMusic {
    /// 音乐名称
    public var name: String = ""
    /// 音乐作者
    public var author: String = ""
    /// 音乐图片地址
    public var imageUrl: String = ""
    /// 音乐播放地址
    public var playpath: String = ""
    /// 总时长
    public var durantion: Int = 0
    /// 初始化
    public init(named: String, user: String, image: String, url: String, time: Int) {
        self.name = named
        self.author = user
        self.imageUrl = image
        self.playpath = url
        self.durantion = time
    }
}
