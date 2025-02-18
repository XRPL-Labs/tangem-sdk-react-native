//
//  RNTangemSdk.h
//  RNTangemSdk
//
//  Created by XRPL Labs on 17/02/2025.
//

#import <Foundation/Foundation.h>

#ifdef RCT_NEW_ARCH_ENABLED
#import <RNTangemSdkSpecs/RNTangemSdkSpecs.h>
@interface RNTangemSdk : NSObject <NativeTangemSdkModuleSpec>
#else
#import <React/RCTBridgeModule.h>
@interface RNTangemSdk : NSObject <RCTBridgeModule>
#endif
@end
