//
//  Proxy_PlatformProtocol.m
//  ProtocolAop
//
//  Created by karos li on 2017/6/15.
//  Copyright © 2017年 karos. All rights reserved.
//

#import "Proxy_PlatformProtocol.h"

@implementation Proxy_PlatformProtocol

- (void)log:(NSDictionary *)params
{
    NSLog(@"log %@", params);
}

@end
