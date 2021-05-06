//
//  WKWebView+Custom.m
//  Test
//
//  Created by MMM on 2021/4/13.
//

#import "WKWebView+Custom.h"
#import <objc/runtime.h>

@implementation WKWebView (Custom)

/*
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method originalMethod1 = class_getClassMethod(self, @selector(handlesURLScheme:));
        Method swizzledMethod1 = class_getClassMethod(self, @selector(mmm_handlesURLScheme:));
        method_exchangeImplementations(originalMethod1, swizzledMethod1);
    });
}

+ (BOOL)mmm_handlesURLScheme:(NSString *)urlScheme {
    if ([urlScheme isEqualToString:@"http"] || [urlScheme isEqualToString:@"https"]) {
        return NO;  //这里让返回NO,应该是默认不走系统断言或者其他判断啥的
    } else {
        return [self mmm_handlesURLScheme:urlScheme];
    }
}
 */

@end
