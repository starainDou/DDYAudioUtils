//
//  DDYAudioChangeViewController.swift
//  DDYAudioUtilsDemo
//
//  Created by doudianyu on 2022/1/29.
//

import UIKit
import AVFoundation
import DDYAudioUtils

class DDYAudioChangeViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    private lazy var recordButton: UIButton = btn(title: "开始录制", y: 100, action: #selector(recordAction(_:)))
    
    private lazy var playButton: UIButton = btn(title: "播放录音", y: 150, action: #selector(playAction(_:)))
    
    private lazy var echoButton: UIButton = btn(title: "回响[0]", y: 250, action: #selector(echoAction(_:)))
    /// 录音器
    private var recorder: AVAudioRecorder?
    /// 播放器
    private var player: AVAudioPlayer?
    
    private lazy var pitchButtons: [UIButton] = []
    
    private let recordSetting: [String: Any] = [AVFormatIDKey: NSNumber(value: kAudioFormatLinearPCM),
                                              AVSampleRateKey: NSNumber(value: 8000),
                                        AVNumberOfChannelsKey: NSNumber(value: 1),
                                       AVLinearPCMBitDepthKey: NSNumber(value: 16),
                                     AVEncoderAudioQualityKey: NSNumber(value: AVAudioQuality.low.rawValue)]
    
    private func btn(title: String, y: CGFloat, action: Selector) -> UIButton {
        return UIButton(type: .custom).ddy_then {
            $0.frame = CGRect(x: 20, y: y, width: UIScreen.main.bounds.width - 40, height: 40)
            $0.setTitle(title, for: .normal)
            $0.setTitleColor(.red, for: .normal)
            $0.backgroundColor = .lightGray
            $0.addTarget(self, action: action, for: .touchUpInside)
            $0.isHidden = true
        }
    }
    
    private lazy var soundQueue = OperationQueue().ddy_then {
        $0.maxConcurrentOperationCount = 1
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "变声测试"
        view.backgroundColor = .white
        view.addSubview(recordButton)
        view.addSubview(playButton)
        view.addSubview(echoButton)
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] isGranted in
            DispatchQueue.main.async {
                self?.recordButton.isHidden = !isGranted
            }
        }
    }
    
    private func showPitchSelectView() {
        let pitchs = [0, 12, -7, -12, 3, 7]
        for btn in pitchButtons {
            btn.removeFromSuperview()
        }
        for (index, pitch) in pitchs.enumerated() {
            view.addSubview(UIButton(type: .custom).ddy_then {
                let width = (UIScreen.main.bounds.width - 90) / 6
                $0.frame = CGRect(x: 20 + (width + 10) * CGFloat(index), y: 300, width: width, height: 30)
                $0.setTitle("变声\(index)", for: .normal)
                $0.setTitleColor(.red, for: .normal)
                $0.backgroundColor = .lightGray
                $0.titleLabel?.font = UIFont.systemFont(ofSize: 12)
                $0.addTarget(self, action: #selector(changeAction(_:)), for: .touchUpInside)
                $0.tag = pitch + 13
            })
        }
    }
    
    @objc private func recordAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        sender.setTitle(sender.isSelected ? "停止录制" : "开始录制", for: .normal)
        playButton.isHidden = sender.isSelected
        echoButton.isHidden = sender.isSelected
        if sender.isSelected {
            try? AVAudioSession.sharedInstance().setCategory(.playAndRecord)
            try? AVAudioSession.sharedInstance().setActive(true)
            recorder = try? AVAudioRecorder(url: URL(fileURLWithPath: ViewController.wavPath), settings: recordSetting)
            recorder?.isMeteringEnabled = true
            recorder?.delegate = self
            if recorder?.prepareToRecord() == true {
                recorder?.record()
                print("开始录制")
            } else {
                print("录制失败")
            }
        } else {
            recorder?.stop()
            showPitchSelectView()
        }
    }
    
    @objc private func playAction(_ sender: UIButton) {
        if changePlayState() {
            if FileManager.default.fileExists(atPath: ViewController.magicPath) {
                try? AVAudioSession.sharedInstance().setCategory(.playback)
                player = try? AVAudioPlayer(contentsOf: URL(fileURLWithPath: ViewController.magicPath))
                player?.numberOfLoops = 0
                player?.delegate = self
                player?.isMeteringEnabled = true
                if player?.prepareToPlay() == true {
                    player?.play()
                    print("开始播放")
                } else {
                    print("播放失败")
                }
            } else {
                print("录音文件不存在！")
                if FileManager.default.fileExists(atPath: ViewController.wavPath) {
                    try? AVAudioSession.sharedInstance().setCategory(.playback)
                    player = try? AVAudioPlayer(contentsOf: URL(fileURLWithPath: ViewController.wavPath))
                    player?.numberOfLoops = 0
                    player?.delegate = self
                    player?.isMeteringEnabled = true
                    if player?.prepareToPlay() == true {
                        player?.play()
                        print("开始播放")
                    } else {
                        print("播放失败")
                    }
                } else {
                    print("wavPath 录音文件不存在！")
                }
            }
            
        } else {
            player?.stop()
            print("停止播放")
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        changePlayState()
    }
    @discardableResult private func changePlayState() -> Bool {
        playButton.isSelected = !playButton.isSelected
        playButton.setTitle(playButton.isSelected ? "停止播放" : "播放录音", for: .normal)
        recordButton.isHidden = playButton.isSelected
        return playButton.isSelected
    }
    
    @objc private func changeAction(_ sender: UIButton) {
        let pitch = sender.tag - 13
        if FileManager.default.fileExists(atPath: ViewController.magicPath) {
            try? FileManager.default.removeItem(atPath: ViewController.magicPath)
        }
        
        if let data = try? Data(contentsOf: URL(fileURLWithPath: ViewController.wavPath)) {
            self.recordButton.isEnabled = false
            self.playButton.isEnabled = false
            DispatchQueue.global().async {
                let config = DDYACConfig(sampleRate: 8000, tempoChange: 0, pitch: Int32(pitch), rate: 0, channels: 1)
                let changedData = DDYAudioChange.change(data, with: config)
                DispatchQueue.main.async {
                    
                    if (self.echoButton.isSelected) {
                        self.recordButton.isEnabled = true
                        self.playButton.isEnabled = true
                        try? changedData?.write(to: URL(fileURLWithPath: ViewController.tempPath))
                        
                        let srcURL = URL(fileURLWithPath: ViewController.tempPath)
                        let dstURL = URL(fileURLWithPath: ViewController.magicPath)
                        DDYSoxTest().testTransform(srcURL, profile: 3, dstURL: dstURL)
                    } else {
                        self.recordButton.isEnabled = true
                        self.playButton.isEnabled = true
                        try? changedData?.write(to: URL(fileURLWithPath: ViewController.magicPath))
                    }
                }
            }
        }
    }
    
    @objc private func echoAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        sender.setTitle(sender.isSelected ? "回响[1]" : "回响[0]", for: .normal)
    }
}

