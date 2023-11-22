//
//  VerSnapViewController.swift
//  Snapchat1
//
//  Created by Mac 17 on 9/06/22.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import SDWebImage
import AVFoundation


class VerSnapViewController: UIViewController {
    var reproducirAudio:AVPlayer?
    
    @IBOutlet weak var lblMensaje: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    var snap = Snap()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblMensaje.text = "Mensaje" + snap.descrip
        imageView.sd_setImage(with: URL(string: snap.imagenURL), completed: nil)
        print(snap.imagenURL)
    }
    
    @IBAction func reproducir(_ sender: Any) {
        guard let audioURL = URL(string: snap.audioURL) else {
            return
        }
        reproducirAudio = AVPlayer(url: audioURL)
        reproducirAudio?.play()
    }
    override func viewWillAppear(_ animated: Bool) {
        Database.database().reference().child("usuarios").child((Auth.auth().currentUser?.uid)!).child("snaps").child(snap.id).removeValue()
        
        Storage.storage().reference().child("imagenes").child("\(snap.imagenID).jgp").delete
          { (error) in
              print("Se elimino la imagen correctamente")
          }
    }
    
    func play(url:NSURL){
        print("playing \(url)")
        
        do{
            let player = try AVAudioPlayer(contentsOf: url as URL)
            player.prepareToPlay()
            player.play()
        }catch let error as NSError{
        }
        
    }
}
