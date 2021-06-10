//
//  File.swift
//  
//
//  Created by Morten Bertz on 2021/06/10.
//

import XCTest
import Accelerate
import AVFoundation
@testable import Tuna

final class YINTests: XCTestCase{
    
    let notes = try! [
        Note(letter: Note.Letter.C, octave: 4),
        Note(letter: Note.Letter.D, octave: 4),
        Note(letter: Note.Letter.E, octave: 4),
        Note(letter: Note.Letter.F, octave: 4),
        Note(letter: Note.Letter.G, octave: 4),
        Note(letter: Note.Letter.A, octave: 4),
        Note(letter: Note.Letter.B, octave: 4),
        Note(letter: Note.Letter.C, octave: 5),
    ]
    
    func testYIN(){
        
        let frequencies=notes.map {$0.frequency}
        
        let expectation = XCTestExpectation(description: "Pitch Engine")
        expectation.expectedFulfillmentCount = frequencies.count
        
        let signalTracker = SimulatorSignalTracker(frequencies: frequencies, delayMs: 500)
        let pitchEngine = PitchEngine(bufferSize: 4096, estimationStrategy: .yin, audioUrl: nil, signalTracker: signalTracker, delegate: nil, callback: {result in
            switch result{
            case .failure(let error):
                XCTFail(error.localizedDescription)
            case .success(let pitch):
                print(pitch.note)
                XCTAssert(self.notes.contains(pitch.note))
                expectation.fulfill()
            }
           
        })
        pitchEngine.start()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+10, execute: {
            pitchEngine.stop()
        })
        
        wait(for: [expectation], timeout: 10.0)
        
    }
    
    
    
    func waveForm(frequency:Float, samplingRate:Float = 22050, duration:Float = 100) throws ->[Float]{
        
        let duration:Float=100 //ms
        let n = Int(samplingRate / duration * 1000)
        let increment = 2 * Float.pi * Float(frequency) * ( 1 / samplingRate)
        
        let x=vDSP.ramp(withInitialValue: Float.zero, increment: increment, count: n)
        
        let y = [Float](unsafeUninitializedCapacity: n) { buffer, initializedCount in
            vForce.sin(x, result: &buffer)
            
            initializedCount = n
        }
        return y
    }
    
    func testYIN_waveform(){
        
        let samplingRate:Float=44100
        
        do{
            for note in self.notes{
                let y=try waveForm(frequency: Float(note.frequency), samplingRate: samplingRate)
                let buffer=Buffer(elements: y)
                let yin=YINEstimator()
                let outFreq = try yin.estimateFrequency(sampleRate: samplingRate, buffer: buffer)
                let outNote = try Note(frequency: Double(outFreq))
                XCTAssert(outNote == note)

            }
            
        }
        catch let error{
            XCTFail(error.localizedDescription)
        }
    
    }
    
}
