//
//  AQCController.m
//  Test
//
//  Created by yxg on 2023/8/8.
//

#import "AQCController.h"

static const NSArray *titles = @[
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

@interface AQCController ()

@end


@implementation AQCController

- (void)dealloc {
    NSLog(@"%s", __func__);
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	self.title = @"";

    [self initUI];
    
    NSLog(@"path : %@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]);
    
    NSArray *companys = [self readCsv];
    for (NSDictionary *dict in companys) {
        NSArray *values = dict[@"值"];
        if (values.count) {
            NSString *name = [NSString stringWithFormat:@"%@-%@", dict[@"序号"], dict[@"名称"]];
            [self writeToFile:name content:values];
        }
        [NSThread sleepForTimeInterval:0.1];
    }
    
    NSLog(@"结束啦");
}

#pragma mark - 初始化UI

- (void)initUI {

}

#pragma mark - 懒加载

#pragma mark - 更新UI

- (void)updateUI {

}

#pragma mark - Setter

#pragma mark - Delegate

#pragma mark - 事件处理

#pragma mark - 界面跳转

#pragma mark - API

#pragma mark - 内部方法

- (NSArray *)readCsv {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"csv"];
    NSError *error = nil;
    NSString *content = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:&error];
    NSArray *rows = [content componentsSeparatedByString:@"\r\n"];
    
    if (rows.count == 0) {
        NSLog(@"文件错误，行数为0");
        return nil;
    }
    
    NSInteger column_0 = NSNotFound; // 统一社会信用代码 所在列
    NSInteger column_1 = NSNotFound; // 企业名称 所在列
    NSInteger column_2 = NSNotFound; // 企业类型 所在列
    NSInteger column_3 = NSNotFound; // 注册地址 所在列
    NSInteger column_4 = NSNotFound; // 法定代表人 所在列
    NSInteger column_5 = NSNotFound; // 注册资本 所在列
    NSInteger column_6 = NSNotFound; // 成立日期 所在列
    NSInteger column_7 = NSNotFound; // 经营范围 所在列
    NSInteger column_8 = NSNotFound; // 登记机关 所在列
    NSInteger column_9 = NSNotFound; // 营业期限 所在列
    NSInteger column_10 = NSNotFound; // 核准日期 所在列

    NSString *string = [rows objectOrNilAtIndex:0]; // 第一行标题
    NSArray *vales = [string componentsSeparatedByString:@","];
    for (int i=0; i<vales.count; i++) {
        NSString *s = vales[i];
        if ([s containsString:@"统一社会信用代码"]) {
            column_0 = i;
        } else if ([s containsString:@"企业名称"]) {
            column_1 = i;
        } else if ([s containsString:@"企业类型"]) {
            column_2 = i;
        } else if ([s containsString:@"注册地址"]) {
            column_3 = i;
        } else if ([s containsString:@"法定代表人"]) {
            column_4 = i;
        } else if ([s containsString:@"注册资本"]) {
            column_5 = i;
        } else if ([s containsString:@"成立日期"]) {
            column_6 = i;
        } else if ([s containsString:@"经营范围"]) {
            column_7 = i;
        } else if ([s containsString:@"登记机关"]) {
            column_8 = i;
        } else if ([s containsString:@"营业期限"]) {
            column_9 = i;
        } else if ([s containsString:@"核准日期"]) {
            column_10 = i;
        }
    }
    
    if (column_0 == NSNotFound ||
        column_1 == NSNotFound ||
        column_2 == NSNotFound ||
        column_3 == NSNotFound ||
        column_4 == NSNotFound ||
        column_5 == NSNotFound ||
        column_6 == NSNotFound ||
        column_7 == NSNotFound ||
        column_8 == NSNotFound ||
        column_9 == NSNotFound ||
        column_10 == NSNotFound) {
        NSLog(@"缺少一些列");
        return nil;
    }
    
    NSMutableArray *companys = [NSMutableArray array];
    for (int i=1; i<rows.count-1; i++) {
        NSString *string = [rows objectOrNilAtIndex:i];

        NSArray *values = [string componentsSeparatedByString:@","];
        
        if (values.count < 11) {
            NSLog(@"序号 %d 有问题", i);
            continue;
        }
        
        NSArray *array = @[
            values[column_0],
            values[column_1],
            values[column_2],
            values[column_3],
            values[column_4],
            values[column_5],
            values[column_6],
            values[column_7],
            values[column_8],
            values[column_9],
            values[column_10],
        ];
        
        [companys addObject:@{
            @"序号": @(i),
            @"名称": values[column_1],
            @"值": array
        }];
    }
    return companys;
}

