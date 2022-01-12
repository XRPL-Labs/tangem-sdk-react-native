//
//  SwiftTangemSdkPluging.swift
//
//  Created by XRPL Labs on 16/11/2020.
//  Copyright © 2020 XRPL Labs. All rights reserved.
//

import Foundation
import CoreNFC
import TangemSdk


@available(iOS 13.0, *)
@objc(RNTangemSdk)
class RNTangemSdk: NSObject {
    private lazy var sdk: TangemSdk = {
        return TangemSdk()
    }()
    private var sessionStarted: Bool = false
    
    @objc func startSession(_ options: NSDictionary, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            if (!self.sessionStarted) {
                let optionsParser = OptionsParser(options: options)
                // set the config
                var config = Config()
                // set default attestationMode
                if let attestationMode = optionsParser.getAttestationMode() {
                    config.attestationMode = attestationMode
                }
                // set default derivationPaths
                if let defaultDerivationPath = optionsParser.getDefaultDerivationPath() {
                    config.defaultDerivationPaths[.secp256k1] = [defaultDerivationPath]
                }
                // set the new config to the SDK
                self.sdk.config = config
                // set the flag
                self.sessionStarted = true
                // resolve promise
                resolve(nil)
            }else{
                reject("ALREADY_STARTED", "session is already started", nil)
            }
        }
    }
    
    @objc func stopSession(_ resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            if(self.sessionStarted){
                // set the default config for the SDk
                self.sdk.config =  Config()
                // set the flag
                self.sessionStarted = false
                resolve(nil)
            }else{
                reject("ALREADY_STOPPED", "session is already stopped", nil)
            }
       
        }
    }
    
    @objc func scanCard(_ options: NSDictionary, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            let optionsParser = OptionsParser(options: options)
            self.sdk.scanCard (
                initialMessage: optionsParser.getInitialMessage()
            ) { [weak self] result in self?.handleCompletion(result, resolve, reject) }
        }
    }
    
    @objc func createWallet(_ options: NSDictionary, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            do{
                let optionsParser = OptionsParser(options: options)
                self.sdk.createWallet(
                    curve: optionsParser.getCurve(),
                    cardId: try optionsParser.getCardId(),
                    initialMessage: optionsParser.getInitialMessage()
                ) { [weak self] result in self?.handleCompletion(result, resolve, reject) }
            } catch OptionsParserError.RquiredArgument(let arg){
                reject("RQUIRED_ARGUMENT", "\(arg) is required", nil);
            } catch {
                reject("UNEXPECTED_ERROR", "Unexpected error: \(error).", nil);
            }
        }
    }
    
    @objc func purgeWallet(_ options: NSDictionary, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            do{
                let optionsParser = OptionsParser(options: options)
                self.sdk.purgeWallet(
                    walletPublicKey: try optionsParser.getWalletPublicKey(),
                    cardId: try optionsParser.getCardId(),
                    initialMessage: optionsParser.getInitialMessage()
                ) { [weak self] result in self?.handleCompletion(result, resolve, reject) }
            } catch OptionsParserError.RquiredArgument(let arg){
                reject("RQUIRED_ARGUMENT", "\(arg) is required", nil);
            } catch {
                reject("UNEXPECTED_ERROR", "Unexpected error: \(error).", nil);
            }
        }
    }
    
    @objc func sign(_ options: NSDictionary, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            do{
                let optionsParser = OptionsParser(options: options)
                self.sdk.sign(
                    hashes: try optionsParser.getHashes(),
                    walletPublicKey: try optionsParser.getWalletPublicKey(),
                    cardId: try optionsParser.getCardId(),
                    derivationPath: optionsParser.getDerivationPath(),
                    initialMessage: optionsParser.getInitialMessage()
                ) { [weak self] result in self?.handleCompletion(result, resolve, reject) }
            } catch OptionsParserError.RquiredArgument(let arg){
                reject("RQUIRED_ARGUMENT", "\(arg) is required", nil);
            } catch {
                reject("UNEXPECTED_ERROR", "Unexpected error: \(error).", nil);
            }
        }
    }
    
    @objc func setAccessCode(_ options: NSDictionary, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            do{
                let optionsParser = OptionsParser(options: options)
                self.sdk.setAccessCode(
                    optionsParser.getAccessCode(),
                    cardId: try optionsParser.getCardId(),
                    initialMessage: optionsParser.getInitialMessage()
                ) { [weak self] result in self?.handleCompletion(result, resolve, reject) }
            } catch OptionsParserError.RquiredArgument(let arg){
                reject("RQUIRED_ARGUMENT", "\(arg) is required", nil);
            } catch {
                reject("UNEXPECTED_ERROR", "Unexpected error: \(error).", nil);
            }
        }
    }
    
    @objc func setPasscode(_ options: NSDictionary, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            do{
                let optionsParser = OptionsParser(options: options)
                self.sdk.setPasscode(
                    optionsParser.getPasscode(),
                    cardId: try optionsParser.getCardId(),
                    initialMessage: optionsParser.getInitialMessage()
                ) { [weak self] result in self?.handleCompletion(result, resolve, reject) }
            } catch OptionsParserError.RquiredArgument(let arg){
                reject("RQUIRED_ARGUMENT", "\(arg) is required", nil);
            } catch {
                reject("UNEXPECTED_ERROR", "Unexpected error: \(error).", nil);
            }
        }
    }
    
    @objc func resetUserCodes(_ options: NSDictionary, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            do{
                let optionsParser = OptionsParser(options: options)
                self.sdk.resetUserCodes(
                    cardId: try optionsParser.getCardId(),
                    initialMessage: optionsParser.getInitialMessage()
                ) { [weak self] result in self?.handleCompletion(result, resolve, reject) }
            } catch OptionsParserError.RquiredArgument(let arg){
                reject("RQUIRED_ARGUMENT", "\(arg) is required", nil);
            } catch {
                reject("UNEXPECTED_ERROR", "Unexpected error: \(error).", nil);
            }
        }
    }
    
    
    @objc func getNFCStatus(_ resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            var isNFCAvailable: Bool {
                if NSClassFromString("NFCNDEFReaderSession") == nil { return false }
                return NFCNDEFReaderSession.readingAvailable
            }
            let resp: NSDictionary = [
                "support": isNFCAvailable,
                "enabled": isNFCAvailable,
            ]
            resolve(resp);
        }
    }
    
    
    private func getArg(_ key: String, args: NSDictionary?, defaultValue:Any? = nil) -> Any? {
        if let unwrappedArgs = args {
            if(key == "initialMessage"){
                let message = unwrappedArgs.object(forKey: key) as? NSDictionary
                if let unwrappedMessage = message {
                    return Message(
                        header: unwrappedMessage.object(forKey: "header") as? String,
                        body: unwrappedMessage.object(forKey: "body") as? String
                    )
                }
            }
            return unwrappedArgs.object(forKey: key) ?? defaultValue
        }
        return defaultValue
    }
    
    private func handleCompletion<TResult: JSONStringConvertible>(_ sdkResult: Result<TResult, TangemSdkError>, _ resolve: RCTPromiseResolveBlock, _ reject: RCTPromiseRejectBlock) {
        switch sdkResult {
        case .success(let response):
            guard let data = response.json.data(using: .utf8) else { resolve({}); break }
            let jsonObject = try? JSONSerialization.jsonObject(with: data, options: [])
            resolve(jsonObject)
        case .failure(let error):
            let pluginError = error.toPluginError()
            reject("\(pluginError.code)", pluginError.localizedDescription, nil)
        }
    }
    
    private func handleSignError(reject: RCTPromiseRejectBlock) {
        reject("9998", "Failed to sign data", nil)
    }
}

