//
//  BFsHealthAssistant.h
//  BFsHealthCenter
//
//  Created by BFsAlex on 2019/4/29.
//  Copyright © 2019 BFsAlex. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BFsHealthAssistant : NSObject

//
+ (BOOL)isDataAvailable;
//
+ (instancetype)sharedAssistant;
- (void)destoryAssistant;


@end

NS_ASSUME_NONNULL_END
