//
//  YINEstimator.swift
//  Beethoven
//
//  Created by Guillaume Laurent on 18/10/16.
//  Copyright © 2016 Vadym Markov. All rights reserved.
//

import Foundation

public struct YINEstimator: Estimator {

    let transformer: Transformer = YINTransformer()
    let threshold: Float = 0.05

    public init(){}
    
    
    public func estimateFrequency(sampleRate: Float, buffer: [Float]) throws -> Float{
        let diffElements = YINUtil.differenceA(buffer: buffer)
        let b=Buffer(elements: diffElements)
        return try estimateFrequency(sampleRate: sampleRate, buffer: b)
        
    }
    
    func estimateFrequency(sampleRate: Float, buffer: Buffer) throws -> Float {
        var elements = buffer.elements

        YINUtil.cumulativeDifference(yinBuffer: &elements)

        let tau = YINUtil.absoluteThreshold(yinBuffer: elements, withThreshold: threshold)
        let f0: Float

        if tau != 0 {
            let interpolatedTau = YINUtil.parabolicInterpolation(yinBuffer: elements, tau: tau)
            f0 = sampleRate / interpolatedTau
        } else {
            f0 = 0.0
        }

        return f0
    }

}
