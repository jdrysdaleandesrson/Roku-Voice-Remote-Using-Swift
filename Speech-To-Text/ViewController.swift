//
//  ViewController.swift
//  Speech-To-Text
//
//  Created by Naren on 27/03/18.
//  Copyright © 2018 naren. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController,SFSpeechRecognizerDelegate {
  @IBOutlet weak var txtView: UITextView!
  @IBOutlet weak var btnStartRecording: UIButton!
  private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
  private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
  private var recognitionTask: SFSpeechRecognitionTask?
  private let audioEngine = AVAudioEngine()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    btnStartRecording.isEnabled = false
    speechRecognizer?.delegate = self
    userAutorization()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func userAutorization(){
    SFSpeechRecognizer.requestAuthorization { (authStatus) in
      var isButtonEnabled = false
      switch authStatus {
      case .authorized:
        isButtonEnabled = true
      case .denied:
        isButtonEnabled = false
        print("User denied access to speech recognition")
      case .restricted:
        isButtonEnabled = false
        print("Speech recognition restricted on this device")
      case .notDetermined:
        isButtonEnabled = false
        print("Speech recognition not yet authorized")
      }
      OperationQueue.main.addOperation() {
        self.btnStartRecording.isEnabled = isButtonEnabled
      }
    }
  }
  
  func startRecording() {
    if recognitionTask != nil {
      recognitionTask?.cancel()
      recognitionTask = nil
    }
    
    let audioSession = AVAudioSession.sharedInstance()
    do {
      try audioSession.setCategory(AVAudioSessionCategoryRecord)
      try audioSession.setMode(AVAudioSessionModeMeasurement)
      try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
    } catch {
      print("audioSession properties weren't set because of an error.")
    }
    
    recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
    
     let inputNode = audioEngine.inputNode
    
    guard let recognitionRequest = recognitionRequest else {
      fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
    }
    
    recognitionRequest.shouldReportPartialResults = true
    
      recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { [self] (result, error) in
      
      var isFinal = false
      
      if result != nil {
        
        //self.txtView.text = result?.bestTranscription.formattedString
        var text = result?.bestTranscription.formattedString
        self.txtView.text = text
        isFinal = (result?.isFinal)!
          if((text?.lowercased().contains("netlflix")) != nil){
              requestsNetflix()
              text = ""
          }
          if((text?.lowercased().contains("home")) != nil){
              requestsHome()
              text = ""
          }
          if((text?.lowercased().contains("prime")) != nil){
              requestsPrime()
              text = ""
          }
          if((text?.lowercased().contains("hulu")) != nil){
              requestsHulu()
              text = ""
          }
      }
      
      if error != nil || isFinal {
        self.audioEngine.stop()
        inputNode.removeTap(onBus: 0)
        
        self.recognitionRequest = nil
        self.recognitionTask = nil
        
        self.btnStartRecording.isEnabled = true
      }
    })
    
    let recordingFormat = inputNode.outputFormat(forBus: 0)
    inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
      self.recognitionRequest?.append(buffer)
    }
    
    audioEngine.prepare()
    
    do {
      try audioEngine.start()
    } catch {
      print("audioEngine couldn't start because of an error.")
    }
    
    txtView.text = "Say something, I'm listening!"
  }
  
  func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
    if available {
      btnStartRecording.isEnabled = true
    } else {
      btnStartRecording.isEnabled = false
    }
  }
  
  
  @IBAction func startRecordingFunc(_ sender: Any) {
    if audioEngine.isRunning {
      audioEngine.stop()
      recognitionRequest?.endAudio()
      btnStartRecording.isEnabled = false
      btnStartRecording.setTitle("Start Recording", for: .normal)
    } else {
      startRecording()
      btnStartRecording.setTitle("Stop Recording", for: .normal)
    }
  }
    func requestsHome() {
        let session = URLSession(configuration: .default)
        let url = URL(string:  "http://192.168.1.94:8060/keypress/home")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("text/plain", forHTTPHeaderField: "Content-Type") // I guess this can be "text/xml"
        // Working line
        request.httpBody = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><Commands><command type=\"open\"><name>environments/Animals.hwe</name><id>a1</id></command></Commands>".data(using: .utf8)
        let task = session.dataTask(with: request) { data, response, error in
                //    print(data as Any)
                //    print(response as Any)
                //    print(error as Any)
                // do something with the result
                print(data as Any? as Any)
                if let data = data {
                        print(String(data: data, encoding: .utf8)!)
                } else {
                        print("no data")
                }
        }
        task.resume()
    }
    
    func requestsNetflix() {
        let session = URLSession(configuration: .default)
        let url = URL(string:  "http://192.168.1.94:8060/launch/12")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("text/plain", forHTTPHeaderField: "Content-Type") // I guess this can be "text/xml"
        // Working line
        request.httpBody = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><Commands><command type=\"open\"><name>environments/Animals.hwe</name><id>a1</id></command></Commands>".data(using: .utf8)
        let task = session.dataTask(with: request) { data, response, error in
                //    print(data as Any)
                //    print(response as Any)
                //    print(error as Any)
                // do something with the result
                print(data as Any? as Any)
                if let data = data {
                        print(String(data: data, encoding: .utf8)!)
                } else {
                        print("no data")
                }
        }
        task.resume()
    }
    
    func requestsPrime() {
        let session = URLSession(configuration: .default)
        let url = URL(string:  "http://192.168.1.94:8060/launch/13")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("text/plain", forHTTPHeaderField: "Content-Type") // I guess this can be "text/xml"
        // Working line
        request.httpBody = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><Commands><command type=\"open\"><name>environments/Animals.hwe</name><id>a1</id></command></Commands>".data(using: .utf8)
        let task = session.dataTask(with: request) { data, response, error in
                //    print(data as Any)
                //    print(response as Any)
                //    print(error as Any)
                // do something with the result
                print(data as Any? as Any)
                if let data = data {
                        print(String(data: data, encoding: .utf8)!)
                } else {
                        print("no data")
                }
        }
        task.resume()
    }
    func requestsHulu() {
        let session = URLSession(configuration: .default)
        let url = URL(string:  "http://192.168.1.94:8060/launch/2285")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("text/plain", forHTTPHeaderField: "Content-Type") // I guess this can be "text/xml"
        // Working line
        request.httpBody = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><Commands><command type=\"open\"><name>environments/Animals.hwe</name><id>a1</id></command></Commands>".data(using: .utf8)
        let task = session.dataTask(with: request) { data, response, error in
                //    print(data as Any)
                //    print(response as Any)
                //    print(error as Any)
                // do something with the result
                print(data as Any? as Any)
                if let data = data {
                        print(String(data: data, encoding: .utf8)!)
                } else {
                        print("no data")
                }
        }
        task.resume()
    }

}

