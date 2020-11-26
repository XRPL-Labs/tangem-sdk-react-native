//
//  RNTangemSdk.m
//  RNTangemSdk
//
//  Created by XRPL Labs on 16/11/2020.
//  Copyright © 2020 XRPL Labs. All rights reserved.
//
#import <React/RCTBridgeModule.h>
#import <Foundation/Foundation.h>

@interface RCT_EXTERN_MODULE(RNTangemSdk, NSObject)
RCT_EXTERN_METHOD(scanCard:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(createWallet:(NSString *)cid resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(purgeWallet:(NSString *)cid resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(changePin1:(NSString *)cid pin:(NSString *)pin resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(changePin2:(NSString *)cid pin:(NSString *)pin resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(sign:(NSString *)cid hashes:(NSArray<NSString *>*)hashes resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(getNFCStatus:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)

+ (BOOL)requiresMainQueueSetup{
  return NO;
}
@end
