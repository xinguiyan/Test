//
//  LocalQccManager.m
//  Test
//
//  Created by MMM on 2021/6/21.
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

#import "LocalQccManager.h"

@implementation LocalQccManager


+ (NSURL *)getURLOfName:(NSString *)name {
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *html = [doc stringByAppendingPathComponent:@"html"];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL isDirectory;
    BOOL isExit = [manager fileExistsAtPath:html isDirectory:&isDirectory];
    if (!isExit || !isDirectory) {
        NSLog(@"不存在html文件夹");
        return nil;
    }
    
    NSError *error;
    NSArray *contents = [manager contentsOfDirectoryAtPath:html error:&error];
    if (error) {
        NSLog(@"读取文件错误：%@", error);
        return nil;
    }
    
    NSString *fname;
    for (NSString *tmp in contents) {
        if ([tmp containsString:name]) {
            fname = tmp;
            break;
        }
    }
    
    if (![fname isNotBlank]) {
        return nil;
    }
    
    NSString *path = [html stringByAppendingPathComponent:fname];
    NSURL *url = [NSURL fileURLWithPath:path];
    return url;
}

+ (NSArray *)getValuesWithSerial:(NSString *)serial name:(NSString *)name {
    
    NSURL *url = [self getURLOfName:name];
    if (!url) {
        NSLog(@"找不到公司 : %@-%@", serial, name);
        return nil;
    }
    
    NSArray *values = [self getContentWithHref:url];
    if (values.count == 0) {
        NSLog(@"找不到公司2 : %@-%@", serial, name);
        return nil;
    }
    
    return values;
}

+ (NSArray *)getContentWithHref:(NSURL *)url {
    NSString *content = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    
    // 截取table
    NSString *regStr = @"<table class=\"ntable\">[\\s\\S]*统一社会信用代码</td>[\\s\\S]*?</table>";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regStr
                                                                           options:0
                                                                             error:nil];
    NSRange range = [regex rangeOfFirstMatchInString:content
                                             options:0
                                               range:NSMakeRange(0, content.length)];
    if (range.location != NSNotFound) {
        content = [content substringWithRange:range];
    }
    
    NSArray *titles = @[
        @"统一社会信用代码", // 0
        @"企业名称",       // 1
        @"企业类型",       // 2
        @"注册地址",       // 3
        @"法定代表人",     // 4
        @"注册资本",       // 5
        @"成立日期",       // 6
        @"经营范围",       // 7
        @"登记机关",       // 8
        @"营业期限",       // 9
        @"核准日期"        // 10
    ];
    NSMutableArray *values = [NSMutableArray array];
    for (NSString *title in titles) {
        NSString *regStr = [NSString stringWithFormat:@"<td[^>]*>[^<]*%@[^<]*</td> <td[^>]*>[\\s\\S]*?</td>", title];
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regStr
                                                                               options:0
                                                                                 error:nil];
        NSRange range = [regex rangeOfFirstMatchInString:content
                                                 options:0
                                                   range:NSMakeRange(0, content.length)];
        if (range.location != NSNotFound) {
            NSString *substring = [content substringWithRange:range];
            NSArray *array = [substring componentsSeparatedByString:@"/td>"];
            NSString *td = array[1];
            NSString *content;
            if ([title isEqualToString:@"法定代表人"]) {
                content = [self contentOfRepresentative:td];
            } else if ([title isEqualToString:@"注册地址"]) {
                content = [self contentOfRegisteredAddress:td];
            } else if ([title isEqualToString:@"营业期限"]) {
                content = [self contentOfBusinessTerm:td];
            } else {
                content = [self contentOfTd:td];
            }
            [values addObject:content];
//            NSLog(@"[%@] : [%@]", title, content);
        }
    }
    
    return values;
}

// 法定代表人
+ (NSString *)contentOfRepresentative:(NSString *)td {
    NSString *content;
    
    NSString *regStr = [NSString stringWithFormat:@"<a[^>]*>[^<]*?</a>"];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regStr
                                                                           options:0
                                                                             error:nil];
    NSRange range = [regex rangeOfFirstMatchInString:td
                                             options:0
                                               range:NSMakeRange(0, td.length)];
    if (range.location != NSNotFound) {
//        range.location += 1;
//        range.length -= 5;
        content = [td substringWithRange:range];
        
        regStr = [NSString stringWithFormat:@">[^<]*</a>"];
        regex = [NSRegularExpression regularExpressionWithPattern:regStr
                                                          options:0
                                                            error:nil];
        range = [regex rangeOfFirstMatchInString:content
                                         options:0
                                           range:NSMakeRange(0, content.length)];
        
        if (range.location != NSNotFound) {
            range.location += 1;
            range.length -= 5;
            content = [content substringWithRange:range];
        }
    }
    
    return [content stringByTrim];
}

// 注册地址
+ (NSString *)contentOfRegisteredAddress:(NSString *)td {
    NSArray *array = [td componentsSeparatedByString:@"<a"];
    NSString *content = array[1];
    
    NSString *regStr = [NSString stringWithFormat:@">[^<]*<"];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regStr
                                                                           options:0
                                                                             error:nil];
    NSRange range = [regex rangeOfFirstMatchInString:content
                                             options:0
                                               range:NSMakeRange(0, content.length)];
    if (range.location != NSNotFound) {
        range.location += 1;
        range.length -= 2;
        content = [content substringWithRange:range];
    }
    
    return [content stringByTrim];
}

// 营业期限
+ (NSString *)contentOfBusinessTerm:(NSString *)td {
    NSString *content;
    
    NSString *regStr = [NSString stringWithFormat:@">[^<]*<"];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regStr
                                                                           options:0
                                                                             error:nil];
    NSRange range = [regex rangeOfFirstMatchInString:td
                                             options:0
                                               range:NSMakeRange(0, td.length)];
    if (range.location != NSNotFound) {
        range.location += 1;
        range.length -= 2;
        content = [td substringWithRange:range];
    }
    
    content = [content stringByTrim];
    
    NSArray *array = [content componentsSeparatedByString:@"\n"];
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:array.count];
    for (NSString *tmp in array) {
        [results addObject:[tmp stringByTrim]];
    }
    return [results componentsJoinedByString:@" "];
}

+ (NSString *)contentOfTd:(NSString *)td {
    NSString *content;
    
    NSString *regStr = [NSString stringWithFormat:@">[^<]*<"];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regStr
                                                                           options:0
                                                                             error:nil];
    NSRange range = [regex rangeOfFirstMatchInString:td
                                             options:0
                                               range:NSMakeRange(0, td.length)];
    if (range.location != NSNotFound) {
        range.location += 1;
        range.length -= 2;
        content = [td substringWithRange:range];
    }
    
    return [content stringByTrim];
}

@end
