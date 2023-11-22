//
//  ImagenViewController.swift
//  TapiaSnapchat
//
//  Created by Joshua Tapia on 14/11/23.
//

import UIKit
import FirebaseStorage
import AVFoundation
import CloudKit

class ImagenViewController: UIViewController, UIImagePickerControllerDelegate,  UINavigationControllerDelegate {
    
    var imagePicker = UIImagePickerController()
    
    var imagenID = NSUUID().uuidString
    var audioID = NSUUID().uuidString
    var grabarAudio:AVAudioRecorder?
    var reproducirAudio:AVAudioPlayer?
    var audioURL:URL?
    var enviados:[String] = []
    
    
    @IBOutlet weak var grabarButton: UIButton!
    
    @IBOutlet weak var reproducirButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var Nombretextfild: UITextField!
    @IBOutlet weak var descripcionTextField: UITextField!
    
    @IBOutlet weak var elegirContactoBoton: UIButton!
    func configurarGrabacion(){
        do{
                    let session = AVAudioSession.sharedInstance()
                    try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: [])
                    try session.overrideOutputAudioPort(.speaker)
                    try session.setActive(true)
                    
                    let basePath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
                    let pathComponents = [basePath,"audio.m4a"]
                    audioURL = NSURL.fileURL(withPathComponents: pathComponents)!
                    
                    print("************")
                    print(audioURL!)
                    print("************")
                    
                    var setting:[String:AnyObject] = [:]
                    setting[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
                    setting[AVSampleRateKey] = 44100.0 as AnyObject?
                    setting[AVNumberOfChannelsKey] = 2 as AnyObject?
                    
                    grabarAudio = try AVAudioRecorder(url: audioURL!, settings: setting)
                    grabarAudio!.prepareToRecord()
                }catch let error as NSError{
                    print(error)
                }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        elegirContactoBoton.isEnabled = false
        configurarGrabacion()
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image =  info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        imageView.image = image
        imageView.backgroundColor = UIColor.clear
        elegirContactoBoton.isEnabled = true
        imagePicker.dismiss(animated: true,completion: nil )
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let siguienteVC = segue.destination as? ElegirUsuarioViewController,
           let senderArray = sender as? [Any],
           let audioURL = senderArray[0] as? String,
           let imagenURL = senderArray[1] as? String {
            siguienteVC.imagenURL = imagenURL
            siguienteVC.audioURL = audioURL
            siguienteVC.descrip = descripcionTextField.text!
            siguienteVC.imagenID = imagenID
            siguienteVC.audioID = audioID
        }
    }

    
    func mostrarAlerta(titulo: String, mensaje: String , accion: String){
        let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        let btnCANCELOK = UIAlertAction(title: accion, style: .default,handler: nil)
        alerta.addAction(btnCANCELOK)
        present(alerta, animated: true, completion: nil)
    }
    
    @IBAction func camaraTapped(_ sender: Any) {
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func grabarTapped(_ sender: Any) {
        if grabarAudio!.isRecording{
            grabarAudio?.stop()
            grabarButton.setTitle("GRABAR", for: .normal)
        }else{
            grabarAudio?.record()
            grabarButton.setTitle("DETENER", for: .normal)
        
        }
    }
    
    @IBAction func reproducirTapped(_ sender: Any) {
        do{
            try reproducirAudio = AVAudioPlayer(contentsOf: self.audioURL!)
            reproducirAudio?.play()
            print("Reproduciendo")
        }catch{}
    }
    @IBAction func elegirContactoTapped(_ sender: Any) {
        self.elegirContactoBoton.isEnabled = false
        guard let data = try? Data(contentsOf:audioURL!) else { return }
                let audioFolder = Storage.storage().reference().child("audio")
                let cargarAudio = audioFolder.child("\(NSUUID().uuidString).m4a")
                cargarAudio.putData(data,metadata: nil){
                    (metadata,error) in
                    if error != nil{
                        self.mostrarAlerta(titulo: "Error", mensaje: "Se produo un error al subir la imagen. Verifique su conexion a internet y vuelva a intentarlo", accion: "Aceptar")
                        print("Ocurrio un error al subir la image: \(error)")
                    }else{
                        cargarAudio.downloadURL(completion: {(url2, error) in guard let enlaceURL2 = url2 else{
                            self.mostrarAlerta(titulo: "Error", mensaje: "Se produjo un error al obtener informacion de imagen", accion: "Cancelar")
                            self.elegirContactoBoton.isEnabled = true
                            print("Ocurrio un error al obtener informacion de imagen \(error)")
                            return
                        }
                            self.enviados.append(url2!.absoluteString)
                            //print("eeeeeeeeeeeeeeeeeeeee")
                            //print(self.enviados[0])
                    })
                    }
                }
               let imagenesFolder = Storage.storage().reference().child("imagenes")
               let imagenData = imageView.image?.jpegData(compressionQuality: 0.50)
               let cargarImagen = imagenesFolder.child("\(imagenID).jpg")
                   cargarImagen.putData(imagenData!, metadata: nil) { (metadata, error ) in
                   if error != nil {
                       self.mostrarAlerta(titulo: "Error", mensaje: "Se produjo un error al subir la imagen verifica tu internet", accion: "Aceptar")
                       self.elegirContactoBoton.isEnabled = true
                       print("A ocurrido un error al subir la imagen: \(error)")
                       return
                   }else{
                       cargarImagen.downloadURL(completion: { (url ,error) in
                           guard let enlaceURL = url else{
                               self.mostrarAlerta(titulo: "error", mensaje: "se produjo un error al obtener informacion de la imagen.", accion: "Cancelar")
                               self.elegirContactoBoton.isEnabled = true
                               print("Ocurrio un error al obtener informacion de la imagen \(error)")
                               return
                           }
                           self.enviados.append(url!.absoluteString)
                           //print(self.enviados[0])
                           self.performSegue(withIdentifier: "seleccionarContactoSegue", sender: self.enviados)
                       })
                   }
           }
    }
      /*  let alertaCarga = UIAlertController(title: "Cargando imagen ...", message: "0%", preferredStyle: .alert)
                let progresocCarga: UIProgressView = UIProgressView(progressViewStyle: .default)
                cargarImagen.observe(.progress) {(snapshot) in
                    let porcentaje = Double(snapshot.progress!.completedUnitCount)
                    / Double(snapshot.progress!.totalUnitCount)
                    print(porcentaje)
                    progresocCarga.setProgress(Float(porcentaje), animated: true)
                    progresocCarga.frame = CGRect(x: 10, y: 70, width: 250, height: 0)
                    alertaCarga.message = String(round(porcentaje*100.0)) + "%"
                    if porcentaje>=1.0 {
                        alertaCarga.dismiss(animated: true, completion: nil )
                    }
                }
        let btnOK = UIAlertAction( title: "Aceptar", style: .default, handler: nil)
                alertaCarga.addAction(btnOK)
                alertaCarga.view.addSubview(progresocCarga)
                present(alertaCarga, animated: true, completion: nil)
                
            }
}*/


}