// 格式化企业类型
- (NSString *)formatType:(NSString *)type {
    NSString *string = type;
    string = [string stringByReplacingOccurrencesOfString:@"(" withString:@"（"];
    string = [string stringByReplacingOccurrencesOfString:@")" withString:@"）"];
    return string;
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
        if ([u isEqualToString:@"万人民币"]) {
            u = @"万元人民币";
        }
        if ([u isEqualToString:@"万(元)"]) {
            u = @"万元人民币";
        }
        
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
    NSString *string = @"";
    
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
    
    NSMutableArray *array = [NSMutableArray arrayWithArray:values];
    
    NSString *string = array[5]; // 注册资本
    array[5] = [self formatMoney:string];
    string = array[6]; // 成立日期
    array[6] = [self formatDate:string];
    {
        string = array[7]; // 经营范围
        if ([string hasPrefix:@"\""]) {
            string = [string substringFromIndex:1];
        }
        if ([string hasSuffix:@"\""]) {
            string = [string substringToIndex:string.length-1];
        }
        array[7] = string;
    }
    string = array[9]; // 营业期限
    if ([string isEqualToString:@"-"]) {
        string = [values[6] stringByAppendingString:@" 至 无固定期限"];
    }
    array[9] = [self formatTerm:string];
    string = array[2]; // 企业类型
    array[2] = [self formatType:string];
    
    NSString *date = array[10]; // 成立日期
    [array removeLastObject];
    NSArray *tmp = [date componentsSeparatedByString:@"-"];
    [array addObjectsFromArray:tmp];
    
    NSString *content = [array componentsJoinedByString:@"\r\n"];
    [content writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    // 二维码保存
//    NSString *url = [NSString stringWithFormat:@"https://www.chitus.com/ewm/createPc?config=%%7B%%22content%%22%%3A%%22http%%3A%%2F%%2Fwww.gsxt.gov.cn%%2Findex.html%%3Funiscid%%3D%@%%22%%7D&amp;auto_title=&amp;k=88859024993250", array[0]];
//    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
//    UIImage *image=[UIImage imageWithData:data];
    NSString *url = [NSString stringWithFormat:@"http://www.gsxt.gov.cn/index.html?uniscid=%@", array[0]];
    UIImage *image = [self createQRCodeWithURL:url];
    
    path = [dir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_qc.png", name]];
    [UIImagePNGRepresentation(image) writeToFile:path atomically:YES];
}

// 生成二维码
- (UIImage *)createQRCodeWithURL:(NSString *)URL {
    // 1.创建一个二维码滤镜实例
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    
    // 2.给滤镜添加数据
    NSString *targetStr = URL;
    NSData *targetData = [targetStr dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    [filter setValue:targetData forKey:@"inputMessage"];
    
    // 3.生成二维码
    CIImage *image = [filter outputImage];
    
    // 4.高清处理: size 要大于等于视图显示的尺寸
    UIImage *img = [self createNonInterpolatedUIImageFromCIImage:image size:310];
    
    return img;
}

- (UIImage *)createNonInterpolatedUIImageFromCIImage:(CIImage *)image size:(CGFloat)size {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    // 1.创建bitmap
    size_t width = CGRectGetWidth(extent)*scale;
    size_t height = CGRectGetHeight(extent)*scale;
    
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    //2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    
    return [UIImage imageWithCGImage:scaledImage];
}

@end
