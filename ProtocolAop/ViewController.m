//
//  ViewController.m
//  ProtocolAop
//
//  Created by karos li on 2017/6/14.
//  Copyright © 2017年 karos. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import "ModulesProtocol.h"
#import "LKMediator.h"

/**
 面向协议的动态代理组件化方案
 */
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 本地调用
    UIViewController *vc = [[LKMediator sharedInstance] performProxy:@protocol(ModuleAProtocol) action:@selector(avViewController:) params:@{kViewControllerKeyId : @"1"}];
    NSLog(@"ModuleA native %@", vc);
    
    // 远程调用
    [[LKMediator sharedInstance] performUrl:[NSURL URLWithString:@"aaa://Platform/log?id=1234"] completion:nil];
    
    // 调用一个不存在的方法
    [[LKMediator sharedInstance] performProxy:@protocol(ModuleAProtocol) action:@selector(printSomething:) params:@{kViewControllerKeyId : @"1"}];
    
//    [[LKMediator sharedInstance] performProxy:@protocol(ModuleAProtocol) action:@selector(nativeInvokeCaclA:addB:) parameters:@"1",@"2",nil];
    
    [[LKMediator sharedInstance] performProxy:@protocol(ModuleAProtocol) action:@selector(nativeInvokeCaclA:addB:resultBlock:) error:nil,@1,@3,^(NSInteger result) {
        NSLog(@"%zd", result);
    }];
}

@end
