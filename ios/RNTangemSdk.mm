//
//  RNTangemSdk.m
//  RNTangemSdk
//
//  Created by XRPL Labs on 16/11/2020.
//  Copyright © 2020 XRPL Labs. All rights reserved.
//
#import "RNTangemSdk.h"
#import "RNTangemSdk-Swift.h"


@implementation RNTangemSdk {
    SwiftTangemSdkPlugin *_swTangemSdkPlugin;
}

-(instancetype) init {
    self = [super init];
    if (self) {
        _swTangemSdkPlugin = [SwiftTangemSdkPlugin new];
    }
    
    return self;
}

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(createWallet:(NSDictionary *)options
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    [_swTangemSdkPlugin createWallet:options resolve:resolve reject:reject];
}


RCT_EXPORT_METHOD(getNFCStatus:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    [_swTangemSdkPlugin getNFCStatus:resolve reject:reject];
}

RCT_EXPORT_METHOD(purgeWallet:(NSDictionary *)options
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    [_swTangemSdkPlugin purgeWallet:options resolve:resolve reject:reject];
}

RCT_EXPORT_METHOD(resetUserCodes:(NSDictionary *)options
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    [_swTangemSdkPlugin resetUserCodes:options resolve:resolve reject:reject];
}

RCT_EXPORT_METHOD(scanCard:(NSDictionary *)options
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    [_swTangemSdkPlugin scanCard:options resolve:resolve reject:reject];
}

RCT_EXPORT_METHOD(setAccessCode:(NSDictionary *)options
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    [_swTangemSdkPlugin setAccessCode:options resolve:resolve reject:reject];
}

RCT_EXPORT_METHOD(setPasscode:(NSDictionary *)options
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    [_swTangemSdkPlugin setPasscode:options resolve:resolve reject:reject];
}

RCT_EXPORT_METHOD(sign:(NSDictionary *)options
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    [_swTangemSdkPlugin sign:options resolve:resolve reject:reject];
}

RCT_EXPORT_METHOD(startSession:(NSDictionary *)options
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    [_swTangemSdkPlugin startSession:options resolve:resolve reject:reject];
}

RCT_EXPORT_METHOD(stopSession:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    [_swTangemSdkPlugin stopSession:resolve reject:reject];
}

#ifdef RCT_NEW_ARCH_ENABLED
- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeTangemSdkModuleSpecJSI>(params);
}
#endif
@end
