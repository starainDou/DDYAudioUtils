//
//  DDYEffectJigsaw.swift
//  DDYAudioUtilsDemo
//
//  Created by ddy on 2022/12/21.
//

import AVFoundation

class DDYEffectJigsaw: DDYEffect {
    private(set) lazy var name = DDYEffectFactory.EffectName.jigsaw
    private(set) lazy var rate = 1.0
    private(set) lazy var audioUnits: [AVAudioUnit] = {
        let distortionAU = AVAudioUnitDistortion()
        distortionAU.loadFactoryPreset(.speechWaves)
        distortionAU.wetDryMix = 20
        
        let timePitchAU = AVAudioUnitTimePitch()
        timePitchAU.pitch = -300
        
        return [distortionAU, timePitchAU]
    }()
}
