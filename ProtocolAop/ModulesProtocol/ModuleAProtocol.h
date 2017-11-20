//
//  ModuleAProtocol.h
//  ProtocolAop
//
//  Created by karos li on 2017/6/15.
//  Copyright © 2017年 karos. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const kViewControllerKeyId;

@protocol ModuleAProtocol <NSObject>

@required
- (UIViewController *)avViewController:(NSDictionary *)params;
- (void)printSomething:(NSDictionary *)params;
- (void)nativeInvokeCaclA:(NSNumber *)a addB:(NSNumber *)b resultBlock:(void(^)(NSInteger result))resultBlock;

@end

