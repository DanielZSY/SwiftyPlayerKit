import UIKit
import BFKit
import CryptoSwift
import AVFoundation

private let kAudioFileTypeWav = "wav"
private let kAudioFileTypeAmr = "amr"
private let kTempWavRecordPath = ZAudioRecordManager.createLocalDataFolder("TempFileFolder")
/// 录制音频跟地址
public let ZAudioRecordPath = ZAudioRecordManager.createLocalDataFolder("AudioWavRecord")
/// 音频录制管理类
public class ZAudioRecordManager: NSObject {
    
    internal var recorder: AVAudioRecorder!
    internal var operationQueue: OperationQueue!
    /// 代理协议
    public weak var delegate: ZAudioRecordDelegate?
    /// 正在录制文件地址
    private let recordAudioPath = kTempWavRecordPath.appendingPathComponent("wav_temp_record").appendingPathExtension(kAudioFileTypeWav)
    /// 录音开始时间
    private var startTime: CFTimeInterval!
    /// 录音结束时间
    private var endTimer: CFTimeInterval!
    private var audioTimeInterval: NSNumber!
    private var isFinishRecord: Bool = true
    private var isCancelRecord: Bool = false
    /// 静态
    public static var shared: ZAudioRecordManager {
        struct Static {
            static let instance = ZAudioRecordManager()
        }
        return Static.instance
    }
    private override init() {
        self.operationQueue = OperationQueue()
        super.init()
    }
    /// 获取录音权限并初始化录音
    public final func checkPermissionAndSetupRecord() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: .duckOthers)
            try session.setActive(true)
            session.requestRecordPermission{ allowed in
                if !allowed {
                    if let url = URL.init(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(url, options: [ : ]) { (success) in }
                        } else {
                            UIApplication.shared.openURL(url)
                        }
                    }
                }
            }
        } catch {
            BFLog.error("Could not activate the audio error: \(error.localizedDescription)")
        }
    }
    /// 开始录音
    public final func startRecord() {
        self.deleteRecordFiles()
        self.isCancelRecord = false
        self.startTime = CACurrentMediaTime()
        do {
            // 基础参数
            let recordSettings:[String: AnyObject] = [
                // 线性采样位数  8、16、24、32
                AVLinearPCMBitDepthKey: NSNumber(value: 16),
                // 设置录音格式  kAudioFormatLinearPCM
                AVFormatIDKey: NSNumber(value: kAudioFormatLinearPCM),
                // 录音通道数  1 或 2
                AVNumberOfChannelsKey: NSNumber(value: 1),
                // 设置录音采样率(Hz)  8000/44100/96000（影响音频的质量）
                AVSampleRateKey: NSNumber(value: 8000.0)
            ]
            self.recorder = try AVAudioRecorder(url: self.recordAudioPath, settings: recordSettings)
            self.recorder.delegate = self
            self.recorder.isMeteringEnabled = true
            self.recorder.prepareToRecord() // creates/overwrites the file at soundFileURL
        } catch let error {
            self.recorder.delegate = nil
            self.recorder = nil
            BFLog.error("初始化录音功能失败 error localizedDescription: \(error.localizedDescription)")
        }
        self.perform(#selector(ZAudioRecordManager.readyStartRecord), with: self, afterDelay: 0.0)
    }
    /// 准备录音
    @objc private func readyStartRecord() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category(rawValue: AVAudioSession.Category.record.rawValue))
            try audioSession.setActive(true)
        } catch let error  {
            BFLog.error("初始化录音功能失败 error localizedDescription: \(error.localizedDescription)")
            return
        }
        self.recorder.record()
        let operation = BlockOperation()
        operation.addExecutionBlock(updateMeters)
        self.operationQueue.addOperation(operation)
    }
    /// 更新进度
    private func updateMeters() {
        guard let recorder = self.recorder else { return }
        
        repeat {
            recorder.updateMeters()
            self.audioTimeInterval = NSNumber(value: NSNumber(value: recorder.currentTime as Double).floatValue as Float)
            //获取音量的平均值 会返回当前的分贝值，取值范围是 -160 ～ 0 db， 0 是很吵， -160 是很安静
            let averagePower = recorder.averagePower(forChannel: 0)
            let lowPassResult = pow(10, (averagePower/20)) * 10
            DispatchQueue.main.async(execute: {
                self.delegate?.audioRecordUpdateMetra(lowPassResult, audioTimeInterval: self.audioTimeInterval.int32Value)
            })
            // 如果大于 60 ,停止录音
            if self.audioTimeInterval.int32Value > 60 {
                self.stopRecord()
            }
            Thread.sleep(forTimeInterval: 0.05)
        } while(recorder.isRecording)
    }
    /// 停止录音
    public final func stopRecord() {
        self.isFinishRecord = true
        self.isCancelRecord = false
        self.endTimer = CACurrentMediaTime()
        // TODO: 录制音频小于2秒提示时间太短
        if (self.endTimer - self.startTime) < 2 {
            self.cancelRrcord()
            DispatchQueue.main.async(execute: {
                self.delegate?.audioRecordTooShort()
            })
        } else {
            self.audioTimeInterval = NSNumber(value: NSNumber(value: self.recorder.currentTime as Double).int32Value as Int32)
            if self.audioTimeInterval.int32Value < 1 {
                self.perform(#selector(ZAudioRecordManager.readyStopRecord), with: self, afterDelay: 0.4)
            } else {
                self.readyStopRecord()
            }
        }
        self.operationQueue.cancelAllOperations()
    }
    /// 取消录音
    public final func cancelRrcord() {
        self.isCancelRecord = true
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(ZAudioRecordManager.readyStartRecord), object: self)
        self.isFinishRecord = false
        self.recorder.stop()
        self.recorder.deleteRecording()
        self.recorder = nil
        self.delegate?.audioRecordCanceled()
    }
    /// 准备停止录制
    @objc private func readyStopRecord() {
        self.recorder.stop()
        self.recorder = nil
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
        } catch let error {
            BFLog.error("error:\(error.localizedDescription)")
        }
    }
    /// 删除录音文件
    public final func deleteRecordFiles() {
        ZAudioRecordManager.deleteFilesWithPath(self.recordAudioPath.path)
    }
    /// 创建本地文件的文件夹
    fileprivate static func createLocalDataFolder(_ filename: String) -> URL {
        let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let folder = cachesDirectory.appendingPathComponent(filename)
        if !FileManager.default.fileExists(atPath: folder.path) {
            do {
                try FileManager.default.createDirectory(atPath: folder.path, withIntermediateDirectories: true, attributes: nil)
            } catch let error {
                BFLog.error("createLocalDataFolder error:\(error.localizedDescription)")
            }
        }
        return folder
    }
    /// 删除文件
    /// - parameter path: 路径
    fileprivate static func deleteFilesWithPath(_ path: String) {
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: path)
            let recordings = files.filter( { (name: String) -> Bool in
                return name.hasSuffix(kAudioFileTypeWav)
            })
            for i in 0 ..< recordings.count {
                let path = path + "/" + recordings[i]
                BFLog.info("removing \(path)")
                do {
                    try FileManager.default.removeItem(atPath: path)
                } catch let error {
                    BFLog.info("could not remove error: \(error.localizedDescription)")
                }
            }
        } catch let error {
            BFLog.info("could not remove error: \(error.localizedDescription)")
        }
    }
    /// 移动文件
    /// - parameter originPath:     原路径
    /// - parameter toPath:         目标路径
    /// - returns: 目标路径
    @discardableResult
    fileprivate static func moveFile(_ originPath: URL, toPath: URL) -> Bool {
        do {
            try FileManager.default.moveItem(at: originPath, to: toPath)
            return true
        } catch let error {
            BFLog.error("moveFile error:\(error.localizedDescription)")
        }
        return false
    }
}
extension ZAudioRecordManager: AVAudioRecorderDelegate {
    
    /// 完成录音的回调
    public func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag && self.isFinishRecord {
            // 获取 wav 文件的 NSData, 改名字使用
            guard let wavAudioData = try? Data.init(contentsOf: self.recordAudioPath) else {
                self.delegate?.audioRecordFailed()
                self.deleteRecordFiles()
                return
            }
            let fileNewUrl = ZAudioRecordManager.createLocalDataFolder("AudioWavRecord").appendingPathComponent(wavAudioData.base64EncodedString().md5()).appendingPathExtension(kAudioFileTypeWav)
            ZAudioRecordManager.moveFile(self.recordAudioPath, toPath: fileNewUrl)
            BFLog.debug("recordAudioPath: \(fileNewUrl.path)")
            self.delegate?.audioRecordFinish(uploadData: wavAudioData, recordTime: self.audioTimeInterval.floatValue, filepath: fileNewUrl)
        } else {
            // 如果不是取消录音，再进行回调 failed 方法
            if !self.isCancelRecord {
                self.delegate?.audioRecordFailed()
            }
        }
        self.deleteRecordFiles()
    }
    /// 录音错误回调
    public func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if error != nil {
            self.delegate?.audioRecordFailed()
        }
        self.deleteRecordFiles()
    }
}
