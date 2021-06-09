//
//  ViewController.m
//  Test
//
//  Created by MMM on 2021/1/4.
//

#import "ViewController.h"
#import "OneController.h"
#import "WebViewController.h"

#import <WebKit/WebKit.h>
#import <Masonry/Masonry.h>
#import <YYKit/YYKit.h>

#ifdef DEBUG
#define NSLog(FORMAT, ...) fprintf(stderr, "%s\n", [[NSString stringWithFormat: FORMAT, ## __VA_ARGS__] UTF8String]);
#else
#define NSLog(FORMAT, ...) nil
#endif

@interface ViewController () <WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    [button setTitle:@"首页" forState:UIControlStateNormal];
//    [button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
//    [button addTarget:self action:@selector(testAction) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:button];
//    [button mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.center.equalTo(self.view);
//    }];
    
//    [self initUI];
    
//    NSArray *companys = [self readCsv];
    NSArray *companys = @[
    @{@"serial": @"97", @"name": @"山西锦晟鼎建筑工程有限公司"},
    ];
    for (NSDictionary *dict in companys) {
        NSArray *values = [self getCompanyInfo:dict];
        if (values.count) {
            NSString *name = [NSString stringWithFormat:@"%@-%@", dict[@"serial"], dict[@"name"]];
            [self writeToFile:name content:values];
        }
        [NSThread sleepForTimeInterval:0.1];
    }
    
    NSLog(@"path : %@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]);
}

#pragma mark - 初始化UI

- (void)initUI {
    [self.view addSubview:self.webView];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
//    NSString *url = @"https://www.baidu.com/";
//    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]
//                                                  cachePolicy:NSURLRequestReloadRevalidatingCacheData
//                                              timeoutInterval:20];
//    [self.webView loadRequest:request];
    
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"1.xlsx"];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

#pragma mark - 懒加载

- (WKWebView *)webView {
    if (!_webView) {
        _webView = ({
            WKWebViewConfiguration*config = [[WKWebViewConfiguration alloc] init];
            config.preferences = [[WKPreferences alloc] init];
            config.preferences.minimumFontSize = 10;
            config.preferences.javaScriptCanOpenWindowsAutomatically = NO;
            
            WKWebView *webView= [[WKWebView alloc] initWithFrame:[UIScreen mainScreen].bounds configuration:config];
            webView.scrollView.bounces = NO;
            webView.navigationDelegate = self;
            webView;
        });
    }
    return _webView;
}

#pragma mark - WKNavigationDelegate

// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [webView evaluateJavaScript:@"document.body.innerText"
              completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"\r\nresult : \r\n%@\r\n", result);
    }];
}

// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"error");
}

#pragma mark - 事件处理

- (void)testAction {
//    OneController *vc = [[OneController alloc] init];
    WebViewController *vc = [[WebViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 内部方法

- (NSArray *)readCsv {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"csv"];
    NSError *error = nil;
    NSString *content = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:&error];
    NSArray *rows = [content componentsSeparatedByString:@"\r\n"];
    
    // 每行内容拆分
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:rows.count];
    for (NSString *s in rows) {
        NSArray *a = [s componentsSeparatedByString:@","];
        if (a) {
            [array addObject:a];
        }
    }
    // 获取公司名称
    NSInteger column = NSNotFound; // 企业名称所在列
    NSInteger serial_column = NSNotFound;
    NSArray *a = [array objectOrNilAtIndex:0];
    if (a) {
        for (NSString *s in a) {
            if ([s containsString:@"公司"] && column==NSNotFound) {
                column = [a indexOfObject:s];
            } else if ([s containsString:@"序号"]) {
                serial_column = [a indexOfObject:s];
            }
        }
    }
    NSMutableArray *companys = [NSMutableArray array];
    if (column != NSNotFound) {
        for (int i=1; i<array.count; i++) {
            NSArray *a = [array objectOrNilAtIndex:i];
            if (a) {
                NSString *name = [a objectOrNilAtIndex:column];
                NSString *serial = [NSString stringWithFormat:@"%d", i]; // [a objectOrNilAtIndex:serial_column];
                if ([name isNotBlank]) {
//                    [names addObject:name];
                    NSDictionary *dict = @{
                        @"serial": serial,
                        @"name": name,
                    };
                    [companys addObject:dict];
                }
            }
        }
    } else {
        NSLog(@"表格不包含公司表");
    }
//    NSLog(@"names : %@", names);
//    NSLog(@"count : %ld", names.count);
    return companys;
}

- (NSArray *)getCompanyInfo:(NSDictionary *)dict {
    NSString *name = dict[@"name"];
    NSString *serial = dict[@"serial"];
    NSString *href = [self getHrefWithName:name];
    if (![href isNotBlank]) {
        NSLog(@"找不到公司 : %@-%@", serial, name);
        return nil;
    }
    
    NSArray *values = [self getContentWithHref:href];
    return values;
}

