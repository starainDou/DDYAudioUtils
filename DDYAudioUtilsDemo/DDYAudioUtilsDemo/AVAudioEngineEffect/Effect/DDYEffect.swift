//
//  DDYEffect.swift
//  DDYAudioUtilsDemo
//
//  Created by ddy on 2022/12/20.
//

import AVFoundation

protocol DDYEffect {
    var name: DDYEffectFactory.EffectName { get }
    var rate: Double { get }
    var audioUnits: [AVAudioUnit] { get }
}
