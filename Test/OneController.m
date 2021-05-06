//
//  OneController.m
//  Test
//
//  Created by MMM on 2021/1/4.
//
//
//      ┏┛ ┻━━━━━┛ ┻┓
//      ┃　　　　　　 ┃
//      ┃　　　━　　　┃
//      ┃　┳┛　  ┗┳　┃
//      ┃　　　　　　 ┃
//      ┃　　　┻　　　┃
//      ┃　　　　　　 ┃
//      ┗━┓　　　┏━━━┛
//        ┃　　　┃   神兽保佑
//        ┃　　　┃   代码无BUG！
//        ┃　　　┗━━━━━━━━━┓
//        ┃　　　　　　　    ┣┓
//        ┃　　　　         ┏┛
//        ┗━┓ ┓ ┏━━━┳ ┓ ┏━┛
//          ┃ ┫ ┫   ┃ ┫ ┫
//          ┗━┻━┛   ┗━┻━┛
//
// Copyright ©2020 Maimaimai Co.,Ltd. All rights reserved.

#import "OneController.h"
#import "TwoController.h"
#import <Masonry/Masonry.h>

@interface OneController ()

@end


@implementation OneController

- (void)dealloc {
    NSLog(@"%s", __func__);
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	self.title = @"";
    self.view.backgroundColor = UIColor.whiteColor;

    [self initUI];
}

#pragma mark - Notification

#pragma mark - 初始化UI

- (void)initUI {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"页面1" forState:UIControlStateNormal];
    [button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [button addTarget:self action:@selector(testAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];
}

#pragma mark - 懒加载

#pragma mark - 重建UI

- (void)rebuildUI {

}

#pragma mark - 更新UI

- (void)updateUI {

}

#pragma mark - Setter

#pragma mark - Delegate

#pragma mark - 事件处理

- (void)testAction {
    TwoController *vc = [[TwoController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 通知处理

#pragma mark - 界面跳转

#pragma mark - API

@end
