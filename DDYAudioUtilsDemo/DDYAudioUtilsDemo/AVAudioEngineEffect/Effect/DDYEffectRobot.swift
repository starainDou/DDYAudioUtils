//
//  DDYEffectRobot.swift
//  DDYAudioUtilsDemo
//
//  Created by ddy on 2022/12/20.
//

import AVFoundation

class DDYEffectRobot: DDYEffect {
    private(set) lazy var name = DDYEffectName.robot
    private(set) lazy var rate = 1.0
    private(set) lazy var audioUnits: [AVAudioUnit] = {
        let timePitchAU = AVAudioUnitTimePitch()
        timePitchAU.pitch = 100

        let reverbAU = AVAudioUnitReverb()
        reverbAU.loadFactoryPreset(.mediumChamber)
        reverbAU.wetDryMix = 5

        let distortionAU = AVAudioUnitDistortion()
        distortionAU.loadFactoryPreset(.speechGoldenPi)
        distortionAU.wetDryMix = 60
        
        let delayAU = AVAudioUnitDelay()
        delayAU.delayTime = 0.015 // seconds
        delayAU.lowPassCutoff = 17593 //Hz
        delayAU.feedback = 0.75 // Normalized Value 0 - 1
        delayAU.wetDryMix = 47 // Normalized Value 0 - 100
        
        return [timePitchAU, reverbAU, distortionAU, delayAU]
    }()
}

/**
 
 private(set) lazy var audioUnits: [AVAudioUnit] = {
     let reverbAU = AVAudioUnitReverb()
     reverbAU.loadFactoryPreset(.cathedral)
     
     let distortionAU = AVAudioUnitDistortion()
     distortionAU.loadFactoryPreset(.speechAlienChatter)
     distortionAU.wetDryMix = 10
     return [reverbAU, distortionAU]
 }()
 private(set) lazy var audioUnits: [AVAudioUnit] = {
     let timePitchAU = AVAudioUnitTimePitch()
     timePitchAU.rate = 1.0
     timePitchAU.pitch = 100
     
     let distortionAU = AVAudioUnitDistortion()
     distortionAU.loadFactoryPreset(.speechCosmicInterference)
     distortionAU.wetDryMix = 100
     return [timePitchAU, distortionAU]
 }()
 */
