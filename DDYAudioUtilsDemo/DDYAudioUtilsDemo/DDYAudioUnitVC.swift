//
//  DDYAudioChangeViewController.swift
//  DDYAudioUtilsDemo
//
//  Created by doudianyu on 2022/1/29.
//

import UIKit
import AVFoundation
import DDYAudioUtils

class DDYAudioUnitVC: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    private lazy var recordButton: UIButton = btn(title: "开始录制", y: 100, action: #selector(recordAction(_:)))
    
    /// 菜单集合视图
    private lazy var collectionView: UICollectionView = {
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        flowLayout.itemSize = CGSize(width: (UIScreen.main.bounds.width - 60.0) / 3.0, height: 40)
        
        let frame = CGRect(x: 0, y: 150, width: UIScreen.main.bounds.width, height: 160)
        let collectionView = UICollectionView(frame: frame, collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.bounces = false
        collectionView.isScrollEnabled = true
        collectionView.showsHorizontalScrollIndicator  = false
        collectionView.backgroundColor = .white
        collectionView.register(InnerCell.self, forCellWithReuseIdentifier: "InnerCell")
        collectionView.isHidden = true
        return collectionView;
    }()
    
    private lazy var dataArray: [DDYEffectName] = DDYEffectName.allCases
    /// 录音器
    private var recorder: AVAudioRecorder?
    /// 变声播放器
    private var audioProcessor: DDYAudioProcessor?
    
    private let recordSetting: [String: Any] = [AVFormatIDKey : kAudioFormatMPEG4AAC]
    
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
        navigationItem.title = "AVAudioUnitEffect"
        view.backgroundColor = .white
        view.addSubview(recordButton)
        view.addSubview(collectionView)
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] isGranted in
            DispatchQueue.main.async {
                self?.recordButton.isHidden = !isGranted
            }
        }
    }
    
    @objc private func recordAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        sender.setTitle(sender.isSelected ? "停止录制" : "开始录制", for: .normal)
        if let oldProcessor = audioProcessor {
            oldProcessor.stop()
        }
        if sender.isSelected {
            collectionView.isHidden = true
            try? AVAudioSession.sharedInstance().setCategory(.playAndRecord)
            try? AVAudioSession.sharedInstance().setActive(true)
            recorder = try? AVAudioRecorder(url: URL(fileURLWithPath: ViewController.m4aPath), settings: recordSetting)
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
            audioProcessor = try? DDYAudioProcessor(with: URL(fileURLWithPath: ViewController.m4aPath))
            collectionView.isHidden = false
        }
    }
}

extension DDYAudioUnitVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InnerCell", for: indexPath) as! InnerCell
        cell.loadData(dataArray[indexPath.row].rawValue)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        audioProcessor?.play(with: dataArray[indexPath.row].effect)
    }
}

// MARK: - 内部cell
private class InnerCell: UICollectionViewCell {
    
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.blue
        label.textAlignment = .center
        label.backgroundColor = UIColor.lightGray
        return label
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(textLabel)
        setupViewsConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /// 布局约束
    private func setupViewsConstraints() {
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        textLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 10).isActive = true
        textLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        textLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 10).isActive = true
    }
    /// 外部传入数据
    func loadData(_ title: String) {
        textLabel.text = title
    }
}
