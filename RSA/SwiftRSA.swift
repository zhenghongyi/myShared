
import Foundation

public struct SwiftRSA {
    
    /// 使用公钥字符串加密Data
    /// - Parameters:
    ///   - data: 需加密的Data
    ///   - publicKey: 公钥字符串
    /// - Returns: 加密后Data
    public static func encryptData(_ data:Data, publicKey:String) -> Data? {
        guard let secKey = addPublicKey(publicKey) else { return nil }
        return encrypt(data, with: secKey)
    }
    
    static func encrypt(_ data: Data, with secKey: SecKey) -> Data? {
        let keyLen = SecKeyGetBlockSize(secKey)
        let dataLen = data.count
        
        var index:Int = 0
        var resData:Data = Data()
        while index < dataLen {
            var pieceLen = dataLen - index
            if pieceLen > keyLen - 11 {
                pieceLen = keyLen - 11
            }
            
            let curData = (data as NSData).subdata(with: NSMakeRange(index, pieceLen))
            var error: Unmanaged<CFError>?
            let curResData = SecKeyCreateEncryptedData(secKey, .rsaEncryptionPKCS1, curData as CFData, &error) as? Data
            
            if error != nil {
                print(error?.takeRetainedValue())
                break
            }
            
            if let curResData = curResData {
                resData.append(curResData)
            }
            
            index += pieceLen
        }
        return resData
    }
    
    /// 使用公钥字符串进行验签
    /// - Parameters:
    ///   - data: 目标Data
    ///   - signature: 已被私钥签名的Data
    ///   - publicKey: 公钥字符串
    /// - Returns: 验签结果
    public static func verifySignature(_ data: Data, signature:Data, publicKey:String) -> Bool {
        guard let secKey = addPublicKey(publicKey) else { return false }
        return verifySignature(data, signature: signature, with: secKey)
    }
    
    static func verifySignature(_ data: Data, signature:Data, with secKey: SecKey) -> Bool {
        var error: Unmanaged<CFError>?
        let result = SecKeyVerifySignature(secKey, .rsaSignatureDigestPKCS1v15SHA256, data as CFData, signature as CFData, &error)
        if error != nil {
            print(error?.takeRetainedValue())
            return false
        }
        return result
    }
    
    /// 使用私钥字符串解密Data
    /// - Parameters:
    ///   - data: 需解密的Data
    ///   - privateKey: 私钥字符串
    /// - Returns: 解密后Data
    public static func decryptData(_ data:Data, privateKey:String) -> Data? {
        guard let secKey = addPrivateKey(privateKey) else { return nil }
        return decrypt(data, with: secKey)
    }
    
    static func decrypt(_ data: Data, with secKey: SecKey) -> Data? {
        let keyLen = SecKeyGetBlockSize(secKey)
        let dataLen = data.count
        
        var index:Int = 0
        var resData:Data = Data()
        while index < dataLen {
            var pieceLen = dataLen - index
            if pieceLen > keyLen {
                pieceLen = keyLen
            }
            let curData = (data as NSData).subdata(with: NSMakeRange(index, pieceLen))
            
            var error: Unmanaged<CFError>?
            let curResData = SecKeyCreateDecryptedData(secKey, .rsaEncryptionPKCS1, curData as CFData, &error) as? Data
            
            if error != nil {
                print(error?.takeRetainedValue())
                break
            }
            
            if let curResData = curResData {
                resData.append(curResData)
            }
            
            index += pieceLen
        }
        return resData
    }
    
    /// 使用私钥字符串签名
    /// - Parameters:
    ///   - data: 需要签名的Data
    ///   - privateKey: 私钥字符串
    /// - Returns: 签名后的字符串
    public static func signature(_ data: Data, privateKey:String) -> Data? {
        guard let secKey = addPrivateKey(privateKey) else { return nil }
        return signature(data, with: secKey)
    }
    
    static func signature(_ data: Data, with secKey: SecKey) -> Data? {
        var error: Unmanaged<CFError>?
        let signature = SecKeyCreateSignature(secKey, .rsaSignatureDigestPKCS1v15SHA256, data as CFData, &error) as? Data
        if error != nil {
            print(error?.takeRetainedValue())
            return nil
        }
        return signature
    }
    
    // MARK: 密钥对处理
    /// 生成密钥对
    /// - Returns: 输出密钥对
    public static func generateKeyPair() -> (SecKey, SecKey)? {
        let privateAttributes:[String:Any] = [(kSecAttrIsPermanent as String):true,
                                              (kSecAttrApplicationTag as String):"MyRSAPrivate",
                                              (kSecAttrAccessible as String): kSecAttrAccessibleAfterFirstUnlock]
        let pairAttributes:[String:Any] = [(kSecAttrKeyType as String): kSecAttrKeyTypeRSA,
                                           (kSecAttrIsPermanent as String):true,
                                           (kSecAttrKeySizeInBits as String): 1024,
                                           (kSecPrivateKeyAttrs as String):privateAttributes]
        var cferror:Unmanaged<CFError>?
        if let privateKey = SecKeyCreateRandomKey(pairAttributes as CFDictionary, &cferror),
            let publicKey = SecKeyCopyPublicKey(privateKey) {
            return (publicKey, privateKey)
        }
        
        return nil
    }
    
