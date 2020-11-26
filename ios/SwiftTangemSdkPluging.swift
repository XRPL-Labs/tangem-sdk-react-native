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
    
    @objc func scanCard(_ resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            self.sdk.scanCard () { [weak self] result in self?.handleCompletion(result, resolve, reject) }
        }
    }

    
    @objc func createWallet(_ cid: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            self.sdk.createWallet(cardId: cid) { [weak self] result in self?.handleCompletion(result, resolve, reject) }
        }
    }
    
    @objc func purgeWallet(_ cid: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            self.sdk.purgeWallet(cardId: cid) { [weak self] result in self?.handleCompletion(result, resolve, reject) }
        }
    }
    
    @objc func sign(_ cid: String, hashes: [String], resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            let hexHashes = hashes.compactMap({Data(hexString: $0)})
            self.sdk.sign(hashes: hexHashes, cardId: cid) { [weak self] result in self?.handleCompletion(result, resolve, reject) }
        }
    }

    @objc func changePin1(_ cid: String, pin: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            self.sdk.changePin1(cardId: cid, pin: pin.sha256()) { [weak self] result in self?.handleCompletion(result, resolve, reject) }
        }
    }

    @objc func changePin2(_ cid: String, pin: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            self.sdk.changePin2(cardId: cid, pin: pin.sha256()) { [weak self] result in self?.handleCompletion(result, resolve, reject) }
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
    
    private func handleCompletion<TResult: ResponseCodable>(_ sdkResult: Result<TResult, TangemSdkError>, _ resolve: RCTPromiseResolveBlock, _ reject: RCTPromiseRejectBlock) {
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
