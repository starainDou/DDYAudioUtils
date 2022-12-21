//
//  DDYEffectFactory.swift
//  DDYAudioUtilsDemo
//
//  Created by ddy on 2022/12/20.
//

import Foundation


class DDYEffectFactory {
    enum EffectName: CaseIterable {
        case slow, fast, alien, darthvader, shaokahn, jigsaw, chipmunk
    }
    // 单例
    private init() {}
    static let shared = DDYEffectFactory()
    
    func effect(forName effectName: DDYEffectFactory.EffectName) -> DDYEffect {
        switch effectName {
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
