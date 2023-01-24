import UIKit

public struct ImageCompressor {
    
    private static func getPercentageToDecreaseTo(forDataCount dataCount: Int) -> CGFloat {
           switch dataCount {
           case 0..<3000000: return 0.05
           case 3000000..<10000000: return 0.1
           default: return 0.2
           }
       }
    static public func compress(image: UIImage,
                                maxBytes: UInt64,
                                startCompression: CGFloat = 1.0) -> UIImage?
    {
        guard let currentImageSize = image.pngData()?.count else { return nil }
        var iterationImage: UIImage? = image
        var iterationImageSize = currentImageSize
        var iterationCompression: CGFloat = startCompression
        var countIteration = 0
        while iterationImageSize > maxBytes && iterationCompression > 0.01 {
            let percentageDecrease = getPercentageToDecreaseTo(forDataCount: iterationImageSize)
            
            let canvasSize = CGSize(width: image.size.width * iterationCompression,
                                    height: image.size.height * iterationCompression)
            
            iterationImage =  image.preparingThumbnail(of: canvasSize)
            guard let newImageSize = iterationImage?.pngData()?.count else {
                return nil
            }
            iterationImageSize = newImageSize
            iterationCompression -= percentageDecrease
            countIteration += 1
        }
        
        print("ImageCompressor - originalSize \(currentImageSize), compressedSize \(iterationImageSize),  factor \(iterationCompression), iterations \(countIteration)")
        
        return iterationImage
    }
    
    
}



