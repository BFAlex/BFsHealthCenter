//
//  BFsHealthAssistant.m
//  BFsHealthCenter
//
//  Created by BFsAlex on 2019/4/29.
//  Copyright © 2019 BFsAlex. All rights reserved.
//

#import "BFsHealthAssistant.h"
#import <HealthKit/HealthKit.h>

@interface BFsHealthAssistant ()
@property (nonatomic, strong) HKHealthStore *healthStore;
@property (nonatomic, strong) HKSampleQuery *sampleQuery;
@property (nonatomic, strong) NSArray *resultItems;

@end

@implementation BFsHealthAssistant

static BFsHealthAssistant *assistant;
static dispatch_once_t onceToken;

+ (BOOL)isDataAvailable {
    return [HKHealthStore isHealthDataAvailable];
}

+ (instancetype)sharedAssistant {
    
    dispatch_once(&onceToken, ^{
        assistant = [[BFsHealthAssistant alloc] init];
        [assistant configDefaultSetting];
    });
    
    return assistant;
}
- (void)destoryAssistant {
    
    if (onceToken) {
        assistant = nil;
        onceToken = 0;
    }
}

- (void)configDefaultSetting {
    
    /*
     HKHealthStore
     [https://developer.apple.com/documentation/healthkit/setting_up_healthkit?language=objc]
     */
    self.healthStore = [[HKHealthStore alloc] init];
    
    /*
     HKSampleQuery
     [https://developer.apple.com/documentation/healthkit/hksamplequery?language=objc]
     */
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];
    NSDate *startDate = [calendar dateFromComponents:components];
    NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];
    HKSampleType *sampleType = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed];
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionNone];
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:sampleType predicate:predicate limit:HKObjectQueryNoLimit sortDescriptors:nil resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
        //
        if (error) {
            NSLog(@"An error occured fetching the user's tracked food. In your app, try to handle this gracefully. The error was: %@.", error);
            return ;
        }
        //
        self.resultItems = results;
        [self showResultItems:results];
    }];
    [self.healthStore stopQuery:query];
}

- (void)showResultItems:(NSArray *)results {
    for (HKQuantitySample *sample in results) {
        NSString *foodName = sample.metadata[HKMetadataKeyFoodType];
        double joules = [sample.quantity doubleValueForUnit:[HKUnit jouleUnit]];
        NSLog(@">>>[%@ %f]", foodName, joules);
    }
}

@end
