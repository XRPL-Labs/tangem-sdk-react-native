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
    
    @objc func scanCard(_ options: NSDictionary, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            self.sdk.scanCard (
                onlineVerification: self.getArg("onlineVerification", args: options, defaultValue: true) as! Bool,
                walletIndex: WalletIndex.index(self.getArg("walletIndex", args: options, defaultValue: 0) as! Int),
                initialMessage: self.getArg("initialMessage", args: options) as? Message,
                pin1: self.getArg("pin1", args: options) as? String
            ) { [weak self] result in self?.handleCompletion(result, resolve, reject) }
        }
    }
    
    
    @objc func createWallet(_ options: NSDictionary, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            self.sdk.createWallet(
                cardId: self.getArg("cardId", args: options) as? String,
                walletIndex: self.getArg("walletIndex", args: options, defaultValue: 0) as? Int,
                initialMessage: self.getArg("initialMessage", args: options) as? Message,
                pin1: self.getArg("pin1", args: options) as? String,
                pin2: self.getArg("pin2", args: options) as? String
            ) { [weak self] result in self?.handleCompletion(result, resolve, reject) }
        }
    }
    
    @objc func purgeWallet(_ options: NSDictionary, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            self.sdk.purgeWallet(
                cardId: self.getArg("cardId", args: options) as? String,
                walletIndex: WalletIndex.index(self.getArg("walletIndex", args: options, defaultValue: 0) as! Int),
                initialMessage: self.getArg("initialMessage", args: options) as? Message,
                pin1: self.getArg("pin1", args: options) as? String,
                pin2: self.getArg("pin2", args: options) as? String
            ) { [weak self] result in self?.handleCompletion(result, resolve, reject) }
        }
    }
    
    @objc func sign(_ hashes: [String], options: NSDictionary, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            self.sdk.sign(
                hashes: hashes.compactMap({Data(hexString: $0)}),
                cardId: self.getArg("cardId", args: options) as? String,
                walletIndex: WalletIndex.index(self.getArg("walletIndex", args: options, defaultValue: 0) as! Int),
                initialMessage: self.getArg("initialMessage", args: options) as? Message,
                pin1: self.getArg("pin1", args: options) as? String,
                pin2: self.getArg("pin2", args: options) as? String
            ) { [weak self] result in self?.handleCompletion(result, resolve, reject) }
        }
    }
    
    @objc func changePin1(_ options: NSDictionary, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        let pin = self.getArg("pin", args: options, defaultValue: "") as! String
        DispatchQueue.main.async {
            self.sdk.changePin1(
                cardId: self.getArg("cardId", args: options) as? String,
                pin: pin.isEmpty ? nil : pin.sha256(),
                initialMessage: self.getArg("initialMessage", args: options) as? Message
            ) { [weak self] result in self?.handleCompletion(result, resolve, reject) }
        }
    }
    
    @objc func changePin2(_ options: NSDictionary, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        let pin = self.getArg("pin", args: options, defaultValue: "") as! String
        DispatchQueue.main.async {
            self.sdk.changePin2(
                cardId: self.getArg("cardId", args: options) as? String,
                pin: pin.isEmpty ? nil : pin.sha256(),
                initialMessage: self.getArg("initialMessage", args: options) as? Message
            ) { [weak self] result in self?.handleCompletion(result, resolve, reject) }
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
            guard let data = response.description.data(using: .utf8) else { resolve({}); break }
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

fileprivate extension TangemSdkError {
    func toPluginError() -> PluginError {
        return PluginError(code: self.code, localizedDescription: self.localizedDescription)
    }
}
