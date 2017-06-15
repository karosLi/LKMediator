//
//  ProtocolRuntimeViewController.m
//  ProtocolAop
//
//  Created by karos li on 2017/6/15.
//  Copyright © 2017年 karos. All rights reserved.
//

#import "ProtocolRuntimeViewController.h"
#import "ModulesProtocol.h"

@interface ProtocolRuntimeViewController ()

@end

@implementation ProtocolRuntimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 即使这个类没有被调用，protocol 也会被编译进去。
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-value"
    @protocol(ModuleAProtocol);
    @protocol(PlatformProtocol);
#pragma clang diagnostic pop
}

@end
