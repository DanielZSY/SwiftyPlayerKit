
import UIKit

/// 录音的 delegate 函数
public protocol ZAudioRecordDelegate: class {
    /// 更新进度 , 0.0 - 9.0, 浮点数
    func audioRecordUpdateMetra(_ metra: Float, audioTimeInterval: Int32)
    /// 录音太短
    func audioRecordTooShort()
    /// 录音失败
    func audioRecordFailed()
    /// 取消录音
    func audioRecordCanceled()
    /// 录音完成
    /// - parameter recordTime:        录音时长
    /// - parameter uploadAmrData:     上传的 amr Data
    /// - parameter filepath:          amr 音频数据的本地地址
    func audioRecordFinish(uploadData: Data, recordTime: Float, filepath: URL)
}
