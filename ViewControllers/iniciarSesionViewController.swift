//
//  ViewController.swift
//  TapiaSnapchat
//
//  Created by Joshua Tapia on 7/11/23.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import FirebaseDatabase


class iniciarSesionViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var password: UITextField!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func iniciarSesionTapped(_ sender: Any ) {
        Auth.auth().signIn(withEmail: emailTextField.text!, password: password.text!){
             (user, error) in print("intentando iniciar sesión")
            if error != nil {
                print("Se presento el siguiente error: \(error)")
                
                let alert = UIAlertController(title: "Se encontro un error", message: "Usuario \(self.emailTextField.text!) incorrecto, cree uno o intentelo de nuevo", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Crear", style: .default, handler: { (action) in
                    self.performSegue(withIdentifier: "crearUsuarioSegue", sender: nil)
                }))
                
                alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: { (action) in
                    
                }))
                
                self.present(alert, animated: true, completion: nil)
                
            }else{
                print("Inicio de sesion exitoso")
                
                let alerta = UIAlertController(title: "Inició sesión de forma exitosa", message: "Usuario: \(self.emailTextField.text!) accedió correctamente" , preferredStyle: .alert)
                let btnOk = UIAlertAction(title: "Aceptar", style: .default, handler: { (UIAlertAction) in self.performSegue(withIdentifier: "iniciarsesionsegue", sender: nil)
                })
                alerta.addAction(btnOk)
                self.present(alerta, animated: true, completion: nil)
                
         
                    
                }
            
            
            
        }
    }
    
    
    @IBAction func login(_ sender: Any) {
        
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
          guard error == nil else {
            // ...
              return
          }

          guard let user = result?.user,
            let idToken = user.idToken?.tokenString
          else {
            // ...
              return
          }

          let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: user.accessToken.tokenString)

          // ...
            Auth.auth().signIn(with: credential) { result, error in
                if let error = error {
                    print("Error al iniciar sesión: \(error.localizedDescription)")
                } else {
                    print("Inicio de sesión exitoso")
                    // Aquí puedes realizar cualquier otra acción que necesites después de un inicio de sesión exitoso
                }
            }

        }
    }
    
}

