//
//  ImagenViewController.swift
//  TapiaSnapchat
//
//  Created by Joshua Tapia on 14/11/23.
//

import UIKit
import FirebaseStorage

class ImagenViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    var imagePicker = UIImagePickerController()
    var imagenID = NSUUID().uuidString

    @IBAction func camaraTapped(_ sender: Any) {
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true,completion: nil)
    }
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descripcionTextField: UITextField!
    @IBOutlet weak var elegirContactoBoton: UIButton!
    @IBAction func elegirContactoTapped(_ sender: Any) {
        self.elegirContactoBoton.isEnabled = false
        
        // Referencia al folder de imágenes en Firebase Storage
        let imagenesFolder = Storage.storage().reference().child("imagenes")
        
        // Convertir la imagen a datos JPEG con cierta calidad
        guard let imagenData = imageView.image?.jpegData(compressionQuality: 0.50) else {
            // Manejo de error si la imagen no puede ser convertida a datos
            self.mostrarAlerta(titulo: "Error", mensaje: "No se pudo obtener la imagen.", accion: "Aceptar")
            self.elegirContactoBoton.isEnabled = true
            return
        }
        
        // Crear un nombre único para la imagen usando UUID
        let nombreImagen = "\(UUID().uuidString).jpg"
        let cargarImagen = imagenesFolder.child("\(imagenID).jpg)")
        
        // Subir la imagen a Firebase Storage
        cargarImagen.putData(imagenData, metadata: nil) { (metadata, error) in
            if let error = error {
                // Manejar el error si la carga falla
                self.mostrarAlerta(titulo: "Error", mensaje: "Ocurrió un error al subir la imagen. Verifique su conexión a internet y vuelva a intentarlo.", accion: "Aceptar")
                self.elegirContactoBoton.isEnabled = true
                print("Ocurrió un error al subir la imagen: \(error)")
                return
            } else {
                // Si la carga es exitosa, obtener la URL de descarga de la imagen
                cargarImagen.downloadURL { (url, error) in
                    if let error = error {
                        // Manejar el error si no se puede obtener la URL de descarga
                        self.mostrarAlerta(titulo: "Error", mensaje: "Ocurrió un error al obtener la información de la imagen.", accion: "Cancelar")
                        self.elegirContactoBoton.isEnabled = true
                        print("Ocurrió un error al obtener información de la imagen: \(error)")
                        return
                    }
                    // Si se obtiene la URL, realizar la transición a la siguiente vista
                    if let imageURL = url {
                        self.performSegue(withIdentifier: "seleccionarContactoSegue", sender: imageURL.absoluteString)
                    }
                }
            }
        }

            /*let alertaCarga = UIAlertController(title: "Cargando Imagen ...", message: "0%", preferredStyle: .alert)
            let progresoCarga = UIProgressView(progressViewStyle: .default)
            
            cargarImagen.observe(.progress) { (snapshot) in
                let porcentaje = Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
                print(porcentaje)
                progresoCarga.setProgress(Float(porcentaje), animated: true)
                progresoCarga.frame = CGRect(x: 10, y: 70, width: 250, height: 0)
                alertaCarga.message = "\(Int(round(porcentaje * 100)))%"
                
                if porcentaje >= 1.0 {
                    alertaCarga.dismiss(animated: true, completion: nil)
                }
            }
            
            let btnOK = UIAlertAction(title: "Aceptar", style: .default, handler: nil)
            alertaCarga.addAction(btnOK)
            alertaCarga.view.addSubview(progresoCarga)
            
            present(alertaCarga, animated: true, completion: nil)
             */
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        elegirContactoBoton.isEnabled = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let siguienteVC = segue.destination as! ElegirUsuarioViewController
        siguienteVC.imagenURL = sender as! String
        siguienteVC.descrip = descripcionTextField.text!
        siguienteVC.imagenID = imagenID
    }
    
    func mostrarAlerta(titulo: String, mensaje: String, accion: String) {
        let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        
        let btnCANCELOK = UIAlertAction(title: accion, style: .default, handler: nil)
        alerta.addAction(btnCANCELOK)
        
        present(alerta, animated: true, completion: nil)
    }

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            imageView.image = image
            imageView.backgroundColor = UIColor.clear
            elegirContactoBoton.isEnabled = true
            imagePicker.dismiss(animated: true, completion: nil)
        }
    }




    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


