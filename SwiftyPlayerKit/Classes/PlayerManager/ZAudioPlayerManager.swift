
import UIKit
import AVKit
import BFKit

/// 默认名称
public enum ZEnumAudioPlayerName: String {
    /// 主播端呼叫声音
    case anchor
    /// 应答按钮声音
    case answer
    /// 匹配过程中声音
    case match
    /// 挂断按钮声音
    case reject
    /// 用户端呼叫声音
    case user
}
/// 播放指定音频
public class ZAudioPlayerManager: NSObject {
    
    /// 静态模式
    public static let shared = ZAudioPlayerManager()
    /// 是否播放中
    public var isPlay: Bool { return self.isPlaying }
    /// 是否播放中
    private var isPlaying: Bool = false
    /// 播放音频对象
    private var audioPlayer: AVAudioPlayer?
    
    /// 开始播放声音
    public final func playSound(name: ZEnumAudioPlayerName) {
        self.stopSound()
        if self.isPlaying { return }
        do {
            let session = AVAudioSession.sharedInstance()
            // 启动音频会话管理，此时会阻断后台音乐播放
            try session.setActive(true)
            // 设置音频播放类别，表示该应用仅支持音频播放
            try session.setCategory(AVAudioSession.Category.playback)
            // 将字符串路径转化为网址路径
            var soundUrl = URL.audioUrl(named: name.rawValue)
            if soundUrl == nil {
                soundUrl = Bundle.main.url(forResource: "Audio", withExtension: "bundle")?.appendingPathComponent(name.rawValue).appendingPathExtension("mp3")
            }
            guard let url = soundUrl else { return }
            BFLog.debug("soundUrl: \(url.path)")
            // 创建播放器对象
            try self.audioPlayer = AVAudioPlayer.init(contentsOf: url)
            // 为音频播放做好准备
            self.audioPlayer?.prepareToPlay()
            // 设置音量
            self.audioPlayer?.volume = 1.0
            // 设置音频播放的次数，-1为无限循环播放
            self.audioPlayer?.numberOfLoops = -1
            DispatchQueue.main.async {
                self.audioPlayer?.play()
            }
            self.isPlaying = true
        } catch {
            BFLog.debug("error: \(error.localizedDescription)")
        }
    }
    /// 停止播放声音
    public final func stopSound() {
        DispatchQueue.main.async {
            self.audioPlayer?.pause()
            self.audioPlayer?.stop()
        }
        self.audioPlayer?.delegate = nil
        self.audioPlayer = nil
        self.isPlaying = false
    }
    /// 继续其他播放器播放音乐
    public final func startOtherPlayer() {
        DispatchQueue.main.async {
            do {
                // 启动音频会话管理，此时会阻断后台音乐播放
                try AVAudioSession.sharedInstance().setActive(false, options: AVAudioSession.SetActiveOptions.notifyOthersOnDeactivation)
            }
            catch {
                BFLog.debug("error: \(error.localizedDescription)")
            }
        }
    }
    /// 震动
    public final func systemVibration() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
    /// 开始持续震动
    private final func startSystemVibrate() {
        AudioServicesAddSystemSoundCompletion(kSystemSoundID_Vibrate, nil, nil, { (sound, _)  in
            let additionalTime: DispatchTimeInterval = .seconds(3)
            DispatchQueue.main.asyncAfter(deadline: .now() + additionalTime, execute: {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            })
        }, nil)
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
    //结束持续震动
    private final func stopSystemVibrate() {
        AudioServicesRemoveSystemSoundCompletion(kSystemSoundID_Vibrate)
        AudioServicesDisposeSystemSoundID(kSystemSoundID_Vibrate)
    }
    /// 音频结束时的回调
    private func audioServicesPlaySystemSoundCompleted(soundID: SystemSoundID) {
        BFLog.debug("Completion: \(soundID)")
        self.isPlaying = false
        AudioServicesRemoveSystemSoundCompletion(soundID)
        AudioServicesDisposeSystemSoundID(soundID)
    }
}
extension ZAudioPlayerManager: AVAudioPlayerDelegate {
    
    public func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        BFLog.debug("audioPlayerDecodeErrorDidOccur")
    }
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        BFLog.debug("audioPlayerDidFinishPlaying")
    }
}
