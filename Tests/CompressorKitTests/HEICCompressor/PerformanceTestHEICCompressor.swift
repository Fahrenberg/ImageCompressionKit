//
//  ------------------------------------------------
//  -----------   PerformanceTestHEICCompressor -----------------
//  ------------------------------------------------
//
    
import XCTest
@testable import CompressorKit
import XCTest

final class PerformanceTestHEICCompressor: XCTestCase {
   
    var measureOnlyOnce: XCTMeasureOptions {
        let option = XCTMeasureOptions()
        option.iterationCount = 1
        return option
    }
    
    
    func testPerformanceHEICCompression() throws {
        let imageName = "large"
        let compressionQuality: CGFloat = 0.5
        let image = try XCTUnwrap(UIImage(named: imageName, in: Bundle.module, with: nil))
        
        self.measure() { // average: 0.375
            do {
                _ = try image.heicImage(compressionQuality: compressionQuality)
            }
            catch {
                print(error.localizedDescription)
            }
        }
        
    }
    
    
    func testPerformanceHEICCompress10Images() throws {
        let imageCount = 10
        let imageName = "large"
        let heicQuality: CGFloat = 0.5
        
        let image = try XCTUnwrap(UIImage(named: imageName, in: Bundle.module, with: nil))
       
        
        let images = Array(repeating: image, count: imageCount)
        
        self.measure(options: measureOnlyOnce) { // 1.574 = 5 images , 3.780 = 10 images
            _ = HEICCompressor.compressToHEICData(for: images, compressionQuality: heicQuality)
        }
        
        
    }

    func testAsyncPerformanceHEICCompress10Images()  throws {
        let imageCount = 10
        let imageName = "large"
        let heicQuality: CGFloat = 0.5
        
        let image = try XCTUnwrap(UIImage(named: imageName, in: Bundle.module, with: nil))
       
        
        let images = Array(repeating: image, count: imageCount)
        
        self.measure(options: measureOnlyOnce) { // .... = 10 images
            let exp = expectation(description: "AsyncCompression")
            Task {
                _ = await HEICCompressor.compressToHEICDataAsync(for: images, compressionQuality: heicQuality)
                exp.fulfill()
            }
            wait(for: [exp], timeout: 200.0)
            
        }
        
        
    }
    
    
    func testPerformanceUIImageFromHEICData() throws {
        let imageName = "large"
        let compressionQuality: CGFloat = 0.5
        let image = try XCTUnwrap(UIImage(named: imageName, in: Bundle.module, with: nil))
        let heicData = try image.heicData(compressionQuality: compressionQuality)
        
        self.measure(options: measureOnlyOnce) {
                _ =  UIImage(data: heicData)
        }
    }
    
    
    func testPerformance100ImagesFromHEICData() throws {
        let imageName = "large"
        let compressionQuality: CGFloat = 0.5
        let image = try XCTUnwrap(UIImage(named: imageName, in: Bundle.module, with: nil))
        let heicData = try image.heicData(compressionQuality: compressionQuality)
        
        let heicDataImages = Array(repeating: heicData, count: 200)
        
        self.measure { // average: 0.075
             _ =  heicDataImages.compactMap { heicData in
                _ =   UIImage(data: heicData) ?? nil
            }
        }
    }
    
    
    
}
