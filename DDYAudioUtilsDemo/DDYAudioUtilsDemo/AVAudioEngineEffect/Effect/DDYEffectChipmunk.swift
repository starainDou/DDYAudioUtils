//
//  DDYEffectChipmunk.swift
//  DDYAudioUtilsDemo
//
//  Created by ddy on 2022/12/21.
//

import AVFoundation

class DDYEffectChipmunk: DDYEffect {
    private(set) lazy var name = DDYEffectFactory.EffectName.chipmunk
    private(set) lazy var rate = 1.0
    private(set) lazy var audioUnits: [AVAudioUnit] = {
        let timePitchAU = AVAudioUnitTimePitch()
        timePitchAU.pitch = 1300
        
        return [timePitchAU]
    }()
}
