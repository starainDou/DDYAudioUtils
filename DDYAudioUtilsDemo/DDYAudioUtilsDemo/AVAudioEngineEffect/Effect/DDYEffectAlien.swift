//
//  DDYEffectAlien.swift
//  DDYAudioUtilsDemo
//
//  Created by ddy on 2022/12/20.
//

import AVFoundation

class DDYEffectAlien: DDYEffect {
    private(set) lazy var name = DDYEffectFactory.EffectName.alien
    private(set) lazy var rate = 1.0
    private(set) lazy var audioUnits: [AVAudioUnit] = {
        let timePitchAU = AVAudioUnitTimePitch()
        timePitchAU.rate = 1.0
        timePitchAU.pitch = 100
        
        let distortionAU = AVAudioUnitDistortion()
        distortionAU.loadFactoryPreset(.speechCosmicInterference)
        distortionAU.wetDryMix = 100
        return [timePitchAU, distortionAU]
    }()
}