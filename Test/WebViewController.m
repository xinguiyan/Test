//
//  WebViewController.m
//  Test
//
//  Created by MMM on 2021/4/13.
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

#import "WebViewController.h"
#import <WebKit/WebKit.h>
#import <Masonry/Masonry.h>
#import "URLSchemeHandler.h"

@interface WebViewController ()

@property (nonatomic, strong) WKWebView *webView;


@end


@implementation WebViewController

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
    [self.view addSubview:self.webView];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
//    NSString *loadUrlString = [NSString stringWithFormat:@"%@", @"http://mmm-partnerh5-dev.fjmaimaimai.com"];
    NSString *loadUrlString = @"https://www.baidu.com/";
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:loadUrlString]]];
}

#pragma mark - 懒加载

- (WKWebView *)webView {
    if (!_webView) {
        _webView = ({
            // 初始化 webViewConfiguration
            WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];

            // 需要通过 webViewConfiguration 注册
            URLSchemeHandler *handler = [[URLSchemeHandler alloc] init];
            [configuration setURLSchemeHandler:handler forURLScheme:@"http"];
            [configuration setURLSchemeHandler:handler forURLScheme:@"https"];
            

            // ...其他配置
            // 初始化 WKWebView
            WKWebView *webView =
                [[WKWebView alloc] initWithFrame:self.view.frame configuration:configuration];
            webView;
        });
    }
    return _webView;
}

#pragma mark - 重建UI

- (void)rebuildUI {

}

#pragma mark - 更新UI

- (void)updateUI {

}

#pragma mark - Setter

#pragma mark - Delegate

#pragma mark - 事件处理

#pragma mark - 通知处理

#pragma mark - 界面跳转

#pragma mark - API

@end
