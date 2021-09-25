//
//  speechModule.swift
//  SpeechRecognition
//
//  Created by Yush Raj Kapoor on 9/24/21.
//

import Foundation
import UIKit
import Speech

class speechModule:NSObject {
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    var label:UILabel?
    var cache:String?
    var stop = false
    
    private var functionArray: [String:() -> Void]?
    
    /*
    Create variables to pass functions or UIElements here
    */
    
    override init() {
        super.init()
    }
    
    func startRecording(lbl:UILabel, funcs:[String: () -> Void]) {
        print("Speech Recognition Started")
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        label = lbl
        functionArray = funcs
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { [self] (result, error) in
            
            var isFinal = false
            
            //HANDLE SPEECH RESULT HERE
            if result != nil {
                let spokenContent = result?.bestTranscription.formattedString.lowercased()
                let split = spokenContent?.split(separator: " ")
                let str:[String.SubSequence] = "\(cache ?? "") \(spokenContent ?? "")".split(separator: " ")
                    
                let new = str[(str.lastIndex(of: "clear") ?? str.startIndex)..<str.endIndex]
                
                label!.text = new.joined(separator: " ")
                
                
                switch split?.last {
                case "stop":
                    stop = true
                    stopRecording()
                    funcs["done"]!()
                    break
                case "clear":
                    funcs["clear"]!()
                    break
                default:
                    break
                }
                
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 1)
                self.recognitionRequest = nil
                self.recognitionTask = nil
                cache = "\(cache ?? "") \(result?.bestTranscription.formattedString.lowercased() ?? "")"
                print("Speech Recognition Stopped")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: { [self] in
                    if !self.isActive() && !stop {
                        print("Speech Recognition Activated again")
                        startRecording(lbl: label!, funcs: functionArray!)
                    }
                })
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 1)
        
        inputNode.installTap(onBus: 1, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
    }
    
    func stopRecording() {
        pause()
        print("audioEngine stopped")
    }
    
    func pause() {
        print("talk pause")
        cache = ""
        audioEngine.inputNode.removeTap(onBus: 1)
        recognitionRequest?.endAudio()
        self.recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
        audioEngine.stop()
    }
    
    func play() {
        print("talk play")
        startRecording(lbl: label!, funcs: functionArray!)
    }
    
    func isActive() -> Bool {
        return audioEngine.isRunning
    }
    
    
    deinit {
        stopRecording()
    }
    
    
    
}
