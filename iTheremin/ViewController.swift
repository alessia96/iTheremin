//
//  ViewController.swift
//  iTheremim
//
//  Created by Peter Lloyd on 25/03/2017.
//  Copyright © 2017 Peter Lloyd. All rights reserved.
//


/// Libraries
import UIKit
import AVFoundation
import SwiftGifOrigin
import Alamofire
import SwiftyJSON

/// Global AVAudioPlayer
var backgroundPlayer: AVAudioPlayer?
var soundPlayer = [AVAudioPlayer]()

// Audio Controller Variable
var audio = AudioController(name: "note1")

/// Audio Controller
class AudioController {
    
    static var active: Bool = false
    
    
    /// init playBackgroundSound
    init(){
        playBackgroundSound()
    }
    
    
    /// Init playSound
    ///
    /// - Parameter name: String
    init(name: String){
        playSound(fileName: name)
    }
    
    
    /// playSound
    ///
    /// - Parameter fileName: String
    func playSound(fileName: String){

        do {
            if let bundle = Bundle.main.path(forResource: fileName, ofType: "wav") {
                let alertSound = NSURL(fileURLWithPath: bundle)
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
                try AVAudioSession.sharedInstance().setActive(true)
                let audioPlayer = try AVAudioPlayer(contentsOf: alertSound as URL)
                soundPlayer.append(audioPlayer)
                soundPlayer.last?.prepareToPlay()
                soundPlayer.last?.play()
            }
        } catch {
            print(error)
        }
    }
    
    /// playBackgroundSound
    func playBackgroundSound() {
        
        let url = Bundle.main.url(forResource: "background-synth", withExtension: "wav")!
        
        do {
            backgroundPlayer = try AVAudioPlayer(contentsOf: url)
            guard let player = backgroundPlayer else { return }
            
            player.enableRate = true
            player.rate = 1.0
            player.prepareToPlay()
            player.numberOfLoops = -1
            player.volume = 0.70
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

/// ViewController inherits UIViewController
class ViewController: UIViewController {

    
    /// Private Variables
    fileprivate var visage : Visage?
    fileprivate let notificationCenter : NotificationCenter = NotificationCenter.default
    
    /// Variables
    var motion: String?
    var dateTime: Date?
    var meteorActive: Bool = false
    var fireworkActive: Bool = false
    
    let emojiLabel : UILabel = UILabel(frame: UIScreen.main.bounds)
    
    
    /// IBOutlet
    /// - backgroundImage
    /// - meteor
    /// - firework
    @IBOutlet var backgroundImage: UIImageView!
    @IBOutlet var meteor: UIImageView!
    @IBOutlet var firework: UIImageView!
    
    
    /// viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = AudioController()
        
        getRate()
        
        let imageData = try! Data(contentsOf: Bundle.main.url(forResource: "background", withExtension: "gif")!)
        self.backgroundImage.image = UIImage.gif(data: imageData)
        
        dateTime = Date().addingTimeInterval(1.0)
        
        // Setup "Visage" with a camera-position
        visage = Visage(cameraPosition: Visage.CameraDevice.faceTimeCamera, optimizeFor: Visage.DetectorAccuracy.higherPerformance)
        
        // Continuous stream of notifications
        visage!.onlyFireNotificatonOnStatusChange = false
        
        
        // Starts face detection
        visage!.beginFaceDetection()
        
        // CameraView you can use to preview the image that is seen by the camera
        let cameraView = visage!.visageCameraView
        cameraView.alpha = 0.2
        self.view.addSubview(cameraView)

        
        // VisageFaceDetectedNotification
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "visageFaceDetectedNotification"), object: nil, queue: OperationQueue.main, using: { notification in
            
            UIView.animate(withDuration: 0.5, animations: {
                self.emojiLabel.alpha = 1
            })
      
            if self.dateTime! < Date() {
                self.dateTime = Date().addingTimeInterval(1.0)
                
                let audioTracksQuiet: [String] = ["1","2","3","4","5","6","7","8","9"]
                let audioTracksLoud: [String] = ["1","2","3","4","5","6","7","8","9","10","11"]
                
                let quietTracks: [String] = audioTracksQuiet.map { "note\($0)" }
                let loudTracks: [String] = audioTracksLoud.map { "hard-note\($0)" }
                
                
                let choice = Int(arc4random_uniform(UInt32(quietTracks.count)))
                let choice2 = Int(arc4random_uniform(UInt32(loudTracks.count)))
                
                // Plays firework sound
                if (self.visage!.isWinking) ?? false {
                    self.play(activeType: self.fireworkActive, image: self.firework, fileName: "firework")

                    
                    audio.playSound(fileName: quietTracks[choice])
                    
                    if self.motion != "wink" {
                        self.motion = "wink"
                    }
                    
                    // Plays meteor sound
                } else if (self.visage!.hasSmile) ?? false {
                    self.play(activeType: self.meteorActive, image: self.meteor, fileName: "meteor")
                    
                    audio.playSound(fileName: loudTracks[choice2])
                    
                    if self.motion != "smile" {
                        self.motion = "smile"
                    }
                }
            }
        })
        
        // When no face is detected things are reset
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "visageNoFaceDetectedNotification"), object: nil, queue: OperationQueue.main, using: { notification in
            
        })
    }
    
    /// viewDidAppear
    ///
    /// - Parameter animated: Bool
    override func viewDidAppear(_ animated: Bool) {
        play(activeType: meteorActive, image: meteor, fileName: "meteor")
    }
    
    
    /// didReceiveMemoryWarning
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    /// prefersStatusBarHidden: Bool
    override var prefersStatusBarHidden : Bool {
        return true
    }

    
    /// play
    ///
    /// - Parameters:
    ///   - activeType: Bool
    ///   - image: UIImageView
    ///   - fileName: String
    func play(activeType: Bool, image: UIImageView, fileName: String){
        if (!activeType){
            if activeType == meteorActive {
                meteorActive = true
            } else if activeType == fireworkActive {
                fireworkActive = true
            }
            UIView.animate(withDuration: 0.25, delay: 0.0, options: [], animations: {
                image.alpha = 1.0
                
            })
            
            let imageData2 = try! Data(contentsOf: Bundle.main.url(forResource: fileName, withExtension: "gif")!)
            image.image = UIImage.gif(data: imageData2)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                if activeType == self.meteorActive {
                    self.meteorActive = false
                } else if activeType == self.fireworkActive {
                    self.fireworkActive = false
                }
                UIView.animate(withDuration: 0.25, delay: 0.0, options: [], animations: {
                    image.alpha = 0.0
                })
            })
        }
    }
    
    
    /// getRate
    ///
    /// - Gets rate from leap motion
    /// - Sends amount of hands / fingers
    func getRate(){
        Alamofire.request("http://7a664141.ngrok.io/api/public/rate").responseJSON { response in
            switch response.result {
            case .success(_):
                let jsonData = JSON(response.data as Any)

                if let result = jsonData[0]["rate"].string {
                    backgroundPlayer?.rate = (Float(result)! * 2) - 1
                }
           
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                    self.getRate()
                })
                break
                
            case .failure(_):
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                    self.getRate()
                })
                break
                
            }
        }
    }

}