    /// 将密钥转换成字符串
    /// - Parameters:
    ///   - secKey: 密钥
    /// - Returns: 转换后的字符串
    public static func secKeyToString(_ secKey:SecKey) -> String? {
        var error: Unmanaged<CFError>?
        let data = SecKeyCopyExternalRepresentation(secKey, &error) as? Data
        if let data = data {
            return data.base64EncodedString()
        }
        return nil
    }
    
    // MARK: 公钥转换
    /// 公钥字符串转SecKey
    /// - Parameter key: 公钥字符串
    /// - Returns: SecKey
    private static func addPublicKey(_ key: String) -> SecKey? {
        var newKey = key
        let spos = newKey.range(of: "-----BEGIN PUBLIC KEY-----")
        let epos = newKey.range(of: "-----END PUBLIC KEY-----")
        if spos != nil && epos != nil {
            newKey = String(newKey[spos!.upperBound..<epos!.lowerBound])
        }
        newKey = newKey.replacingOccurrences(of: "\r", with: "")
        newKey = newKey.replacingOccurrences(of: "\n", with: "")
        newKey = newKey.replacingOccurrences(of: "\t", with: "")
        newKey = newKey.replacingOccurrences(of: " ", with: "")
        
        var data = base64_decode(newKey)
//        data = stripPublicKeyHeader(data)
//        if data == nil {
//            return nil
//        }
        
        return addPublicKey(data!)
    }
    
    public static func addPublicKey(_ data: Data) -> SecKey? {
        let tag = "RSAUtil_PubKey"
        let d_tag = tag.data(using: String.Encoding.utf8)
        
        var publicKey = Dictionary<String, Any>.init()
        publicKey[kSecClass as String] = kSecClassKey
        publicKey[kSecAttrKeyType as String] = kSecAttrKeyTypeRSA
        publicKey[kSecAttrApplicationTag as String] = d_tag
        SecItemDelete(publicKey as CFDictionary)

        publicKey[kSecValueData as String] = data
        publicKey[kSecAttrKeyClass as String] = kSecAttrKeyClassPublic
        publicKey[kSecReturnPersistentRef as String] = true

        var status = SecItemAdd(publicKey as CFDictionary, nil)

        if status != noErr && status != errSecDuplicateItem {
            return nil
        }

        publicKey.removeValue(forKey: kSecValueData as String)
        publicKey.removeValue(forKey: kSecReturnPersistentRef as String)
        publicKey[kSecReturnRef as String] = NSNumber(value: true)
        publicKey[kSecAttrKeyType as String] = kSecAttrKeyTypeRSA

        var keyRef: CFTypeRef?
        status = SecItemCopyMatching(publicKey as CFDictionary, &keyRef)
        if status != noErr {
            return nil
        }
        
        return (keyRef as! SecKey)
    }
    
    private static func stripPublicKeyHeader(_ d_key: Data?) -> Data? {
        guard let dKey = d_key else {
            return nil
        }
        let len = dKey.count
        if len == 0 {
            return nil
        }
        
        var cKey = dataToBytes(dKey)
        var index = 0
        
        if cKey[index] != 0x30 {
            return nil
        }
        index += 1
        
        if cKey[index] > 0x80 {
            index += Int(cKey[index]) - 0x80 + 1
        } else {
            index += 1
        }
        
        let swqiod:[CUnsignedChar] = [0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00]
        if (memcmp(&cKey[index], swqiod, 15) == 1) {
            return nil
        }
        
        index += 15
        
        if cKey[index] != 0x03 {
            return nil
        }
        index += 1
        
        if cKey[index] > 0x80 {
            index += Int(cKey[index]) - 0x80 + 1
        } else {
            index += 1
        }
        
        if cKey[index] != Unicode.Scalar.init("\0").value {
            return nil
        }
        
        index += 1

        return Data.init(cKey).advanced(by: index)
    }
    
