
import UIKit
import SnapKit

/// 自定义UI控件
open class ZBMPlayerCustomControlView: BMPlayerControlView {
    
    /// Override if need to customize UI components
    open override func customizeUIComponents() {
        // just make the view hidden
        topMaskView.isHidden = true
        chooseDefinitionView.isHidden = true
        
        // or remove from superview
        titleLabel.removeFromSuperview()
        backButton.removeFromSuperview()
        playButton.removeFromSuperview()
        replayButton.removeFromSuperview()
        currentTimeLabel.removeFromSuperview()
        totalTimeLabel.removeFromSuperview()
        timeSlider.removeFromSuperview()
        fullscreenButton.removeFromSuperview()
        
        progressView.snp.remakeConstraints { (make) in
            make.bottom.left.right.equalTo(bottomMaskView)
            make.height.equalTo(1)
        }
    }
}

