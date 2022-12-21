//
//  DDYEffectSlow.swift
//  DDYAudioUtilsDemo
//
//  Created by ddy on 2022/12/20.
//

import AVFoundation

class DDYEffectSlow: DDYEffect {
    private(set) lazy var name = DDYEffectName.slow
    private(set) lazy var rate = 0.5
    private(set) lazy var audioUnits: [AVAudioUnit] = {
        let timePitchAU = AVAudioUnitTimePitch()
        timePitchAU.rate = 0.5
        return [timePitchAU]
    }()
}
