//
//  BFsHealthAssistant.m
//  BFsHealthCenter
//
//  Created by BFsAlex on 2019/4/29.
//  Copyright © 2019 BFsAlex. All rights reserved.
//

#import "BFsHealthStore.h"
#import <HealthKit/HealthKit.h>

@interface BFsHealthStore ()
@property (nonatomic, strong) HKHealthStore *healthStore;
@property (nonatomic, strong) HKSampleQuery *sampleQuery;
@property (nonatomic, strong) NSArray *resultItems;

@end

@implementation BFsHealthStore

static BFsHealthStore *assistant;
static dispatch_once_t onceToken;

+ (BOOL)isDataAvailable {
    return [HKHealthStore isHealthDataAvailable];
}

+ (instancetype)sharedAssistant {
    
    dispatch_once(&onceToken, ^{
        assistant = [[BFsHealthStore alloc] init];
//        [assistant configDefaultSetting];
    });
    
    return assistant;
}
- (void)destoryAssistant {
    
    if (onceToken) {
        assistant = nil;
        onceToken = 0;
    }
}


/*
 构建
 */
- (void)setupHealthStore:(HSResultBlock)resultBlock {
    // 功能集
    if (![BFsHealthStore isDataAvailable]) {
        if (resultBlock) {
            NSError *error = [self errorForDescription:@"设备不支持相关功能"];
            resultBlock(error, nil);
        }
        
        return;
    }
    // 授权
    _healthStore = [[HKHealthStore alloc] init];
    NSSet *targetSRTypes = [NSSet setWithObjects:[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount], nil];
    [_healthStore requestAuthorizationToShareTypes:targetSRTypes readTypes:targetSRTypes completion:^(BOOL success, NSError * _Nullable error) {
        if (error) {
            if (resultBlock) {
                resultBlock(error, nil);
            }
        }
    }];
}

/*
 Query
 */
- (void)queryStepCount:(HSResultBlock)resultBlock {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *curDate = [NSDate date];
    NSDateComponents *components = [calendar components:NSCalendarUnitDay fromDate:curDate];
    NSDate *startDate = [calendar dateFromComponents:components];
    NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];
    
    HKSampleType *sampleType = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionNone];
    
    HKSampleQuery *sampleQuery = [[HKSampleQuery alloc] initWithSampleType:sampleType predicate:predicate limit:HKObjectQueryNoLimit sortDescriptors:nil resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
        //
//        NSLog(@"finish query(%lu)...", results.count);
//        for (HKSample *sample in results) {
//            NSLog(@"[type:%@, start date:%@, end date:%@]", sample.sampleType, sample.startDate, sample.endDate);
//        }
        
        if (resultBlock) {
            resultBlock(error, results);
        }
        
    }];
    [_healthStore executeQuery:sampleQuery];
}

/*
 Save data
 */
- (void)saveStepCount:(double)count andResultBlock:(HSResultBlock)resultBlock {
    
    NSDate *endDate = [NSDate date];
    NSDate *startDate = [NSDate dateWithTimeInterval:-300 sinceDate:endDate];
    
    HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit countUnit] doubleValue:count];
    HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
//    HKDevice *device = [[HKDevice alloc] initWithName:@"iPhone" manufacturer:@"Apple" model:@"iPhone" hardwareVersion:@"iPhone6s Plus" firmwareVersion:@"iPhone6s Plus" softwareVersion:@"12.0" localIdentifier:@"iphone" UDIDeviceIdentifier:@"iphone"];
    
    HKQuantitySample *quantituSample = [HKQuantitySample quantitySampleWithType:quantityType quantity:quantity startDate:startDate endDate:endDate];
    
    [_healthStore saveObject:quantituSample withCompletion:^(BOOL success, NSError * _Nullable error) {
        //
        if (resultBlock) {
            resultBlock(error, nil);
        }
    }];
}


// build error message

- (NSError *)errorCode:(NSInteger)code andDescription:(NSString *)desc {
    
    NSDictionary *errDict = @{NSLocalizedDescriptionKey:desc};
    NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:code userInfo:errDict];
    
    return error;
}

- (NSError *)errorForDescription:(NSString *)desc {
    
    return [self errorCode:110 andDescription:desc];
}

@end
