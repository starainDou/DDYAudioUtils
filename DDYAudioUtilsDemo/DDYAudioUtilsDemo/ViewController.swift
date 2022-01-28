//
//  ViewController.swift
//  DDYAudioUtilsDemo
//
//  Created by doudianyu on 2022/1/27.
//

import UIKit


class ViewController: UIViewController {
    
    private lazy var mp3Button: UIButton = btn(title: "Mp3", y: 100, action: #selector(mp3Action(_:)))
    
    private lazy var amrButton: UIButton = btn(title: "Amr", y: 150, action: #selector(amrAction(_:)))
    
    private lazy var cafButton: UIButton = btn(title: "Caf", y: 200, action: #selector(cafAction(_:)))
    
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

