import UIKit

class SignUpViewController: UIViewController {

    // MARK: - Properties
    
    let firstNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "First Name"
        textField.autocapitalizationType = .none
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let lastNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Last Name"
        textField.autocapitalizationType = .none
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.autocapitalizationType = .none
        textField.text = Defaults.userEmail
        textField.keyboardType = .emailAddress
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.autocapitalizationType = .none
        textField.text = Defaults.userPassword
        textField.isSecureTextEntry = true
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    // MARK: - Setup UI
    
    private func setupViews() {
        view.backgroundColor = .white
        
        view.addSubview(firstNameTextField)
        view.addSubview(lastNameTextField)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(signUpButton)
        
        NSLayoutConstraint.activate([
            firstNameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            firstNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            firstNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            firstNameTextField.heightAnchor.constraint(equalToConstant: 40),
            
            lastNameTextField.topAnchor.constraint(equalTo: firstNameTextField.bottomAnchor, constant: 20),
            lastNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            lastNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            lastNameTextField.heightAnchor.constraint(equalToConstant: 40),
            
            emailTextField.topAnchor.constraint(equalTo: lastNameTextField.bottomAnchor, constant: 20),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 40),
            
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            passwordTextField.heightAnchor.constraint(equalToConstant: 40),
            
            signUpButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 30),
            signUpButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            signUpButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            signUpButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    // MARK: - Button Actions
    
    @objc private func signUpButtonTapped() {
        
        register()
        print("Sign Up button tapped")
    }
    
    private func register() {
        let urlString = "http://localhost:8081/reddit/auth/register"
        let url = URL(string: urlString)!
        
        guard let firstNameText = firstNameTextField.text, !firstNameText.isEmpty, let lastNameText = lastNameTextField.text, !lastNameText.isEmpty, let emailText = emailTextField.text, !emailText.isEmpty, let passwordText = passwordTextField.text, !passwordText.isEmpty else {
            showErrorAlert()
            return
        }

        // Create an instance of SignUpModel
        let signUpData = SignUpModel(firstname: firstNameText,
                                     lastname: lastNameText,
                                     email: emailText,
                                     password: passwordText)

        // Create a URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // Set the HTTP body with encoded JSON data
        do {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase // If your server expects snake_case keys
            request.httpBody = try encoder.encode(signUpData)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        } catch {
            print("Error encoding data: \(error)")
            // Handle error
        }

        // Perform the request
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("Error: \(error)")
                // Handle error
                return
            }
            
            if let response = response as? HTTPURLResponse {
                print("Status code: \(response.statusCode)")
                if response.statusCode == 200 {
                    Defaults.userEmail = signUpData.email
                    Defaults.userPassword = signUpData.password
                    DispatchQueue.main.async {
                        self?.navigationController?.popToRootViewController(animated: true)
                    }
                    
                } else {
                    DispatchQueue.main.async {
                        self?.showErrorAlert()
                    }
                }
                // Handle response status code
            } else {
                DispatchQueue.main.async {
                    self?.showErrorAlert()
                }
            }
        }

        task.resume()
    }
    
    private func showErrorAlert() {
        let alert = UIAlertController(title: "Error login", message: "check your user data", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        present(alert, animated: true)
    }
}
