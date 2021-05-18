
import UIKit

extension Bundle {
    static var audioAssetBundle: Bundle {
        guard let url = Bundle(for: ZVideoPlayerViewController.self).url(forResource: "SwiftyAudioKit", withExtension: "bundle"),
              let resourcesBundle = Bundle(url: url)
        else {
            return Bundle(for: ZVideoPlayerViewController.self)
        }
        return resourcesBundle
    }
    static var playerAssetBundle: Bundle {
        guard let url = Bundle(for: ZVideoPlayerViewController.self).url(forResource: "SwiftyPlayerKit", withExtension: "bundle"),
              let resourcesBundle = Bundle(url: url)
        else {
            return Bundle(for: ZVideoPlayerViewController.self)
        }
        return resourcesBundle
    }
}
extension URL {
    static func audioUrl(named: String) -> URL? {
        return Bundle.audioAssetBundle.url(forResource: "Audio", withExtension: "bundle")?.appendingPathComponent(named).appendingPathExtension("mp3")
    }
}

extension UIImage {
    static func assetImage(named: String) -> UIImage? {
        let image = UIImage(named: named, in: Bundle.playerAssetBundle, compatibleWith: nil)
        if image == nil {
            return UIImage.init(named: named)
        }
        return image
    }
}
