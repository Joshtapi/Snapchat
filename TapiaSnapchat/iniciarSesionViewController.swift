//
//  ViewController.swift
//  TapiaSnapchat
//
//  Created by Joshua Tapia on 7/11/23.
//

import Firebase
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

class iniciarSesionViewController: UIViewController {

    
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBAction func iniciarSesionConGoogleTapped(_ sender: Any) {
        
    }
    
    
        

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //GIDSignIn.sharedInstance.signIn(withPresenting: self, hint: "")
        
        
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