- (NSString *)getHrefWithName:(NSString *)name {
    NSString *urlStr = [NSString stringWithFormat:@"https://www.qcc.com/web/search?key=%@", name];
    urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSString *content = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    if (![content isNotBlank]) {
        return @"";
    }
    
    NSString *regStr = @"<a[^>]*class=\"title\".*</a>";
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

- (NSArray *)getContentWithHref:(NSString *)href {
    NSURL *url = [NSURL URLWithString:href];
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
            } else {
                content = [self contentOfTd:td];
            }
            [values addObject:content];
//            NSLog(@"[%@] : [%@]", title, content);
        }
    }
    
    return values;
}

- (NSString *)contentOfRepresentative:(NSString *)td {
    NSString *content;
    
    NSString *regStr = [NSString stringWithFormat:@">[^<]*</h2>"];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regStr
                                                                           options:0
                                                                             error:nil];
    NSRange range = [regex rangeOfFirstMatchInString:td
                                             options:0
                                               range:NSMakeRange(0, td.length)];
    if (range.location != NSNotFound) {
        range.location += 1;
        range.length -= 6;
        content = [td substringWithRange:range];
    }
    
    return [content stringByTrim];
}

- (NSString *)contentOfTd:(NSString *)td {
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

// 格式化注册资本
- (NSString *)formatMoney:(NSString *)money {
    NSString *string = money;
    
    NSString *regStr = [NSString stringWithFormat:@"[0-9.]*"];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regStr
                                                                           options:0
                                                                             error:nil];
    NSRange range = [regex rangeOfFirstMatchInString:money
                                             options:0
                                               range:NSMakeRange(0, money.length)];
    if (range.location != NSNotFound) {
        NSString *f = [money substringWithRange:range];
        NSString *u = [money substringFromIndex:range.location+range.length];
        
        NSRange r = [f rangeOfString:@"."];
        if (r.location != NSNotFound) {
            NSInteger n = f.length - r.location - 1;
            for (int i=0; i<6-n; i++) {
                f = [f stringByAppendingString:@"0"];
            }
        } else {
            f = [f stringByAppendingString:@".000000"];
        }
        
        string = [NSString stringWithFormat:@"%@%@", f, u];
    }
    
    return string;
}

// 格式化日期
- (NSString *)formatDate:(NSString *)date {
    if ([date isEqualToString:@"-"]) {
        return @"-";
    }
    
    NSString *string;
    
    NSArray *array = [date componentsSeparatedByString:@"-"];
    if (array.count != 3) {
        return string;
    }
    
    string = [NSString stringWithFormat:@"%@年%@月%@日", array[0], array[1], array[2]];
//    NSLog(@"string : [%@]", string);
    
    return string;
}

// 格式化营业期限
- (NSString *)formatTerm:(NSString *)term {
    NSString *string;
    
    NSArray *array = [term componentsSeparatedByString:@" 至 "];
    if (array.count != 2) {
        return string;
    }
    
    NSString *start = [self formatDate:array[0]];
    NSString *end;
    if ([array[1] isEqualToString:@"无固定期限"]) {
        end = @"长期";
    } else {
        end = [self formatDate:array[1]];
    }
    
    string = [NSString stringWithFormat:@"%@ 至 %@", start, end];
//    NSLog(@"string : [%@]", string);
    
    return string;
}

// 写入文件
- (void)writeToFile:(NSString *)name content:(NSArray *)values {
    if (values.count != 11) {
        NSLog(@"%@ 公司有问题", name);
        return;
    }
    
    NSString *dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    dir = [dir stringByAppendingPathComponent:@"ZZ"];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager createDirectoryAtPath:dir
       withIntermediateDirectories:YES
                        attributes:nil
                             error:nil];
    
    NSString *path = [dir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt", name]];
    BOOL isExit = [manager fileExistsAtPath:path];
    if (!isExit) {
        [manager createFileAtPath:path contents:nil attributes:nil];
    }
    
    /*
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
     */
    
    NSMutableArray *array = [NSMutableArray arrayWithArray:values];
    
    NSString *string = array[5];
    array[5] = [self formatMoney:string];
    string = array[6];
    array[6] = [self formatDate:string];
    string = array[9];
    array[9] = [self formatTerm:string];
    
    NSString *date = array[10]; // 成立日期
    [array removeLastObject];
    NSArray *tmp = [date componentsSeparatedByString:@"-"];
    [array addObjectsFromArray:tmp];
    
    NSString *content = [array componentsJoinedByString:@"\r\n"];
    [content writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    // 二维码保存
    NSString *url = [NSString stringWithFormat:@"https://www.chitus.com/ewm/create?config=%%7B%%22content%%22%%3A%%22http%%3A%%2F%%2Fwww.gsxt.gov.cn%%2Findex.html%%3Funiscid%%3D%@%%22%%7D", array[0]];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    UIImage *image=[UIImage imageWithData:data];
    
    path = [dir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_qc.png", name]];
    [UIImagePNGRepresentation(image) writeToFile:path atomically:YES];
}

@end
