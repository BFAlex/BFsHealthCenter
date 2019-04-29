//
//  BFsHealthAssistant.m
//  BFsHealthCenter
//
//  Created by BFsAlex on 2019/4/29.
//  Copyright © 2019 BFsAlex. All rights reserved.
//

#import "BFsHealthAssistant.h"

@implementation BFsHealthAssistant

static BFsHealthAssistant *assistant;
static dispatch_once_t onceToken;

+ (instancetype)sharedAssistant {
    
    dispatch_once(&onceToken, ^{
        assistant = [[BFsHealthAssistant alloc] init];
    });
    
    return assistant;
}
- (void)destoryAssistant {
    
    if (onceToken) {
        assistant = nil;
        onceToken = 0;
    }
}

@end
