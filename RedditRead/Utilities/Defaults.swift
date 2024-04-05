import Foundation

enum Defaults {
    // Keys for accessing user defaults
    private static let emailKey = "userEmail"
    private static let passwordKey = "userPassword"
    private static let fontTypeKey = "fontTypeKey"
    private static let fontSizeKey = "fontSizeKey"
    
    static let fonts = ["Arial", "Times New Roman", "Helvetica"]
    
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
    
    static var fontType: String {
        get {
            return UserDefaults.standard.string(forKey: fontTypeKey) ?? fonts[0]
        }
        set {
            UserDefaults.standard.set(newValue, forKey: fontTypeKey)
        }
    }
    
    static var fontSize: Int {
        get {
            let size = UserDefaults.standard.integer(forKey: fontSizeKey)
            
            if (size == 0) {
                return 18
            } else {
                return size
            }
        }
        set {
            UserDefaults.standard.set(newValue, forKey: fontSizeKey)
        }
    }
    
    // MARK: - Clear User Data
    
    static func clearUserData() {
        UserDefaults.standard.removeObject(forKey: emailKey)
        UserDefaults.standard.removeObject(forKey: passwordKey)
        UserDefaults.standard.removeObject(forKey: fontTypeKey)
        UserDefaults.standard.removeObject(forKey: fontSizeKey)
    }
}
