
import UIKit

/// 全屏播放器
open class ZVideoPlayerViewController: UIViewController {
    
    /// 播放资源对象
    public var resource: BMPlayerResource? {
        didSet {
            guard let resource = resource else { return }
            self.viewPlayer.setVideo(resource: resource)
        }
    }
    private var currentTime: TimeInterval = 0
    private var totalTime: TimeInterval = 1
    private lazy var viewPlayer: BMPlayer = {
        let control = BMPlayerControlView()
        let item = BMPlayer.init(customControlView: control)
        item.frame = CGRect.init(x: 0, y: 0, width: UIScreen.screenWidth, height: UIScreen.screenHeight)
        item.backgroundColor = self.view.backgroundColor
        item.videoGravity = .resizeAspectFill
        return item
    }()
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(viewPlayer)
    }
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.viewPlayer.playTimeDidChange = { current, total in
            self.currentTime = current
            self.totalTime = total
            if self.currentTime == self.totalTime {
                self.replayer()
            }
        }
        self.startPlayer()
    }
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.stopPlayer()
        self.viewPlayer.playTimeDidChange = nil
    }
    private func replayer() {
        self.viewPlayer.seek(0, completion: {
            DispatchQueue.main.async(execute: {
                self.viewPlayer.play()
            })
        })
    }
    private func startPlayer() {
        if self.currentTime == self.totalTime {
            self.viewPlayer.seek(0, completion: {
                DispatchQueue.main.async(execute: {
                    self.viewPlayer.play()
                })
            })
        } else {
            DispatchQueue.main.async(execute: {
                self.viewPlayer.play()
            })
        }
    }
    private func stopPlayer() {
        DispatchQueue.main.async(execute: {
            self.viewPlayer.pause()
        })
    }
}
