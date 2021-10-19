import Foundation

final class KeychainManager {
    
    static let shared = KeychainManager()
    
    typealias KeychainDictionary = [String : Any]
    typealias ItemAttributes = [CFString : Any]
    
    /// Save any Encodable data into the keychain
    ///
    /// ```
    /// do {
    ///    let apiTokenAttributes: KeychainManager.ItemAttributes = [
    ///         kSecAttrLabel: "ApiToken"
    ///    ]
    ///    try KeychainManager.shared.saveItem(apiToken, itemClass: .generic, attributes: apiTokenAttributes)
    ///    print("Api Token saved!")
    /// } catch let keychainError as KeychainManager.KeychainError {
    ///     print(keychainError.localizedDescription)
    /// } catch {
    ///     print(error)
    /// }
    /// ```
    ///
    /// - Parameter item: The item to be saved
    /// - Parameter itemClass: The item class
    /// - Parameter attributes: The attributes that unique identifiy the ittem
    func saveItem<T: Encodable>(_ item: T, itemClass: ItemClass, attributes: ItemAttributes? = nil) throws {
        
        let itemData = try JSONEncoder().encode(item)
        var query: KeychainDictionary = [
            kSecClass as String: itemClass.rawValue,
            kSecValueData as String: itemData as AnyObject
        ]
        
        if let itemAttributes = attributes {
            query.addAttributes(itemAttributes)
        }
        
        let result = SecItemAdd(query as CFDictionary, nil)
        if result != errSecSuccess {
            throw convertError(result)
        }
    }
    
    /// Retrieve a decodable item from the keychain
    ///
    /// ```
    /// do {
    ///    let apiTokenAttributes: KeychainManager.ItemAttributes = [
    ///         kSecAttrLabel: "ApiToken"
    ///    ]
    ///    let token: String = try KeychainManager.shared.retrieveItem(ofClass: .generic, attributes: apiTokenAttributes)
    /// } catch let keychainError as KeychainManager.KeychainError {
    ///     print(keychainError.localizedDescription)
    /// } catch {
    ///     print(error)
    /// }
    /// ```
    ///
    /// - Parameter itemClass: The item class
    /// - Parameter attributes: The attributes that unique identify the item
    /// - Returns: An instance of type `T`
    func retrieveItem<T: Decodable>(ofClass itemClass: ItemClass, attributes: ItemAttributes? = nil) throws -> T {
        var query: KeychainDictionary = [
            kSecClass as String: itemClass.rawValue,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ]
        
        if let itemAttributes = attributes {
            query.addAttributes(itemAttributes)
        }
        
        var item: CFTypeRef?
        let result = SecItemCopyMatching(query as CFDictionary, &item)
        if result != errSecSuccess {
            throw convertError(result)
        }
        
        guard let keychainItem = item as? [String : Any], let data = keychainItem[kSecValueData as String] as? Data else {
            throw KeychainError.invalidData
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    /// Update an encodable item from the keychain
    ///
    /// ```
    /// do {
    ///    let apiTokenAttributes: KeychainManager.ItemAttributes = [
    ///         kSecAttrLabel: "ApiToken"
    ///    ]
    ///    let token: String = try KeychainManager.shared.retrieveItem(ofClass: .generic, attributes: apiTokenAttributes)
    /// } catch let keychainError as KeychainManager.KeychainError {
    ///     print(keychainError.localizedDescription)
    /// } catch {
    ///     print(error)
    /// }
    /// ```
    ///
    /// - Parameter item: Item to update
    /// - Parameter itemClass: The item class
    /// - Parameter attributes: The attributes that unique identify the item
    func updateItem<T: Encodable>(with item: T, ofClass itemClass: ItemClass, attributes: ItemAttributes? = nil) throws {
        var query: KeychainDictionary = [
            kSecClass as String: itemClass.rawValue
        ]
        
        if let itemAttributes = attributes {
            query.addAttributes(itemAttributes)
        }
        
        let itemData = try JSONEncoder().encode(item)
        
        let attributesToUpdate: KeychainDictionary = [
            kSecValueData as String: itemData as AnyObject
        ]
        
        let result = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
        if result != errSecSuccess {
            throw convertError(result)
        }
    }
    
    /// Delete an item from the keychain
    ///
    /// ```
    /// do {
    ///    let apiTokenAttributes: KeychainManager.ItemAttributes = [
    ///         kSecAttrLabel: "ApiToken"
    ///    ]
    ///    try KeychainManager.shared.deleteImte(ofClass: .generic, attributes: apiTokenAttributes)
    /// } catch let keychainError as KeychainManager.KeychainError {
    ///     print(keychainError.localizedDescription)
    /// } catch {
    ///     print(error)
    /// }
    /// ```
    ///
    /// - Parameter itemClass: The item class
    /// - Parameter attributes: The attributes that unique identify the item
    func deleteImte(ofClass itemClass: ItemClass, attributes: ItemAttributes) throws {
        var query: KeychainDictionary = [
            kSecClass as String: itemClass.rawValue
        ]
        
        query.addAttributes(attributes)
        
        let result = SecItemDelete(query as CFDictionary)
        if result != errSecSuccess {
            throw convertError(result)
        }
    }
}

// MARK: - ItemClass

extension KeychainManager {
    enum ItemClass: RawRepresentable {
        typealias RawValue = CFString
        
        case generic
        case password
        case certificate
        case cryptography
        case identity
        
        init?(rawValue: CFString) {
            switch rawValue {
            case kSecClassGenericPassword:
                self = .generic
            case kSecClassInternetPassword:
                self = .password
            case kSecClassCertificate:
                self = .certificate
            case kSecClassKey:
                self = .cryptography
            case kSecClassIdentity:
                self = .identity
            default:
                return nil
            }
        }
        
        var rawValue: CFString {
            switch self {
            case .generic:
                return kSecClassGenericPassword
            case .password:
                return kSecClassInternetPassword
            case .certificate:
                return kSecClassCertificate
            case .cryptography:
                return kSecClassKey
            case .identity:
                return kSecClassIdentity
            }
        }
    }
}

// MARK: - Errors

extension KeychainManager {
    enum KeychainError: Error {
        case invalidData
        case itemNotFound
        case duplicateItem
        case incorrectAttributeForClass
        case unexpected(OSStatus)
        
        var localizedDescription: String {
            switch self {
            case .invalidData:
                return "Invalid data"
            case .itemNotFound:
                return "Item not found"
            case .duplicateItem:
                return "Duplicate Item"
            case .incorrectAttributeForClass:
                return "Incorrect Attribute for Class"
            case .unexpected(let oSStatus):
                return "Unexpected error - \(oSStatus)"
            }
        }
    }
    
    private func convertError(_ error: OSStatus) -> KeychainError {
        switch error {
        case errSecItemNotFound:
            return .itemNotFound
        case errSecDataTooLarge:
            return .invalidData
        case errSecDuplicateItem:
            return .duplicateItem
        default:
            return .unexpected(error)
        }
    }
}

// MARK: - Dictionary

extension KeychainManager.KeychainDictionary {
    mutating func addAttributes(_ attributes: KeychainManager.ItemAttributes) {
        for(key, value) in attributes {
            self[key as String] = value
        }
    }
}