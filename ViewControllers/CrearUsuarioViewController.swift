
import UIKit
import FirebaseCore
import FirebaseDatabase
import FirebaseAuth

class CrearUsuarioViewController: UIViewController {

    @IBOutlet weak var EmailUsuarioText: UITextField!
    
    @IBOutlet weak var passwordUserText: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

    @IBAction func crearUsuarioTapped(_ sender: Any) {
        Auth.auth().createUser(withEmail: self.EmailUsuarioText.text! , password: self.passwordUserText.text!, completion: {(user, error) in print("Intentando crear un usuario")
                if error != nil {
                    print("Se presento el siguiente error al crear el usuario: \(error) ")
                }else{
                    print("El usuario fue creado exitosamente")
                    
                    Database.database().reference().child("usuarios").child(user!.user.uid).child("email").setValue(user!.user.email)
                    
                    let alerta = UIAlertController(title: "Creación de Usuario ", message: "Usuario: \(self.EmailUsuarioText.text!) se creo correctamente" , preferredStyle: .alert)
                    let btnOk = UIAlertAction(title: "Aceptar", style: .default, handler: { (UIAlertAction) in self.performSegue(withIdentifier: "1Segue", sender: nil)
                    })
                    alerta.addAction(btnOk)
                    self.present(alerta, animated: true, completion: nil)
                    
                }
              }

        )}
}
