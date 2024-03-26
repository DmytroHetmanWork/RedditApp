import Foundation

enum Defaults {
    // Keys for accessing user defaults
    private static let emailKey = "userEmail"
    private static let passwordKey = "userPassword"
    
    // MARK: - Email
    
    static var userEmail: String? {
        get {
            return UserDefaults.standard.string(forKey: emailKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: emailKey)
        }
    }
    
    // MARK: - Password
    
    static var userPassword: String? {
        get {
            return UserDefaults.standard.string(forKey: passwordKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: passwordKey)
        }
    }
    
    // MARK: - Clear User Data
    
    static func clearUserData() {
        UserDefaults.standard.removeObject(forKey: emailKey)
        UserDefaults.standard.removeObject(forKey: passwordKey)
    }
}
