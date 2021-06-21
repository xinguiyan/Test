//
//  TianyanchaManager.m
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

#import "TianyanchaManager.h"

@implementation TianyanchaManager

+ (NSArray *)getValuesWithSerial:(NSString *)serial name:(NSString *)name {
    NSString *href = [self getHrefWithName:name];
    if (![href isNotBlank]) {
        NSLog(@"找不到公司 : %@-%@", serial, name);
        return nil;
    }
    
    NSArray *values = [self getContentWithHref:href];
    
    if (values.count == 0) {
        values = [self getContentWithHref:href];
    }
    if (values.count == 0) {
        values = [self getContentWithHref:href];
    }
    if (values.count == 0) {
        NSLog(@"找不到公司2 : %@-%@", serial, name);
        return nil;
    }
    
    NSMutableArray *array = [NSMutableArray arrayWithArray:values];
    [array insertObject:name atIndex:1];
    
    return array;
}

+ (NSString *)getHrefWithName:(NSString *)name {
    NSString *urlStr = [NSString stringWithFormat:@"https://www.tianyancha.com/search?key=%@", name];
    urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSString *content = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    if (![content isNotBlank]) {
        return @"";
    }
    
    NSString *regStr = @"<a class=\"name select-none \"[\\s\\S]*?</a>";
//    NSString *regStr = @"<a[^>].*</a>";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regStr
                                                                           options:0
                                                                             error:nil];
    NSArray *matches = [regex matchesInString:content
                                      options:0
                                        range:NSMakeRange(0, content.length)];
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:matches.count];
    for (NSTextCheckingResult *match in matches) {
        NSString *substring = [content substringWithRange:match.range];
        [array addObject:substring];
    }
    
    NSString *href;
    for (NSString *substring in array) {
        NSMutableString *tmp = [NSMutableString stringWithString:substring];
        [tmp replaceOccurrencesOfString:@"<em>"
                             withString:@""
                                options:NSCaseInsensitiveSearch
                                  range:NSMakeRange(0, tmp.length)];
        [tmp replaceOccurrencesOfString:@"</em>"
                             withString:@""
                                options:NSCaseInsensitiveSearch
                                  range:NSMakeRange(0, tmp.length)];
        
        if ([tmp containsString:name]) {
            NSString *regStr = @"href=\"[^\"]*\"";
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regStr
                                                                                   options:0
                                                                                     error:nil];
            NSRange range = [regex rangeOfFirstMatchInString:substring
                                                     options:0
                                                       range:NSMakeRange(0, substring.length)];
            if (range.location != NSNotFound) {
                range.location += 6;
                range.length -= 7;
                href = [substring substringWithRange:range];
            }
            break;
        }
    }
    return href;
}

+ (NSArray *)getContentWithHref:(NSString *)href {
    NSURL *url = [NSURL URLWithString:href];
    NSString *content = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    
    // 截取table
    NSString *regStr = @"<table class=\"table -striped-col -breakall\"[\\s\\S]*<td>统一社会信用代码[\\s\\S]*?</table>";
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
//        @"企业名称",       // 1
        @"公司类型",       // 2
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
        NSString *regStr = [NSString stringWithFormat:@"<td[^>]*>[^<]*%@[\\s\\S]*?</td><td[^>]*>[\\s\\S]*?</td>", title];
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
//            } else if ([title isEqualToString:@"注册地址"]) {
//                content = [self contentOfRegisteredAddress:td];
            } else if ([title isEqualToString:@"注册资本"]) {
                content = [self contentOfRegisteredCapital:td];
            } else if ([title isEqualToString:@"经营范围"]) {
                content = [self contentOfBusinessScope:td];
            } else if ([title isEqualToString:@"营业期限"]) {
                content = [self contentOfBusinessTerm:td];
            } else if ([title isEqualToString:@"核准日期"]) {
                content = [self contentOfApprovalDate:td];
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

// 注册资本
+ (NSString *)contentOfRegisteredCapital:(NSString *)td {
    NSString *content;
    
    NSString *regStr = [NSString stringWithFormat:@"<div[^>]*>[^<]*?</div>"];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regStr
                                                                           options:0
                                                                             error:nil];
    NSRange range = [regex rangeOfFirstMatchInString:td
                                             options:0
                                               range:NSMakeRange(0, td.length)];
    if (range.location != NSNotFound) {
        content = [td substringWithRange:range];
        
        regStr = [NSString stringWithFormat:@">[^<]*<"];
        regex = [NSRegularExpression regularExpressionWithPattern:regStr
                                                          options:0
                                                            error:nil];
        range = [regex rangeOfFirstMatchInString:content
                                         options:0
                                           range:NSMakeRange(0, content.length)];
        
        if (range.location != NSNotFound) {
            range.location += 1;
            range.length -= 2;
            content = [content substringWithRange:range];
        }
    }
    
    return [content stringByTrim];
}

