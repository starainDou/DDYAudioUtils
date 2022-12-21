//
//  ViewController.swift
//  DDYAudioUtilsDemo
//
//  Created by doudianyu on 2022/1/27.
//

import UIKit
import AVFoundation


class ViewController: UIViewController {
    
    private lazy var mp3Button: UIButton = btn(title: "Mp3", y: 100, action: #selector(mp3Action(_:)))
    
    private lazy var amrButton: UIButton = btn(title: "Amr", y: 150, action: #selector(amrAction(_:)))
    
    private lazy var cafButton: UIButton = btn(title: "Caf", y: 200, action: #selector(cafAction(_:)))
    
    private lazy var changeButton: UIButton = btn(title: "变声", y: 250, action: #selector(changeAction(_:)))
    
    private lazy var audioUnitButton: UIButton = btn(title: "AVAudioUnit", y: 300, action: #selector(audioUnitAction(_:)))
    
    private func btn(title: String, y: CGFloat, action: Selector) -> UIButton {
        return UIButton(type: .custom).ddy_then {
            $0.frame = CGRect(x: 20, y: y, width: UIScreen.main.bounds.width - 40, height: 40)
            $0.setTitle(title, for: .normal)
            $0.setTitleColor(.red, for: .normal)
            $0.backgroundColor = .lightGray
            $0.addTarget(self, action: action, for: .touchUpInside)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Home"
        view.backgroundColor = .white
        ViewController.tryCreate(path: ViewController.voicePath)
        view.addSubview(mp3Button)
        view.addSubview(amrButton)
        view.addSubview(cafButton)
        view.addSubview(changeButton)
        view.addSubview(audioUnitButton)
    }
    @objc private func mp3Action(_ sender: UIButton) {
        navigationController?.pushViewController(DDYMp3ViewController(), animated: true)
    }
    @objc private func amrAction(_ sender: UIButton) {
        navigationController?.pushViewController(DDYAmrViewController(), animated: true)
    }
    @objc private func cafAction(_ sender: UIButton) {
        navigationController?.pushViewController(DDYCafViewController(), animated: true)
    }
    @objc private func changeAction(_ sender: UIButton) {
        navigationController?.pushViewController(DDYAudioChangeViewController(), animated: true)
    }
    
    @objc private func audioUnitAction(_ sender: UIButton) {
        navigationController?.pushViewController(DDYAudioUnitVC(), animated: true)
    }
}

extension ViewController {
    static let voicePath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/PersonVoice/"
    static let cafPath: String = ViewController.voicePath + "record.caf"
    static let mp3Path: String = ViewController.voicePath + "record.mp3"
    static let amrPath: String = ViewController.voicePath + "record.amr"
    static let wavPath: String = ViewController.voicePath + "record.wav"
    static let tempPath: String = ViewController.voicePath + "temp.wav"
    static let magicPath: String = ViewController.voicePath + "magic.wav"
    static let m4aPath: String = ViewController.voicePath + "record.m4a"
    
    /// 尝试创建
    static func tryCreate(path: String) {
        if !FileManager.default.fileExists(atPath: path) {
            let attributes: [FileAttributeKey: Any] = [.posixPermissions: 0o777]
            try? FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: attributes)
        }
    }
}

