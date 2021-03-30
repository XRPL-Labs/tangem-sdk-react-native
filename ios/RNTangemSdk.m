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
RCT_EXTERN_METHOD(scanCard:(NSDictionary)options resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(createWallet:(NSDictionary)options resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(purgeWallet:(NSDictionary)options resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(changePin1:(NSDictionary)options resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(changePin2:(NSDictionary)options resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(sign:(NSArray<NSString *>*)hashes options:(NSDictionary)options resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(getNFCStatus:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)

+ (BOOL)requiresMainQueueSetup{
  return NO;
}
@end