    // MARK: 私钥转换
    /// 私钥字符串转SecKey
    /// - Parameter key: 私钥字符串
    /// - Returns: SecKey
    static func addPrivateKey(_ key:String) -> SecKey? {
        var newKey = key
        var spos: Range<String.Index>?
        var epos: Range<String.Index>?
        spos =  newKey.range(of: "-----BEGIN RSA PRIVATE KEY-----")
        if spos != nil {
            epos = newKey.range(of: "-----END RSA PRIVATE KEY-----")
        } else {
            spos = newKey.range(of: "-----BEGIN PRIVATE KEY-----")
            epos = newKey.range(of: "-----END PRIVATE KEY-----")
        }
        if spos != nil && epos != nil {
            newKey = String(newKey[spos!.upperBound..<epos!.lowerBound])
        }
        newKey = newKey.replacingOccurrences(of: "\r", with: "")
        newKey = newKey.replacingOccurrences(of: "\n", with: "")
        newKey = newKey.replacingOccurrences(of: "\t", with: "")
        newKey = newKey.replacingOccurrences(of: " ", with: "")
        
        var data = base64_decode(newKey)
//        data = stripPrivateKeyHeader(data)
//        if data == nil {
//            return nil
//        }
        
        return addPrivateKey(data!)
    }
    
    /// 私钥数据流转SecKey
    /// - Parameter data: 私钥数据流
    /// - Returns: SecKey
    static func addPrivateKey(_ data:Data) -> SecKey? {
        let tag = "SwiftRSA"
        let d_tag = tag.data(using: .utf8)
        
        var privateKey = Dictionary<CFString, Any>()
        privateKey[kSecClass] = kSecClassKey
        privateKey[kSecAttrKeyType] = kSecAttrKeyTypeRSA
        privateKey[kSecAttrApplicationTag] = d_tag
        SecItemDelete(privateKey as CFDictionary)
        
        privateKey[kSecValueData] = data
        privateKey[kSecAttrKeyClass] = kSecAttrKeyClassPrivate
        privateKey[kSecReturnPersistentRef] = true
        
        var persistKey:CFTypeRef?
        var status = SecItemAdd(privateKey as CFDictionary, &persistKey)
        
        if status != noErr && status != errSecDuplicateItem {
            return nil
        }
        
        privateKey.removeValue(forKey: kSecValueData)
        privateKey.removeValue(forKey: kSecReturnPersistentRef)
        privateKey[kSecReturnRef] = true
        privateKey[kSecAttrKeyType] = kSecAttrKeyTypeRSA
        
        var keyRef:CFTypeRef?
        status = SecItemCopyMatching(privateKey as CFDictionary, &keyRef)
        if status != noErr {
            return nil
        }
        return keyRef as! SecKey
    }
    
    private static func stripPrivateKeyHeader(_ d_key: Data?) -> Data? {
        guard let dKey = d_key else {
            return nil
        }
        let len = dKey.count
        if len == 0 {
            return nil
        }
        
        var cKey = dataToBytes(dKey)
        var index = 22
        
        if cKey[index] != 0x04 {
            return nil
        }
        index += 1
        
        var cLen = Int(cKey[index])
        index += 1
        let det = cLen & 0x80
        if det == 0 {
            cLen = cLen & 0x7f
        } else {
            var byteCount = Int(cLen & 0x7f)
            if Int(byteCount) + index > len {
                return nil
            }
            var accum = 0
            var ptr = withUnsafePointer(to: &cKey[index]) { $0 }
            index += Int(byteCount)
            while byteCount > 0 {
                accum = (accum << 8) + Int(ptr.pointee)
                ptr = ptr.advanced(by: 1)
                byteCount -= 1
            }
            cLen = accum
        }
        
        return dKey.subdata(in: Range.init(_NSRange.init(location: index, length: Int(cLen)))!)
    }
    
    // MARK: 工具方法
    /// data转base64字符串
    private static func base64_encode(_ data:Data) -> String? {
        let newData = data.base64EncodedData(options: .lineLength64Characters)
        return String(data: newData, encoding: .utf8)
    }
    
    /// base64字符串解密
    private static func base64_decode(_ string:String) -> Data? {
        return Data(base64Encoded: string, options: .ignoreUnknownCharacters)
    }
    
    /// Data转Byte(UInt8)数组
    /// - Parameter data: Data
    /// - Returns: Byte(UInt8)数组
    static func dataToBytes(_ data:Data) -> [UInt8] {
        let string = dataToHex(data)
        var start = string.startIndex
        return stride(from: 0, to: string.count, by: 2).compactMap { _ in
            let end = string.index(after: start)
            defer { start = string.index(after: end) }
            return UInt8(string[start...end], radix: 16)
        }
    }
    
    /// Data转16进制字符串
    /// - Parameters:
    ///   - data: Data
    /// - Returns: 16进制字符串
    static func dataToHex(_ data:Data) -> String {
        let bytes = [UInt8](data)
        var hex:String = ""
        for index in 0..<data.count {
            let newHex = String(format: "%x", bytes[index] & 0xff)
            if newHex.count == 1 {
                hex = String(format: "%@0%@", hex, newHex)
            } else {
                hex += newHex
            }
        }
        return hex
    }
}
