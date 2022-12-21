//
//  DDYAudioProcessor.swift
//  DDYAudioUtilsDemo
//
//  Created by ddy on 2022/12/21.
//

import AVFoundation

class DDYAudioProcessor {
    private let maxNumberOfFrames: AVAudioFrameCount = 8192
    private let avAudioFile: AVAudioFile!
    private var audioPlayerNode = AVAudioPlayerNode()
    private var audioEngine = AVAudioEngine()
    
    init(with audioFile: URL) throws {
        self.avAudioFile = try AVAudioFile.init(forReading: audioFile)
    }
}

// MARK: - Private methods
extension DDYAudioProcessor {
    private func prepareAudioEngine(forEffect effect: DDYEffect) {
        stop()
        audioEngine = AVAudioEngine()
        audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attach(audioPlayerNode)
        var previousNode: AVAudioNode = audioPlayerNode
        for audioUnit in effect.audioUnits {
            audioEngine.attach(audioUnit)
            audioEngine.connect(previousNode, to: audioUnit, format: nil)
            previousNode = audioUnit
        }
        audioEngine.connect(previousNode, to: audioEngine.mainMixerNode, format: nil)
    }
}


// MARK: Internal methods
extension DDYAudioProcessor {
    func manualAudioRender(effect: DDYEffect, toFile: URL) throws {
        prepareAudioEngine(forEffect: effect)
        audioPlayerNode.scheduleFile(avAudioFile, at: nil)
        try audioEngine.enableManualRenderingMode(.offline, format: avAudioFile.processingFormat, maximumFrameCount: maxNumberOfFrames)
        try audioEngine.start()
        audioPlayerNode.play()
        
        let outputFile = try AVAudioFile(forWriting: toFile, settings: avAudioFile.fileFormat.settings)
        let buffer = AVAudioPCMBuffer(pcmFormat: audioEngine.manualRenderingFormat, frameCapacity: audioEngine.manualRenderingMaximumFrameCount)!
        let outputFileLength = Int64(Double(avAudioFile.length) / effect.rate)
        
        while audioEngine.manualRenderingSampleTime < outputFileLength {
            let framesToRender = min(buffer.frameCapacity, AVAudioFrameCount(outputFileLength - audioEngine.manualRenderingSampleTime))
            let status = try audioEngine.renderOffline(framesToRender, to: buffer)
            switch status {
            case .success:
                try outputFile.write(from: buffer)
            case .error:
                print("Error rendering offline audio")
                return
            default:
                break
            }
        }
        
        audioPlayerNode.stop()
        audioEngine.stop()
        audioEngine.disableManualRenderingMode()
    }
    
    func play(with effect: DDYEffect) {
        audioPlayerNode = AVAudioPlayerNode()
        prepareAudioEngine(forEffect: effect)
        audioPlayerNode.scheduleFile(avAudioFile, at: nil, completionHandler: nil)
        try? audioEngine.start()
        audioPlayerNode.play()
    }
    
    func stop() {
        audioPlayerNode.stop()
        audioEngine.stop()
        audioEngine.reset()
    }
}
