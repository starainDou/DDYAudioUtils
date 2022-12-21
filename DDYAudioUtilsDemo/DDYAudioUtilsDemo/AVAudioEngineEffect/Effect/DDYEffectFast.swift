//
//  DDYEffectFast.swift
//  DDYAudioUtilsDemo
//
//  Created by ddy on 2022/12/20.
//

import AVFoundation

class DDYEffectFast: DDYEffect {
    private(set) lazy var name = DDYEffectName.fast
    private(set) lazy var rate = 2.0
    private(set) lazy var audioUnits: [AVAudioUnit] = {
        let timePitchAU = AVAudioUnitTimePitch()
        timePitchAU.rate = 2.0
        return [timePitchAU]
    }()
}
