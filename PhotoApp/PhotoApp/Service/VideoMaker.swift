//
//  VideoMaker.swift
//  PhotoApp
//
//  Created by 심 승민 on 2018. 4. 21..
//  Copyright © 2018년 심 승민. All rights reserved.
//

import UIKit
import AVFoundation

class VideoMaker {
    private let writer: AVAssetWriter
    private let writerInput: AVAssetWriterInput
    private let pixelBufferAdapter: AVAssetWriterInputPixelBufferAdaptor
    private var settings: [String: Any] = [:]

    init(videoSize: CGSize) throws {
        self.writer = try AVAssetWriter(url: VideoMaker.generateFilePath(), fileType: AVFileType.mov)
        self.settings = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: Int(videoSize.width),
            AVVideoHeightKey: Int(videoSize.height),
            AVVideoScalingModeKey: AVVideoScalingModeResize
        ]
        self.writerInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: settings)
        writer.add(writerInput)
        self.pixelBufferAdapter = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: writerInput,
                                                                       sourcePixelBufferAttributes: nil)
    }
    
    static func generateFilePath() throws -> URL {
        let fileName = Date().currentTimeAsFileName + ".mov"
        let cacheURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let saveURL = cacheURL.appendingPathComponent(fileName)
        return saveURL
    }
    
    func makeVideo(from images: [UIImage?], duration: Int, _ completion: @escaping (URL)->(Void)) {
        writer.startWriting()
        writer.startSession(atSourceTime: kCMTimeZero)
        let frameTime = CMTime(value: CMTimeValue(duration), timescale: Int32(images.count))
        let mediaQueue = DispatchQueue(label: "mediaQueue")
        var i = 0
        self.writerInput.requestMediaDataWhenReady(on: mediaQueue) { [self = self] in
            while self.writerInput.isReadyForMoreMediaData {
                if i >= images.count {
                    self.writerInput.markAsFinished()
                    self.writer.finishWriting {
                        completion(self.writer.outputURL)
                    }
                    break
                }

                if let image = images[i], let buffer = self.samplePixelBuffer(from: image) {
                    if i == 0 {
                        self.pixelBufferAdapter.append(buffer, withPresentationTime: kCMTimeZero)
                    } else {
                        let currPresentTime = CMTimeMultiply(frameTime, Int32(i))
                        self.pixelBufferAdapter.append(buffer, withPresentationTime: currPresentTime)
                    }
                    i += 1
                }
            }
        }
    }
    
    func samplePixelBuffer(from image: UIImage) -> CVPixelBuffer? {
        guard let image = image.cgImage,
            let videoWidth = self.settings[AVVideoWidthKey] as? Int,
            let videoHeight = self.settings[AVVideoHeightKey] as? Int else { return nil }
        var resultBuffer: CVPixelBuffer?

        CVPixelBufferCreate(kCFAllocatorDefault, videoWidth, videoHeight, kCVPixelFormatType_32ARGB, nil, &resultBuffer)
        CVPixelBufferLockBaseAddress(resultBuffer!, .init(rawValue: 0))
        
        let pixelData = CVPixelBufferGetBaseAddress(resultBuffer!)
        let context = CGContext(data: pixelData, width: videoWidth, height: videoHeight,
                                bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(resultBuffer!),
                                space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        // 중앙정렬
        let yCenter = (videoHeight-image.height)/2
        // 이미지 사이즈를 비디오 사이즈에 딱 맞도록 sizeToFit해서 그린다.
        let imageSize = CGSize(width: image.width, height: image.height)
        let videoSize = CGSize(width: videoWidth, height: videoHeight)
        context?.draw(image, in: CGRect(origin: CGPoint(x: 0, y: yCenter), size: imageSize.sizeToFit(in: videoSize)))

        CVPixelBufferUnlockBaseAddress(resultBuffer!, .init(rawValue: 0))
        
        return resultBuffer
    }
}

extension CGSize {
    func sizeToFit(in boundSize: CGSize) -> CGSize {
        let widthRatio = boundSize.width / self.width
        let heightRatio = boundSize.height / self.height
        let ratio = min(widthRatio, heightRatio)
        return CGSize(width: width*ratio, height: height*ratio)
    }
}

extension Date {
    var currentTimeAsFileName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyymmddss"
        return formatter.string(from: self)
    }
}
