//
//  DDYEffect.swift
//  DDYAudioUtilsDemo
//
//  Created by ddy on 2022/12/20.
//

import AVFoundation

protocol DDYEffect {
    var name: DDYEffectName { get }
    var rate: Double { get }
    var audioUnits: [AVAudioUnit] { get }
}


enum DDYEffectName: String, CaseIterable {
    case slow, fast, alien, robot, darthvader, shaokahn, jigsaw, chipmunk
    
    var effect: DDYEffect {
        switch self {
        case .slow: return DDYEffectSlow()
        case .fast: return DDYEffectFast()
        case .alien: return DDYEffectAlien()
        case .robot: return DDYEffectRobot()
        case .darthvader: return DDYEffectDarthvader()
        case .shaokahn: return DDYEffectShaokahn()
        case .jigsaw: return DDYEffectJigsaw()
        case .chipmunk: return DDYEffectChipmunk()
        }
    }
}

/**
 AVAudioUnitReverb 混响，混响可以模拟咱们在一个空旷的环境，比如教堂、大房间等，这样咱们在说话的时候，就会有回音，并且声音也比较有立体感
 AVAudioUnitEQ 均衡器，咱们可以使用均衡器来调节咱们音频的各个频段
 AVAudioUnitDistortion：失真，失真是可以把声音变得沙哑的效果器
 */
