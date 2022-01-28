//
//  ViewController.swift
//  DDYAudioUtilsDemo
//
//  Created by doudianyu on 2022/1/27.
//

import UIKit
import DDYAudioUtils

class ViewController: UIViewController, AVAudioPlayerDelegate {

    private lazy var recorder: DDYAudioRecorder = DDYAudioRecorder().ddy_then {
        $0.fileWriterDelegate = mp3Writer
    }
    
    private lazy var cafWriter: DDYCafRecordWriter = DDYCafRecordWriter().ddy_then {
        $0.filePath = ViewController.cafPath
    }
    private lazy var mp3Writer: DDYMp3RecordWriter = DDYMp3RecordWriter().ddy_then {
        $0.maxSecondCount = 120
        $0.filePath = ViewController.mp3Path
    }
    private lazy var amrWriter: DDYAmrRecordWriter = DDYAmrRecordWriter().ddy_then {
        $0.maxSecondCount = 120
        $0.maxFileSize = 1024 * 256 * 100
        $0.filePath = ViewController.amrPath
    }
    
    private lazy var meterObserver: DDYAudioMeterObserver = DDYAudioMeterObserver()
    
    private lazy var recordButton: UIButton = btn(title: "开始录制", y: 100, action: #selector(recordAction(_:)))
    
    private lazy var playButton: UIButton = btn(title: "播放录音", y: 150, action: #selector(playAction(_:)))
    
    private var player: AVAudioPlayer?
    
    private var amrPlayer: DDYAmrPlayer?
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ViewController.tryCreate(path: ViewController.voicePath)
        view.addSubview(recordButton)
        view.addSubview(playButton)
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] isGranted in
            DispatchQueue.main.async {
                self?.recordButton.isHidden = !isGranted
            }
        }
    }
    /// 其他配置
    private func config() {
        meterObserver.audioQueue = recorder.audioQueue;
        meterObserver.actionBlock = { (levelMeterStates, meterObserver) in
            print("valume:\(DDYAudioMeterObserver.volume(forLevelMeterStates: levelMeterStates))")
        }
        meterObserver.errorBlock = { (error, meterObserver) in
            if let tempError = error {
                print("error:\(tempError)")
            }
        }
        recorder.receiveStoppedBlock = { [weak self] in
            self?.meterObserver.audioQueue = nil
        }
        recorder.receiveErrorBlock = {  [weak self] (error) in
            if let tempError = error {
                self?.meterObserver.audioQueue = nil
                print("error:\(tempError)")
            }
        }
    }
    
    @objc private func recordAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        sender.setTitle(sender.isSelected ? "停止录制" : "开始录制", for: .normal)
        playButton.isHidden = sender.isSelected
        if sender.isSelected {
            recorder.startRecording()
            config()
        } else {
            recorder.stopRecording()
        }
    }
    
    @objc private func playAction(_ sender: UIButton) {
        if changePlayState() {
            if FileManager.default.fileExists(atPath: ViewController.mp3Path) {
                try? AVAudioSession.sharedInstance().setCategory(.playback)
                player = try? AVAudioPlayer(contentsOf: URL(fileURLWithPath: ViewController.mp3Path))
                player?.numberOfLoops = 1
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
            }
//            try? AVAudioSession.sharedInstance().setCategory(.playback)
//            amrPlayer = DDYAmrPlayer(fileName: ViewController.amrPath)
//            amrPlayer?.play()
            
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
}

extension ViewController {
    static let voicePath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/PersonVoice/"
    static let cafPath: String = ViewController.voicePath + "record.caf"
    static let mp3Path: String = ViewController.voicePath + "record.mp3"
    static let amrPath: String = ViewController.voicePath + "record.amr"
    
    /// 尝试创建
    static func tryCreate(path: String) {
        if !FileManager.default.fileExists(atPath: path) {
            let attributes: [FileAttributeKey: Any] = [.posixPermissions: 0o777]
            try? FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: attributes)
        }
    }
}

