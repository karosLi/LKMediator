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
- (UIViewController *)Action_avViewController:(NSDictionary *)params;
- (void)Action_printSomething:(NSDictionary *)params;

@end

