//
//  ViewController.m
//  BFsHealthCenter
//
//  Created by BFsAlex on 2019/4/29.
//  Copyright © 2019 BFsAlex. All rights reserved.
//

#import "ViewController.h"
#import "BFsHealthStore.h"

@interface ViewController ()
@property (nonatomic, strong) BFsHealthStore *healthStore;

@property (weak, nonatomic) IBOutlet UILabel *curStepCountLabel;
@property (weak, nonatomic) IBOutlet UITextField *addStepCountTF;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configGesture];
    
    self.healthStore = [BFsHealthStore sharedAssistant];
    [_healthStore setupHealthStore:^(NSError *error, id result) {
        if (!error) {
//            NSLog(@"666:%@", result);
        }
    }];
}

- (void)dealloc {
    
    if (self.healthStore) {
        [self.healthStore destoryAssistant];
    }
}

#pragma mark - Feature

- (void)updateDate {
    
    [_healthStore queryStepCount:^(NSError *error, id result) {
        if (error) {
            NSString *msg = [NSString stringWithFormat:@"数据更新失败: %@", error.localizedDescription];
            [self showMessage:msg];
        } else {
//            NSLog(@"result: %@", result);
            [self showMessage:@"数据更新成功"];
        }
    }];
}

- (void)addStepCount {
    
    double addCount = [self.addStepCountTF.text doubleValue];
    if (addCount < 0) {
        addCount = 0;
    }
    
    [_healthStore saveStepCount:addCount andResultBlock:^(NSError *error, id result) {
        if (!error) {
            [self showMessage:@"数据保存成功"];
        } else {
            NSString *msg = [NSString stringWithFormat:@"数据保存失败: %@", error.localizedDescription];
            [self showMessage:msg];
        }
    }];
}

- (void)configGesture {
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnView:)];
    [self.view addGestureRecognizer:tapGesture];
}

- (void)tapOnView:(UIGestureRecognizer *)gesture {
    
    [self.view endEditing:YES];
}

- (void)showMessage:(NSString *)msg {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Action

- (IBAction)actionAddStepCountBtn:(UIButton *)sender {
    
    [self addStepCount];
    [self.view endEditing:YES];
}

- (IBAction)actionUpdateBtn:(UIButton *)sender {
    
    [self updateDate];
    [self.view endEditing:YES];
}

@end
