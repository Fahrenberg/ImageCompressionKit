//
//  -------------------------------------------------------------------
//  ---------------              JPGCompressor   		 --------------
//  ---------------			                    		 --------------
//  -------					                                    -------
//  -------------------------------------------------------------------


import Foundation
import UIKit

public struct JPGCompressor {
    
    static func compressToJPGData(for images: [UIImage], compressionQuality: CGFloat) -> [Data] {
        let imagesData = images.compactMap { image in
            do {
                return try image.jpgCompressorData(compressionQuality: compressionQuality)
            } catch {
                return nil
            }
        }
        print("compressToJPGData \(imagesData.count) images")
        return imagesData
    }
    
    static func compressToHEICDataAsync(for images: [UIImage], compressionQuality: CGFloat) async -> [Data] {
        //  UseTaskGroup
        // make that async! max 4 threads per batch
        let imagesData: [Data?] = images.map { image in
            do {
                return try image.jpgCompressorData(compressionQuality: compressionQuality)
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
   enum JPGError: Error {
       case image_has_no_data_or_unsupported_bitmap_format
       case noUIImageCreated
       case unknown
    }
   /// Use it only with [supported devices for HEIC](https://support.apple.com/en-us/HT207022)
   public  func jpgCompressorData(compressionQuality: CGFloat) throws -> Data {
       guard let data = jpegData(compressionQuality: compressionQuality) else { throw JPGError.image_has_no_data_or_unsupported_bitmap_format }
       print("JPGCompressor -jpgData = \(data.count)")
       return data
    }
    
   public func jpgCompressorImage(compressionQuality: CGFloat)  throws -> UIImage {
        do {
            let jpgData = try self.jpgCompressorData(compressionQuality: compressionQuality)
            guard let image = UIImage(data: jpgData) else { throw JPGError.noUIImageCreated }
            return image
        } catch {
            throw error
        }
    }
}
