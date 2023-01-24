import SwiftUI
import AVFoundation

public struct HEICCompressor {
    
    static func compressToHEICData(for images: [UIImage], compressionQuality: CGFloat) -> [Data] {
        let imagesData = images.compactMap { image in
            do {
                return try image.heicData(compressionQuality: compressionQuality)
            } catch {
                return nil
            }
        }
        print("compressToHEICData \(imagesData.count) images")
        return imagesData
    }
    
    static func compressToHEICDataAsync(for images: [UIImage], compressionQuality: CGFloat) async -> [Data] {
        //  UseTaskGroup
        // make that async! max 4 threads per batch
        let imagesData: [Data?] = images.map { image in
            do {
                return try image.heicData(compressionQuality: compressionQuality)
            } catch {
                return nil
            }
        }
        let data = imagesData.compactMap { $0 }
        
        print("compressToHEICDataAsync \(data.count) images")
        return data
    }
}



extension UIImage {
   enum HEICError: Error {
        case heicNotSupported
        case cgImageMissing
        case canNotFinalize
        case cgImageNotAddedAndFinished
        case noUIImageCreated
    }
    
   public  func heicData(compressionQuality: CGFloat) throws -> Data {
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
    
   public func heicImage(compressionQuality: CGFloat)  throws -> UIImage {
        do {
            let heicData = try self.heicData(compressionQuality: compressionQuality)
            print("HEICCompressor - heicData = \(heicData.count)")
            guard let image = UIImage(data: heicData) else { throw HEICError.noUIImageCreated }
            return image
        } catch {
            throw error
        }
    }
}