// 经营范围
+ (NSString *)contentOfBusinessScope:(NSString *)td {
    NSString *content;
    
    NSString *regStr = [NSString stringWithFormat:@"<span[^>]*>[^<]*?</span>"];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regStr
                                                                           options:0
                                                                             error:nil];
    NSRange range = [regex rangeOfFirstMatchInString:td
                                             options:0
                                               range:NSMakeRange(0, td.length)];
    if (range.location != NSNotFound) {
        content = [td substringWithRange:range];
        
        regStr = [NSString stringWithFormat:@">[^<]*<"];
        regex = [NSRegularExpression regularExpressionWithPattern:regStr
                                                          options:0
                                                            error:nil];
        range = [regex rangeOfFirstMatchInString:content
                                         options:0
                                           range:NSMakeRange(0, content.length)];
        
        if (range.location != NSNotFound) {
            range.location += 1;
            range.length -= 2;
            content = [content substringWithRange:range];
        }
    }
    
    return [content stringByTrim];
}

// 营业期限
+ (NSString *)contentOfBusinessTerm:(NSString *)td {
    NSString *content;
    
    NSString *regStr = [NSString stringWithFormat:@"<span[^>]*>[^<]*?</span>"];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regStr
                                                                           options:0
                                                                             error:nil];
    NSRange range = [regex rangeOfFirstMatchInString:td
                                             options:0
                                               range:NSMakeRange(0, td.length)];
    if (range.location != NSNotFound) {
        content = [td substringWithRange:range];
        
        regStr = [NSString stringWithFormat:@">[^<]*<"];
        regex = [NSRegularExpression regularExpressionWithPattern:regStr
                                                          options:0
                                                            error:nil];
        range = [regex rangeOfFirstMatchInString:content
                                         options:0
                                           range:NSMakeRange(0, content.length)];
        
        if (range.location != NSNotFound) {
            range.location += 1;
            range.length -= 2;
            content = [content substringWithRange:range];
        }
    }
    
    NSArray *array = [content componentsSeparatedByString:@"&nbsp;"];
    
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:array.count];
    for (NSString *tmp in array) {
        [result addObject:[tmp stringByTrim]];
    }
    
    content = [result componentsJoinedByString:@" "];
    
    
    return [content stringByTrim];
}

// 核准日期
+ (NSString *)contentOfApprovalDate:(NSString *)td {
    NSString *content;
    
    NSString *regStr = [NSString stringWithFormat:@"<text[^>]*>[^<]*?</text>"];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regStr
                                                                           options:0
                                                                             error:nil];
    NSRange range = [regex rangeOfFirstMatchInString:td
                                             options:0
                                               range:NSMakeRange(0, td.length)];
    if (range.location != NSNotFound) {
        content = [td substringWithRange:range];
        
        regStr = [NSString stringWithFormat:@">[^<]*<"];
        regex = [NSRegularExpression regularExpressionWithPattern:regStr
                                                          options:0
                                                            error:nil];
        range = [regex rangeOfFirstMatchInString:content
                                         options:0
                                           range:NSMakeRange(0, content.length)];
        
        if (range.location != NSNotFound) {
            range.location += 1;
            range.length -= 2;
            content = [content substringWithRange:range];
        }
    }
    
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:content.length];
    for (int i=0; i<content.length; i++) {
        NSString *tmp = [content substringWithRange:NSMakeRange(i, 1)];
        NSString *s = [self tycnum:tmp];
        [result addObject:s];
    }
    content = [result componentsJoinedByString:@""];
    
    
    return [content stringByTrim];
}

+ (NSString *)tycnum:(NSString *)num {
    if ([num isEqualToString:@"-"]) {
        return num;
    }
    
    NSString *s = @"";
    switch (num.intValue) {
        case 0:
            s = @"9";
            break;
        case 1:
            s = @"1";
            break;
        case 2:
            s = @"4";
            break;
        case 3:
            s = @"5";
            break;
        case 4:
            s = @"3";
            break;
        case 5:
            s = @"7";
            break;
        case 6:
            s = @"6";
            break;
        case 7:
            s = @"0";
            break;
        case 8:
            s = @"2";
            break;
        case 9:
            s = @"8";
            break;
        default:
            break;
    }
    return s;
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
