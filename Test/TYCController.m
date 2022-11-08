//
//  TYCController.m
//  Test
//
//  Created by linxj on 2022/11/8.
//

#import "TYCController.h"

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

@interface TYCController ()

@end


@implementation TYCController

- (void)dealloc {
    NSLog(@"%s", __func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"";
    self.view.backgroundColor = UIColor.whiteColor;

    [self initUI];
    
    NSLog(@"path : %@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]);
    
    NSArray *companys = [self mergeCsv];
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

#pragma mark - 内部方法

/**
 ,"1,000万(元)", | ,"有限责任公司（自然人投资或控股）    ",
 双引号内
 【,】需要替换成【₱】；
 【  】删掉
 */
- (NSString *)csvString:(NSString *)csv {
    NSString *string = csv;
    
    NSString *regStr = @",\"[\\s\\S]*?\",";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regStr
                                                                           options:0
                                                                             error:nil];
    NSRange range = [regex rangeOfFirstMatchInString:string
                                             options:0
                                               range:NSMakeRange(0, string.length)];
    while (range.location != NSNotFound) {
        NSString *substring = [string substringWithRange:NSMakeRange(range.location+2, range.length-4)];
        substring = [substring stringByReplacingOccurrencesOfString:@"," withString:@"₱"];
        substring = [NSString stringWithFormat:@",%@,", substring];
        
        string = [string stringByReplacingCharactersInRange:range withString:substring];
        
        range = [regex rangeOfFirstMatchInString:string
                                         options:0
                                           range:NSMakeRange(0, string.length)];
    }
    
    // 匹配最后一个
    regStr = @",\"[\\s\\S]*?\"$";
    regex = [NSRegularExpression regularExpressionWithPattern:regStr
                                                      options:0
                                                        error:nil];

    range = [regex rangeOfFirstMatchInString:string
                                     options:0
                                       range:NSMakeRange(0, string.length)];
    if (range.location != NSNotFound) {
        NSString *substring = [string substringWithRange:NSMakeRange(range.location+2, range.length-3)];
        substring = [substring stringByReplacingOccurrencesOfString:@"," withString:@"₱"];
        substring = [NSString stringWithFormat:@",%@", substring];
        
        string = [string stringByReplacingCharactersInRange:range withString:substring];
    }
    
    return string;
}

- (NSString *)restoreCsv:(NSString *)csv {
    return [[csv stringByReplacingOccurrencesOfString:@"₱" withString:@","] stringByTrim];
}

- (NSArray *)readCsv1 {
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
        column_9 == NSNotFound) {
        NSLog(@"缺少一些列");
        return nil;
    }
    
    NSMutableArray *companys = [NSMutableArray array];
    for (int i=1; i<rows.count-1; i++) {
        NSString *string = [rows objectOrNilAtIndex:i];
        string = [self csvString:string];

        NSArray *values = [string componentsSeparatedByString:@","];
        
        if (values.count < 11) {
            NSLog(@"序号 %d 有问题", i);
            continue;
        }
        
        NSDictionary *dict = @{
            @"统一社会信用代码": [self restoreCsv:values[column_0]],
            @"企业名称": [self restoreCsv:values[column_1]],
            @"企业类型": [self restoreCsv:values[column_2]],
            @"注册地址": [self restoreCsv:values[column_3]],
            @"法定代表人": [self restoreCsv:values[column_4]],
            @"注册资本": [self restoreCsv:values[column_5]],
            @"成立日期": [self restoreCsv:values[column_6]],
            @"经营范围": [self restoreCsv:values[column_7]],
            @"登记机关": [self restoreCsv:values[column_8]],
            @"营业期限": [self restoreCsv:values[column_9]]
        };
        
        [companys addObject:dict];
    }
    return companys;
}

- (NSArray *)readCsv2 {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"1-1" ofType:@"csv"];
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
        string = [self csvString:string];
        
        NSArray *values = [string componentsSeparatedByString:@","];
        
        if (values.count < 11) {
            NSLog(@"行号 ： %d 有问题", i);
            continue;
        }
        
        NSDictionary *dict = @{
            @"统一社会信用代码": [self restoreCsv:values[column_0]],
            @"企业名称": [self restoreCsv:values[column_1]],
            @"企业类型": [self restoreCsv:values[column_2]],
            @"注册地址": [self restoreCsv:values[column_3]],
            @"法定代表人": [self restoreCsv:values[column_4]],
            @"注册资本": [self restoreCsv:values[column_5]],
            @"成立日期": [self restoreCsv:values[column_6]],
            @"经营范围": [self restoreCsv:values[column_7]],
            @"登记机关": [self restoreCsv:values[column_8]],
            @"营业期限": [self restoreCsv:values[column_9]],
            @"核准日期": [self restoreCsv:values[column_10]]
        };
        
        [companys addObject:dict];
    }

    return companys;
}

- (NSArray *)mergeCsv {
    NSMutableArray *array = [NSMutableArray array];
    
    NSArray *csv1 = [self readCsv1];
    NSArray *csv2 = [self readCsv2];
    
    
    
    for (int i=0; i<csv1.count; i++) {
        NSDictionary *dic1 = csv1[i];
        
        BOOL error = NO;
        
        for (int j=0; j<csv2.count; j++) {
            NSDictionary *dic2 = csv2[j];
            if ([dic2[@"企业名称"] isEqualToString:dic1[@"企业名称"]]) {

                /*
                NSString *key = @"核准日期";
                if ([dic2[key] isNotBlank] &&
                    [dic1[key] isNotBlank] &&
                    ![dic2[key] isEqualToString:dic1[key]]) {
                        NSLog(@"【%d】%@ ：\n【%@】\n【%@】",
                              i,
                              dic1[@"企业名称"],
                              dic1[key],
                              dic2[key]);
                }
                 */
                
                NSMutableArray *values = [NSMutableArray arrayWithCapacity:titles.count];
                for (int k=0; k<titles.count; k++) {
                    NSString *key = titles[k];
                    if ([key isEqualToString:@"登记机关"]) {
                        if ([dic1[@"登记机关"] isNotBlank]) {
                            [values addObject:dic1[@"登记机关"]];
                        } else {
                            error = YES;
                            NSLog(@"【%d】【%@】登记机关 为空", i, dic1[@"企业名称"]);
                            break;
                        }
                    } else {
                        if ([dic2[key] isNotBlank]) {
                            [values addObject:dic2[key]];
                        } else {
                            error = YES;
                            NSLog(@"【%d】【%@】%@ 为空", i, dic1[@"企业名称"], key);
                            break;
                        }
                    }
                }
                
                if (error) {
                    break;
                } else {
                    [array appendObject:@{
                        @"序号": @(i+1),
                        @"名称": dic1[@"企业名称"],
                        @"值": values
                    }];
                }
            }
        }
    }

    return array;
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
    
    NSString *string = array[5];
    array[5] = [self formatMoney:string];
    string = array[6];
    array[6] = [self formatDate:string];
    string = array[9];
    array[9] = [self formatTerm:string];
    string = array[2];
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
