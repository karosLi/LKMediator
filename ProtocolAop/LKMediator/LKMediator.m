//
//  LKMediator.m
//  ProtocolAop
//
//  Created by karos li on 2017/6/14.
//  Copyright © 2017年 karos. All rights reserved.
//

#import "LKMediator.h"
#import "VKMsgSend.h"
#import <objc/runtime.h>

@interface LKMediator ()

@property (nonatomic, strong) NSMutableDictionary *cachedProxys;

@end

@implementation LKMediator

#pragma mark - public methods
+ (instancetype)sharedInstance
{
    static id mediator;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mediator = [[self alloc] init];
    });
    
    return mediator;
}

/*
 scheme://[proxy]/[action]?[params]
 
 url sample:
 aaa://proxyA/actionB?id=1234
 */
- (id)performUrl:(NSURL *)url completion:(void (^)(NSDictionary *))completion
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSString *urlString = [url query];
    for (NSString *param in [urlString componentsSeparatedByString:@"&"]) {
        NSArray *elts = [param componentsSeparatedByString:@"="];
        if([elts count] < 2) continue;
        [params setObject:[elts lastObject] forKey:[elts firstObject]];
    }
    
    // 这里这么写主要是出于安全考虑，防止黑客通过远程方式调用本地模块。这里的做法足以应对绝大多数场景，如果要求更加严苛，也可以做更加复杂的安全逻辑。
    NSString *actionName = [url.path stringByReplacingOccurrencesOfString:@"/" withString:@""];
    if ([actionName hasPrefix:@"native"]) {
        return @(NO);
    }
    
    NSString *protocolString = [NSString stringWithFormat:@"%@Protocol", url.host];
    actionName = [NSString stringWithFormat:@"%@:", actionName];
    
    id result = [self performProxy:NSProtocolFromString(protocolString) action:NSSelectorFromString(actionName) params:params];
    if (completion) {
        if (result) {
            completion(@{@"result":result});
        } else {
            completion(nil);
        }
    }
    
    return result;
}

- (id)performProxy:(Protocol *)protocol action:(SEL)action params:(NSDictionary *)params
{
    return [self performProxy:protocol action:action cacheProxy:NO params:params];
}

- (id)performProxy:(Protocol *)protocol action:(SEL)action cacheProxy:(BOOL)cacheProxy params:(NSDictionary *)params
{
    Class proxyClass;
    NSString *proxyClassString = NSStringFromProtocol(protocol);
    
    NSObject *proxy = self.cachedProxys[proxyClassString];
    if (proxy == nil) {
        proxyClass = [self proxyClassForProtocol:protocol];
        proxy = [[proxyClass alloc] init];
    }
    
    if (proxyClass == nil) {
        return nil;
    }
    
    if (cacheProxy) {
        self.cachedProxys[proxyClassString] = proxyClass;
    }
    
    if ([proxy respondsToSelector:action]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        return [self safePerformAction:action target:proxy params:params];
#pragma clang diagnostic pop
    } else {
        SEL action = NSSelectorFromString(@"notFound:");
        if ([proxy respondsToSelector:action]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            return [self safePerformAction:action target:proxy params:params];;
#pragma clang diagnostic pop
        } else {
            [self.cachedProxys removeObjectForKey:proxyClassString];
            return nil;
        }
    }
    
    return nil;
}

- (id)performProxy:(Protocol *)protocol action:(SEL)action error:(NSError *__autoreleasing *)error,...
{
    Class proxyClass;
    NSString *proxyClassString = NSStringFromProtocol(protocol);
    
    NSObject *proxy = self.cachedProxys[proxyClassString];
    if (proxy == nil) {
        proxyClass = [self proxyClassForProtocol:protocol];
        proxy = [[proxyClass alloc] init];
    }
    
    if (proxyClass == nil) {
        return nil;
    }
    
    if ([proxy respondsToSelector:action]) {
        va_list argList;
        va_start(argList, error);
        NSArray* boxingArguments = vk_targetBoxingArguments(argList, proxyClass, action, error);
        va_end(argList);
        
        if (!boxingArguments) {
            return nil;
        }
        return vk_targetCallSelectorWithArgumentError(proxy, action, boxingArguments, error);
    }
    
    return nil;
}

- (id)performProxy:(Protocol *)protocol action:(SEL)action cacheProxy:(BOOL)cacheProxy error:(NSError *__autoreleasing *)error,...
{
    Class proxyClass;
    NSString *proxyClassString = NSStringFromProtocol(protocol);
    
    NSObject *proxy = self.cachedProxys[proxyClassString];
    if (proxy == nil) {
        proxyClass = [self proxyClassForProtocol:protocol];
        proxy = [[proxyClass alloc] init];
    }
    
    if (proxyClass == nil) {
        return nil;
    }
    
    if (cacheProxy) {
        self.cachedProxys[proxyClassString] = proxyClass;
    }
    
    if ([proxy respondsToSelector:action]) {
        va_list argList;
        va_start(argList, error);
        NSArray* boxingArguments = vk_targetBoxingArguments(argList, proxyClass, action, error);
        va_end(argList);
        
        if (!boxingArguments) {
            return nil;
        }
        return vk_targetCallSelectorWithArgumentError(proxy, action, boxingArguments, error);
    } else {
        [self.cachedProxys removeObjectForKey:proxyClassString];
        return nil;
    }
    
    return nil;
}

- (void)releaseCachedProxyForProtocol:(Protocol *)protocol
{
    NSString *proxyClassString = NSStringFromProtocol(protocol);
    [self.cachedProxys removeObjectForKey:proxyClassString];
}

#pragma mark - getters and setters
- (NSMutableDictionary *)cachedProxys
{
    if (_cachedProxys == nil) {
        _cachedProxys = [[NSMutableDictionary alloc] init];
    }
    return _cachedProxys;
}

#pragma mark - pricate methods
- (id)safePerformAction:(SEL)action target:(NSObject *)target params:(NSDictionary *)params
{
    NSMethodSignature* methodSig = [target methodSignatureForSelector:action];
    if(methodSig == nil) {
        return nil;
    }
    const char* retType = [methodSig methodReturnType];
    
    if (strcmp(retType, @encode(void)) == 0) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
        [invocation setArgument:&params atIndex:2];
        [invocation setSelector:action];
        [invocation setTarget:target];
        [invocation invoke];
        return nil;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        return [target performSelector:action withObject:params];
#pragma clang diagnostic pop
    }
}

- (Class)proxyClassForProtocol:(Protocol *)protocol {
    NSString *protocolName = NSStringFromProtocol(protocol);
    Class class = NSClassFromString([NSString stringWithFormat:@"%@%@", @"Proxy_", protocolName]);
    
#ifdef DEBUG
    ClassDoNotImplementsMethodsInProtocol(class, protocol);
#endif
    
    return class;
}

void ClassDoNotImplementsMethodsInProtocol(Class class, Protocol *protocol) {
    BOOL isRequiredMethod = YES;
    BOOL isInstanceMethod = YES;
    
    unsigned int count;
    struct objc_method_description *methodDescriptions = protocol_copyMethodDescriptionList(protocol, isRequiredMethod, isInstanceMethod, &count);
    
    for (unsigned int i = 0; i<count; i++) {
        if (![class instancesRespondToSelector:methodDescriptions[i].name]) {
            NSLog(@"Class %@ do not implement method %@", NSStringFromClass(class), NSStringFromSelector(methodDescriptions[i].name));
        }
    }
    free(methodDescriptions);
}

@end
