//
//  ModulesProtocol.m
//  ProtocolAop
//
//  Created by karos li on 2017/6/15.
//  Copyright © 2017年 karos. All rights reserved.
//

#import "ModulesProtocol.h"

@implementation ModulesProtocol

+ (void)load
{
    /**
     url 远程调用的时候，避免 NSProtocolFromString() 返回 nil, 这里引入 @protocol() 语句为了能让 protocol 也加入编译，不然会被认为 protocol 没有被使用，会被编译器忽略。
     实际上代码的任何地方只要写入 @protocol() 语句，就已经是把 procotol 加入编译的，并可以在运行时使用。放在这里是为了统一管理。
     **/
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-value"
    @protocol(ModuleAProtocol);
    @protocol(PlatformProtocol);
#pragma clang diagnostic pop
}

@end
