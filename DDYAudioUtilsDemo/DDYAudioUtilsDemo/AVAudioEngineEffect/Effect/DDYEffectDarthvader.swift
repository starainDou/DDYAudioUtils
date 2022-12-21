//
//  DDYEffectDarthvader.swift
//  DDYAudioUtilsDemo
//
//  Created by ddy on 2022/12/21.
//

import AVFoundation

class DDYEffectDarthvader: DDYEffect {
    private(set) lazy var name = DDYEffectFactory.EffectName.darthvader
    private(set) lazy var rate = 1.0
    private(set) lazy var audioUnits: [AVAudioUnit] = {
        let timePitchAU = AVAudioUnitTimePitch()
        timePitchAU.rate = 1.0
        timePitchAU.pitch = -1200
        return [timePitchAU]
    }()
}