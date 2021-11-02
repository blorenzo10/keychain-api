## Usage

Copy the KeychainManager.swift file into your project.

For every item that you want to save, update, delete or retrieve you must provide a list of attributes in order to identify the item correctly. Depending on the item class you chose, the available attributes you're going to have available for usage. You can check the full list [here](https://developer.apple.com/documentation/security/keychain_services/keychain_items/item_attribute_keys_and_values).

### Items types

More information, [here](https://developer.apple.com/documentation/security/keychain_services/keychain_items/item_class_keys_and_values#1678477).

- **Generic**
- **Password**
- **Certificate**
- **Cryptography**
- **Identity**


### Operations

**Save item**

```swift
let apiToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJnb2Fsc2J1ZGR5IiwiZXhwIjo2NDA5MjIxMTIwMH0.JoDuSMARI2Ihh8fisiUxfQiP8AE_WFz9Hcogkk8QMcQ"
do {
    let apiTokenAttributes: KeychainManager.ItemAttributes = [
        kSecAttrLabel: "ApiToken"
    ]
    try KeychainManager.shared.saveItem(apiToken, itemClass: .generic, key: "ApiToken", attributes: apiTokenAttributes)
} catch let keychainError as KeychainManager.KeychainError {
    print(keychainError.localizedDescription)
} catch {
    print(error)
}
```

**Update item**

```swift
do {
    let apiTokenAttributes: KeychainManager.ItemAttributes = [
        kSecAttrLabel: "ApiToken"
    ]
    
    try KeychainManager.shared.updateItem(with: "new-token-value", ofClass: .generic, key: "ApiToken", attributes: apiTokenAttributes)
    
} catch let keychainError as KeychainManager.KeychainError {
    print(keychainError.localizedDescription)
} catch {
    print(error)
}
```

**Delete item**

```swift
do {
    let apiTokenAttributes: KeychainManager.ItemAttributes = [
        kSecAttrLabel: "ApiToken"
    ]
    
    try KeychainManager.shared.deleteImte(ofClass: .generic, key: "ApiToken", attributes: apiTokenAttributes)
    
} catch let keychainError as KeychainManager.KeychainError {
    print(keychainError.localizedDescription)
} catch {
    print(error)
}
```

**Retrieve item**

```swift
do {
    let apiTokenAttributes: KeychainManager.ItemAttributes = [
        kSecAttrLabel: "ApiToken"
    ]
    
    let token: String = try KeychainManager.shared.retrieveItem(ofClass: .generic, key: "ApiToken", attributes: apiTokenAttributes)
    
} catch let keychainError as KeychainManager.KeychainError {
    print(keychainError.localizedDescription)
} catch {
    print(error)
}
```
