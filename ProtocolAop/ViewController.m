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
    
    UIViewController *vc = [[LKMediator sharedInstance] performProxy:@protocol(ModuleAProtocol) action:@selector(Action_avViewController:) params:@{kViewControllerKeyId : @"1"}];
    NSLog(@"ModuleA native %@", vc);
    
    [[LKMediator sharedInstance] performUrl:[NSURL URLWithString:@"aaa://Platform/100001?id=1234"] completion:nil];
}

@end
