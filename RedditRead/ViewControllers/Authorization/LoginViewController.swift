import UIKit

class LoginViewController: UIViewController {
    
    // MARK: - Properties
    
    let loginTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter your email"
        textField.text = Defaults.userEmail
        textField.autocapitalizationType = .none
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter your password"
        textField.text = Defaults.userPassword
        textField.autocapitalizationType = .none
        textField.isSecureTextEntry = true
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        return button
    }()
    
    let signUpButton: UIButton = {
        let button = UIButton(type: .roundedRect)
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
        navigationItem.setHidesBackButton(true, animated: false)
        view.backgroundColor = .systemBackground
        
        view.addSubview(loginTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        view.addSubview(signUpButton)
        
        NSLayoutConstraint.activate([
            loginTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            loginTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            loginTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            loginTextField.heightAnchor.constraint(equalToConstant: 40),
            
            passwordTextField.topAnchor.constraint(equalTo: loginTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            passwordTextField.heightAnchor.constraint(equalToConstant: 40),
            
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 30),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            loginButton.heightAnchor.constraint(equalToConstant: 40),
            
            signUpButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 30),
            signUpButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            signUpButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            signUpButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    // MARK: - Button Actions
    
    @objc private func loginButtonTapped() {
        login()
        print("Login button tapped")
    }
    
    @objc private func signUpButtonTapped() {
        let loginVC = SignUpViewController()
        navigationController?.pushViewController(loginVC, animated: true)
    }
    
    private func login() {
        let urlString = "http://localhost:8081/reddit/auth/authenticate"
        let url = URL(string: urlString)!
        
        guard let emailText = loginTextField.text, !emailText.isEmpty, let passwordText = passwordTextField.text, !passwordText.isEmpty else {
            showErrorAlert()
            return
        }

        // Create an instance of SignUpModel
        let signUpData = LoginModel(email: emailText,
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
