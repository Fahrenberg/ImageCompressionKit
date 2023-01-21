import SwiftUI
import AVFoundation

extension UIImage {
    enum HEICError: Error {
        case heicNotSupported
        case cgImageMissing
        case canNotFinalize
        case cgImageNotAddedAndFinished
        case noUIImageCreated
    }
    
    func heicData(compressionQuality: CGFloat) async throws -> Data {
        let data = NSMutableData()
        guard let imageDestination =
                CGImageDestinationCreateWithData(
                    data, AVFileType.heic as CFString, 1, nil
                )
        else {
            throw HEICError.heicNotSupported
        }
        
        guard let cgImage = self.cgImage else {
            throw HEICError.cgImageMissing
        }
        
        let options: NSDictionary = [
            kCGImageDestinationLossyCompressionQuality: compressionQuality
        ]
        
        CGImageDestinationAddImage(imageDestination, cgImage, options)
        guard CGImageDestinationFinalize(imageDestination) else {
            throw HEICError.cgImageNotAddedAndFinished
        }
        
        return data as Data
    }
    
    func heicImage(compressionQuality: CGFloat)  async throws -> UIImage {
        do {
            let heicData = try await self.heicData(compressionQuality: compressionQuality)
            print("heicData = \(heicData.count)")
            guard let image = UIImage(data: heicData) else { throw HEICError.noUIImageCreated }
            return image
        } catch {
            throw error
        }
    }
}
