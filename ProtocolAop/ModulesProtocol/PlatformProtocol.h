//
//  PlatformProtocol.h
//  ProtocolAop
//
//  Created by karos li on 2017/6/15.
//  Copyright © 2017年 karos. All rights reserved.
//

@protocol PlatformProtocol <NSObject>

@required
- (void)log:(NSDictionary *)params;

@end