fileprivate struct PluginError: Encodable {
    let code: Int
    let localizedDescription: String
    
    var jsonDescription: String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
        let data = (try? encoder.encode(self)) ?? Data()
        return String(data: data, encoding: .utf8)!
    }
}

@available(iOS 13.0, *)
fileprivate extension TangemSdkError {
    func toPluginError() -> PluginError {
        return PluginError(code: self.code, localizedDescription: self.localizedDescription)
    }
}

enum OptionsParserError: Error {
    case RquiredArgument(String)
}

@available(iOS 13.0, *)
class OptionsParser {
    var options: NSDictionary
    
    init(options: NSDictionary) {
        self.options = options
    }
    
    
    func getInitialMessage() -> Message? {
        let message = self.options.object(forKey: "initialMessage") as? NSDictionary
        if let unwrappedMessage = message {
            return Message(
                header: unwrappedMessage.object(forKey: "header") as? String,
                body: unwrappedMessage.object(forKey: "body") as? String
            )
        }
        return nil;
    }
    
    func getCardId() throws -> String {
        if let cardId = self.options.object(forKey: "cardId") as? String {
            if(cardId.isEmpty){
                throw OptionsParserError.RquiredArgument("cardId");
            }else{
                return cardId;
            }
        }
        else {
            throw OptionsParserError.RquiredArgument("cardId");
        }
    }
    
    func getPasscode() -> String? {
        if let passcode = self.options.object(forKey: "passcode") as? String {
            return passcode;
        }
        else {
            return nil;
        }
    }
    
    func getAccessCode() -> String? {
        if let accessCode = self.options.object(forKey: "accessCode") as? String {
            return accessCode;
        }
        else {
            return nil;
        }
    }
    
    func getCurve() -> EllipticCurve {
        if let curve = self.options.object(forKey: "curve") as? String {
            switch curve {
            case "ed25519":
                return EllipticCurve.ed25519;
            case "secp256k1":
                return EllipticCurve.secp256k1;
            case "secp256r1":
                return EllipticCurve.secp256r1;
            default:
                return EllipticCurve.secp256k1;
            }
        }
        else {
            return EllipticCurve.secp256k1;
        }
    }
    
    func getWalletPublicKey() throws -> Data {
        if let walletPublicKey = self.options.object(forKey: "walletPublicKey") as? String {
            if(walletPublicKey.isEmpty){
                throw OptionsParserError.RquiredArgument("walletPublicKey");
            }else{
                return Data(hexString: walletPublicKey);
            }
        }
        else {
            throw OptionsParserError.RquiredArgument("walletPublicKey");
        }
    }
    
    func getHashes() throws -> [Data] {
        if let hashes = self.options.object(forKey: "hashes") as? [String] {
            if(hashes.isEmpty){
                throw OptionsParserError.RquiredArgument("hashes");
            }else{
                return hashes.compactMap({Data(hexString: $0)})
            }
        }
        else {
            throw OptionsParserError.RquiredArgument("hashes");
        }
    }
    
    func getDerivationPath() -> DerivationPath? {
        if let path = self.options.object(forKey: "derivationPath") as? String {
            return try? DerivationPath(rawPath: path)
        }
        return nil
    }
    
    func getAttestationMode() -> AttestationTask.Mode? {
        if let attestationMode = self.options.object(forKey: "attestationMode") as? String {
            switch attestationMode {
            case "offline":
                return .offline;
            case "normal":
                return .normal;
            case "full":
                return .full;
            default:
                return nil;
            }
        }
        else {
            return nil;
        }
    }
    
    func getDefaultDerivationPath() -> DerivationPath? {
        if let defaultPath = self.options.object(forKey: "defaultDerivationPaths") as? String {
            return try? DerivationPath(rawPath: defaultPath)
        }
        return nil
    }
}
