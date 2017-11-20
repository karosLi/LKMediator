//
//  LKMediator.h
//  ProtocolAop
//
//  Created by karos li on 2017/6/14.
//  Copyright © 2017年 karos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VKMsgSend.h"

@interface LKMediator : NSObject

+ (instancetype)sharedInstance;

// 远程App调用入口
- (id)performUrl:(NSURL *)url completion:(void (^)(NSDictionary *))completion;

// 本地组件调用入口
- (id)performProxy:(Protocol *)protocol action:(SEL)action params:(NSDictionary *)params;
- (id)performProxy:(Protocol *)protocol action:(SEL)action cacheProxy:(BOOL)cacheProxy params:(NSDictionary *)params;

// 本地组件调用入口, 支持可变参数
- (id)performProxy:(Protocol *)protocol action:(SEL)action error:(NSError *__autoreleasing *)error,...;
- (id)performProxy:(Protocol *)protocol action:(SEL)action cacheProxy:(BOOL)cacheProxy error:(NSError *__autoreleasing *)error,...;

- (void)releaseCachedProxyForProtocol:(Protocol *)protocol;

@end
