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
    case slow, fast, alien, darthvader, shaokahn, jigsaw, chipmunk
    
    var effect: DDYEffect {
        switch self {
        case .slow: return DDYEffectSlow()
        case .fast: return DDYEffectFast()
        case .alien: return DDYEffectAlien()
        case .darthvader: return DDYEffectDarthvader()
        case .shaokahn: return DDYEffectShaokahn()
        case .jigsaw: return DDYEffectJigsaw()
        case .chipmunk: return DDYEffectChipmunk()
        }
    }
}
