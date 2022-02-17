//
//  ViewController.m
//  CRCallDirectoryDemo
//
//  Created by CRMO on 2017/10/19.
//  Copyright © 2017年 CRMO. All rights reserved.
//

#import "ViewController.h"
#import "CRCallDirectoryManager.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *phoneText;
@property (weak, nonatomic) IBOutlet UITextField *indtifierText;
@property (nonatomic, strong) CRCallDirectoryManager *manager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.phoneText.text = @"15258060534";
//    self.phoneText.text = @"18658849753";
    self.indtifierText.text = @"kk123";
#warning extension Bundle ID和App Group ID需要根据实际项目调整
    self.manager = [[CRCallDirectoryManager alloc] initWithExtensionIdentifier:@"com.getui.www.demo.CallDirectoryExtension"
                                            ApplicationGroupIdentifier:@"group.ent.com.getui.demo"];
}

- (IBAction)recognize:(id)sender {
    BOOL result = [self.manager addPhoneNumber:self.phoneText.text label:self.indtifierText.text];
    if (result) {
        [self reload];
    }
}

- (IBAction)block:(id)sender {
    BOOL result = [self.manager blockPhoneNumber:self.phoneText.text label:self.indtifierText.text];
    if (result) {
    [self reload];
    }
}

// 测试超大数据量效率
- (IBAction)autoRec:(id)sender {
    for (int i = 0; i < 9; i++) {
        NSString *name = @"测试时";
        NSString *phone = [NSString stringWithFormat:@"%ld", (18000000000 + i)];
        [self.manager addPhoneNumber:phone label:name];
        name = nil;
        phone = nil;
    }
    __weak typeof(self) weakself = self;
    [self.manager reload:^(NSError *error) {
        if (error) {
            [weakself alertMessage:@"写入系统错误"];
        } else {
            [weakself alertMessage:@"写入系统成功"];
        }
    }];
}

- (void)reload {
    __weak typeof(self) weakself = self;
    // 先检查设置是否打开
    [self.manager getEnableStatus:^(CXCallDirectoryEnabledStatus enabledStatus, NSError *error) {
        if (error) {
            // CXErrorCodeCallDirectoryManagerError
            [weakself alertMessage:@"获取权限发生错误"];
            return;
        }
        
        if (enabledStatus == CXCallDirectoryEnabledStatusUnknown) {
            [weakself alertMessage:@"获取权限-未知状态"];
        } else if (enabledStatus == CXCallDirectoryEnabledStatusDisabled) {
            [weakself alertMessage:@"请在设置-电话-来电阻止与身份识别中开启权限"];
        } else if (enabledStatus == CXCallDirectoryEnabledStatusEnabled) {
            // 有权限，调用reload
            [weakself.manager reload:^(NSError *error) {
                if (error) {
                   // CXErrorCodeCallDirectoryManagerError
                    [weakself alertMessage:@"写入系统错误"];
                } else {
                    [weakself alertMessage:@"写入系统成功"];
                }
            }];
        }
    }];
}

- (void)alertMessage:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK"
                                                               style:UIAlertActionStyleCancel
                                                             handler:nil];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    });
}
@end
