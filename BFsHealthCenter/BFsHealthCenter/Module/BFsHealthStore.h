//
//  BFsHealthAssistant.h
//  BFsHealthCenter
//
//  Created by BFsAlex on 2019/4/29.
//  Copyright © 2019 BFsAlex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BFsHealthStoreHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface BFsHealthStore : NSObject

//
+ (BOOL)isDataAvailable;
//
+ (instancetype)sharedAssistant;
- (void)destoryAssistant;
//
- (void)setupHealthStore:(HSResultBlock)resultBlock;
- (void)queryStepCount:(HSResultBlock)resultBlock;
- (void)saveStepCount:(double)count andResultBlock:(HSResultBlock)resultBlock;

@end

NS_ASSUME_NONNULL_END
