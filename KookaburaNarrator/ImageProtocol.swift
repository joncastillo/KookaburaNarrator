import SwiftUI

protocol ImageProtocol {
    func jpegData(compressionQuality: CGFloat) -> Data?
}

extension UIImage: ImageProtocol {}
