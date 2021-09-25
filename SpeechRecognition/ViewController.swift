//
//  ViewController.swift
//  SpeechRecognition
//
//  Created by Yush Raj Kapoor on 9/24/21.
//

import UIKit
import Speech

class ViewController: UIViewController, SFSpeechRecognizerDelegate {

    var talk:speechModule?
    
    /*
     Requires info.plist permission!!!
     Privacy - Microphone Usage Description
     Privacy - Speech Recognition Usage Description
    */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let label = UILabel(frame: CGRect(x: 20, y: 90, width: UIScreen.main.bounds.width - 40, height: UIScreen.main.bounds.height - 180))
        label.numberOfLines = 0
        label.minimumScaleFactor = 0.1
        label.adjustsFontSizeToFitWidth = true
        label.lineBreakMode = .byTruncatingHead
        
        let button = UIButton(frame: CGRect(x: 20, y: 50, width: 250, height: 25))
        button.center.x = view.center.x
        button.setTitle("Start Speech Recognition", for: .normal)
        button.layer.cornerRadius = 7
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.label.cgColor
        button.addAction(UIAction(handler: {_ in
            self.startSpeech(l: label)
        }), for: .touchUpInside)
        
        view.addSubview(button)
        view.addSubview(label)
        
        talk = speechModule()
        
        startSpeech(l: label)
        

    }

    //when done:  talk?.stopRecording()
    
    func clear() {
        print("Clear!")
    }
    
    func stop() {
        print("Stop!")
    }
    
    
    @objc func startSpeech(l:UILabel) {
        if !(talk?.isActive())! {
            talk?.stop = false
            let d = ["clear":clear, "done":stop]
            talk?.startRecording(lbl: l, funcs: d)
        }
    }
  
}

