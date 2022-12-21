//
//  DDYEffectShaokahn.swift
//  DDYAudioUtilsDemo
//
//  Created by ddy on 2022/12/21.
//

import AVFoundation

class DDYEffectShaokahn: DDYEffect {
    private(set) lazy var name = DDYEffectName.shaokahn
    private(set) lazy var rate = 1.0
    private(set) lazy var audioUnits: [AVAudioUnit] = {
        let distortionAU = AVAudioUnitDistortion()
        distortionAU.loadFactoryPreset(.speechWaves)
        distortionAU.wetDryMix = 10
        
        let timePitchAU = AVAudioUnitTimePitch()
        timePitchAU.pitch = -400
        
        let reverbAU = AVAudioUnitReverb()
        reverbAU.loadFactoryPreset(.mediumHall3)
        reverbAU.wetDryMix = 20
        
        return [distortionAU, timePitchAU, reverbAU]
    }()
}
