//
//  Proxy_ModuleAProtocol.m
//  ProtocolAop
//
//  Created by karos li on 2017/6/15.
//  Copyright © 2017年 karos. All rights reserved.
//

#import "Proxy_ModuleAProtocol.h"

NSString * const kViewControllerKeyId = @"id";

@implementation Proxy_ModuleAProtocol

- (UIViewController *)avViewController:(NSDictionary *)params {
    return [[UIViewController alloc] init];
}

- (void)nativeInvokeCaclA:(NSNumber *)a addB:(NSNumber *)b resultBlock:(void(^)(NSInteger result))resultBlock {
    NSInteger c = a.integerValue + b.integerValue;
    if (resultBlock) {
        resultBlock(c);
    }
}

@end
