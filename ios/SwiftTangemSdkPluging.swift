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
            let optionsParser = OptionsParser(options: options)
            self.sdk.scanCard (
                onlineVerification: optionsParser.getOnlineVerification(),
                walletIndex: optionsParser.getWalletIndex().1,
                initialMessage: optionsParser.getInitialMessage(),
                pin1: optionsParser.getPin1()
            ) { [weak self] result in self?.handleCompletion(result, resolve, reject) }
        }
    }
    
    @objc func verifyCard(_ options: NSDictionary, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            let optionsParser = OptionsParser(options: options)
            self.sdk.verify (
                cardId: optionsParser.getCardId(),
                online: optionsParser.getOnline(),
                initialMessage: optionsParser.getInitialMessage(),
                pin1: optionsParser.getPin1()
            ) { [weak self] result in self?.handleCompletion(result, resolve, reject) }
        }
    }
    
    
    @objc func createWallet(_ options: NSDictionary, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            let optionsParser = OptionsParser(options: options)
            self.sdk.createWallet(
                cardId: optionsParser.getCardId(),
                walletIndex: optionsParser.getWalletIndex().0,
                initialMessage: optionsParser.getInitialMessage(),
                pin1: optionsParser.getPin1(),
                pin2: optionsParser.getPin2()
            ) { [weak self] result in self?.handleCompletion(result, resolve, reject) }
        }
    }
    
    @objc func purgeWallet(_ options: NSDictionary, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            let optionsParser = OptionsParser(options: options)
            self.sdk.purgeWallet(
                cardId: optionsParser.getCardId(),
                walletIndex: optionsParser.getWalletIndex().1,
                initialMessage: optionsParser.getInitialMessage(),
                pin1: optionsParser.getPin1(),
                pin2: optionsParser.getPin2()
            ) { [weak self] result in self?.handleCompletion(result, resolve, reject) }
        }
    }
    
    @objc func sign(_ hashes: [String], options: NSDictionary, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            let optionsParser = OptionsParser(options: options)
            self.sdk.sign(
                hashes: hashes.compactMap({Data(hexString: $0)}),
                cardId: optionsParser.getCardId(),
                walletIndex: optionsParser.getWalletIndex().1,
                initialMessage: optionsParser.getInitialMessage(),
                pin1: optionsParser.getPin1(),
                pin2: optionsParser.getPin2()
            ) { [weak self] result in self?.handleCompletion(result, resolve, reject) }
        }
    }
    
    @objc func changePin1(_ options: NSDictionary, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            let optionsParser = OptionsParser(options: options)
            self.sdk.changePin1(
                cardId: optionsParser.getCardId(),
                pin: optionsParser.getPin(),
                initialMessage: optionsParser.getInitialMessage()
            ) { [weak self] result in self?.handleCompletion(result, resolve, reject) }
        }
    }
    
    @objc func changePin2(_ options: NSDictionary, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            let optionsParser = OptionsParser(options: options)
            self.sdk.changePin2(
                cardId: optionsParser.getCardId(),
                pin: optionsParser.getPin(),
                initialMessage: optionsParser.getInitialMessage()
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

class OptionsParser {
    var options: NSDictionary

    init(options: NSDictionary) {
        self.options = options
    }
    
    func getOnlineVerification() -> Bool {
        if let onlineVerification = self.options.object(forKey: "onlineVerification") as? Bool {
            return onlineVerification;
        }
        else {
            return false;
        }
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
    
    func getWalletIndex() -> (Int?, WalletIndex?) {
        if let walletIndex = self.options.object(forKey: "walletIndex") as? Int {
            return (walletIndex, WalletIndex.index(walletIndex))
        }
        else {
            return (nil, nil)
        }
    }
    
    func getCardId() -> String? {
        if let cardId = self.options.object(forKey: "cardId") as? String {
            return cardId;
        }
        else {
            return nil;
        }
    }
    
    func getPin1() -> String? {
        if let pin1 = self.options.object(forKey: "pin1") as? String {
            return pin1;
        }
        else {
            return nil;
        }
    }
    
    func getPin2() -> String? {
        if let pin2 = self.options.object(forKey: "pin2") as? String {
            return pin2;
        }
        else {
            return nil;
        }
    }
    
    func getPin() -> Data? {
        if let pin = self.options.object(forKey: "pin") as? String {
            return pin.isEmpty ? nil : pin.sha256();
        }
        else {
            return nil;
        }
    }
    
    func getOnline() -> Bool {
        if let online = self.options.object(forKey: "online") as? Bool {
            return online;
        }
        else {
            return false;
        }
    }
}
