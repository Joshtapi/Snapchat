//
//  ElegirUsuarioViewController.swift
//  TapiaSnapchat
//
//  Created by Joshua Tapia on 14/11/23.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class ElegirUsuarioViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var listaUsuarios: UITableView!
    var usuarios: [Usuario] = []
    var imagenURL = " "
    var descrip = " "
    var imagenID = " "
    var audioURL = " "
    var audioID = " "
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listaUsuarios.delegate = self
        listaUsuarios.dataSource = self
        Database.database().reference().child("usuarios").observe(DataEventType.childAdded, with: {(snapshot) in
            print(snapshot)
            let usuario = Usuario()
            usuario.email = (snapshot.value as! NSDictionary)["email"] as! String
            usuario.uid = snapshot.key
            self.usuarios.append(usuario)
            self.listaUsuarios.reloadData()
        })
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usuarios.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let usuario = usuarios[indexPath.row]
        cell.textLabel?.text = usuario.email
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let usuario = usuarios[indexPath.row]
        
        let snap = [
            "from": Auth.auth().currentUser?.email,
            "descripcion": descrip,
            "imagenURL": imagenURL,
            "imagenID": imagenID,
            "audioURL": audioURL,   // Agrega el audioURL al diccionario del snap
            "audioID": audioID      // Agrega el audioID al diccionario del snap
        ]
        
        Database.database().reference().child("usuarios").child(usuario.uid).child("snaps").childByAutoId().setValue(snap)
        
        // Sube el archivo de audio a Firebase Storage
        let audioRef = Storage.storage().reference().child("audios").child("\(audioID).m4a")
        let audioData = Data() // Aquí debes proporcionar los datos del audio a subir
        let metadata = StorageMetadata()
        metadata.contentType = "audio/m4a"
        
        audioRef.putData(audioData, metadata: metadata) { (metadata, error) in
            if let error = error {
                // Error al subir el audio
                print("Error al subir el audio: \(error.localizedDescription)")
            } else {
                // El audio se ha subido correctamente
                print("Audio subido exitosamente.")
            }
        }
        
        navigationController?.popViewController(animated: true)
    }
}
