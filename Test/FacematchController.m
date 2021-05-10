//
//  FacematchController.m
//  Test
//
//  Created by MMM on 2021/5/5.
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

#import "FacematchController.h"

//#import <Masonry/Masonry.h>
//#import <YYKit/YYKit.h>
//#import <SVProgressHUD/SVProgressHUD.h>
//#import "MMLocationParser.h"

#import "JQUploadPicRequest.h"
#import "BRAddressModel.h"

@interface FacematchController ()

@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, assign) NSInteger faceIndex;

@property (nonatomic, copy) NSArray *users;
@property (nonatomic, assign) NSInteger index;

@property (nonatomic, copy) NSArray *provinceModelArr;

@end


@implementation FacematchController

- (void)dealloc {
    NSLog(@"%s", __func__);
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	self.title = @"";
    self.view.backgroundColor = UIColor.whiteColor;

//    self.faceIndex = 0;
//    [self initUI];
    
    [self getAddressList];
    
    NSLog(@"path : %@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]);
    NSArray *users = [self readCsv];
    [self getAgesOfUsers:users];
    
//    for (int i=0; i<100; i++) {
//        NSLog(@"%@", [self calcDate:@[@"",@"",@"",@"",@"",@"",@"1984",@"05",@"23"] age:18]);
//    }
    
//    NSLog(@"%@", [self organOfAddress:@"辽宁省本溪满族自治县观音阁向阳街南二巷6号2-1"]);
}

#pragma mark - Notification

#pragma mark - 初始化UI

- (void)initUI {
    [self.view addSubview:self.headImageView];
    [self.headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(100);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(125);
    }];
    
    [self changeFace];
}

#pragma mark - 懒加载

- (UIImageView *)headImageView {
    if (!_headImageView) {
        _headImageView  = ({
            UIImage *image = [UIImage imageNamed:@""];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            imageView;
        });
    }
    return _headImageView;
}

#pragma mark - 更新UI

- (void)updateUI {

}

- (void)changeFace {
    self.faceIndex++;
    if (self.faceIndex > 20) {
        return;
    }
    
    NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%ld", self.faceIndex]
                                                     ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    self.headImageView.image = image;
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@"mYiEK5EzegjJP1VNg-4FoTHqFhvaZExQ" forKey:@"api_key"];
    [dict setObject:@"ld2rYGcpwRZdrvX-bsJoz_Fow-KKnCz5" forKey:@"api_secret"];
//    [dict setObject:@"http://avatar.csdn.net/5/7/E/1_qq_31810357.jpg" forKey:@"image_url"];
    [dict setObject:@"0" forKey:@"return_landmark"]; // 检测 83个点返回结果,1检测, 0不检测
    // 根据人脸特征判断出的年龄，性别，微笑、人脸质量等属性
    [dict setObject:@"gender,age" forKey:@"return_attributes"]; // 检测属性
    
    [JQUploadPicRequest requestToUploadImage:image parmete:dict completion:^(NSDictionary * responDic, NSError *error) {
//        NSLog(@"%@",responDic);
        if ([responDic[@"faces"] count] != 0) {
            NSDictionary *dict = ((NSArray *)responDic[@"faces"]).firstObject;
            NSInteger age = [dict[@"attributes"][@"age"][@"value"] intValue];
            NSString *gender = dict[@"attributes"][@"gender"][@"value"];
            
            NSString *string = [NSString stringWithFormat:@"%@ %ld岁", [gender isEqualToString:@"Female"]?@"女":@"男", age];
            [SVProgressHUD showSuccessWithStatus:string];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self changeFace];
            });
        } else {
            NSLog(@"错误返回");
        }
    }];
}

#pragma mark - Setter

#pragma mark - Delegate

#pragma mark - 事件处理

#pragma mark - 通知处理

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
    
    // 每行内容拆分
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:rows.count];
    for (NSString *s in rows) {
        NSArray *a = [s componentsSeparatedByString:@","];
        if (a) {
            [array addObject:a];
        }
    }
    
    // 列
    NSInteger serial = NSNotFound;  // 序号
    NSInteger name = NSNotFound;    // 名字
    NSInteger gender = NSNotFound;  // 性别
    NSInteger address = NSNotFound; // 地址
    NSInteger cid = NSNotFound;     // 证件号码
    
    NSArray *a = [array objectOrNilAtIndex:0];
    if (a) {
        serial = [a indexOfObject:@"序号"];
        name = [a indexOfObject:@"姓名"];
        gender = [a indexOfObject:@"性别"];
        address = [a indexOfObject:@"个人地址"];
        cid = [a indexOfObject:@"证件号码"];
    }
    
    if (serial == NSNotFound || name == NSNotFound || gender == NSNotFound ||
        address == NSNotFound || cid == NSNotFound) {
        NSLog(@"表格缺少指定列名");
        return nil;
    }
    
    NSMutableArray *users = [NSMutableArray arrayWithCapacity:array.count-1];
    for (int i=1; i<array.count; i++) {
        NSArray *a = [array objectOrNilAtIndex:i];
        if (a) {
            NSString *s1 = [a objectOrNilAtIndex:serial];
            NSString *s2 = [a objectOrNilAtIndex:name];
            if ([s1 isNotBlank] && [s2 isNotBlank]) {
                NSString *s3 = [a objectOrNilAtIndex:cid];
                if (s3.length != 18) {
                    NSLog(@"%@-%@ : 【%@】 身份证有问题", s1, s2, s3);
                    continue;
                }
                NSString *year = [s3 substringWithRange:NSMakeRange(6, 4)];
                NSString *month = [s3 substringWithRange:NSMakeRange(10, 2)];
                NSString *day = [s3 substringWithRange:NSMakeRange(12, 2)];
                
                if ([month hasPrefix:@"0"]) {
                    month = [month substringFromIndex:1];
                }
                if ([day hasPrefix:@"0"]) {
                    day = [day substringFromIndex:1];
                }
                
                NSString *s4 = [a objectOrNilAtIndex:address];
                NSString *organ = [self organOfAddress:s4];
                if (![organ isNotBlank]) {
                    NSLog(@"%@-%@ : 【%@】 111地址有问题", s1, s2, s4);
                    
                    organ = [self organOfAddress2:s4];
                    if (![organ isNotBlank]) {
                        NSLog(@"%@-%@ : 【%@】 222地址有问题", s1, s2, s4);
                        continue;
                    }
                }
                if ([s4 containsString:@"新区"]) {
//                    NSLog(@"%@-%@ : 【%@】 新区注意查看", s1, s2, s4);
                }
                if (![s4 containsString:@"省"] || ![s4 containsString:@"巿"]) {
//                    NSLog(@"%@-%@ : 【%@】 缺少省市，注意查看", s1, s2, s4);
                }
                
                NSArray *values = @[
                    [a objectOrNilAtIndex:serial],
                    [a objectOrNilAtIndex:name],
                    [a objectOrNilAtIndex:gender],
                    [a objectOrNilAtIndex:address],
                    [a objectOrNilAtIndex:cid],
                    organ,
                    year, month, day,
                ];
                [users addObject:values];
            }
        }
    }
    return users;
}

// 有市有区  写 1.某某市公安局某某分局  2.有市没区有县  只要写某某县公安局    有市没区没县  只要县某某市公安局
// 还有某某区分局的情况  还分为  一个字要加区字然后分局    一个字以上不包含一个字的要去掉区
- (NSString *)organOfAddress:(NSString *)address {
    NSString *organ;
    
    NSArray *array = [self getSSQOfAddress:address];
    if (array.count == 0) {
        return organ;
    }
    
    NSString *city = array[1];
    NSString *qu = array[2];
    NSString *xian = array[2];
    
    BOOL hasCity = [city isNotBlank];
    BOOL hasQu = [qu hasSuffix:@"区"];
    BOOL hasXian = [xian hasSuffix:@"县"];
    
    if (hasQu && qu.length >= 3) {
        qu = [qu substringToIndex:qu.length-1];
    }
    
    if (hasXian) {
        organ = [NSString stringWithFormat:@"%@公安局", xian];
    } else if (hasCity) {
        if (hasQu) {
            organ = [NSString stringWithFormat:@"%@公安局%@分局", city, qu];
        } else {
            organ = [NSString stringWithFormat:@"%@公安局", city];
        }
    }
    
    return organ;
}

- (NSString *)organOfAddress2:(NSString *)address {
    NSString *organ;
    
    MMLocationParser *parser = [MMLocationParser parserWithLoation:address];
//    NSLog(@"%@",parser.location);
//    NSLog(@"输出:");
//    NSLog(@"province: %@",parser.province); // 省、自治区、直辖市、特别行政区
//    NSLog(@"city:     %@",parser.city); // 市、自治州、地区、行政单位
//    NSLog(@"area:     %@",parser.area); // 区、县、旗、海域、岛
//    NSLog(@"town:     %@",parser.town); // 乡、镇
//    NSLog(@"street:   %@",parser.street); // 街道信息以及楼号、门牌号等
//    NSLog(@"name:     %@",parser.name); // 乡镇 + 街道信息以及楼号、门牌号等
    
    BOOL hasCity = [parser.city isNotBlank];
    BOOL hasQu = [parser.area hasSuffix:@"区"];
    BOOL hasXian = [parser.area hasSuffix:@"县"];
    
    NSString *city = parser.city;
    NSString *qu = parser.area;
    NSString *xian = parser.area;
    
    if (hasQu && qu.length >= 3) {
        qu = [qu substringToIndex:qu.length-1];
    }
    
    if (hasXian) {
        organ = [NSString stringWithFormat:@"%@公安局", xian];
    } else if (hasCity) {
        if (hasQu) {
            organ = [NSString stringWithFormat:@"%@公安局%@分局", city, qu];
        } else {
            organ = [NSString stringWithFormat:@"%@公安局", city];
        }
    }
    
    return organ;
}

- (void)getAgesOfUsers:(NSArray *)users {
    self.users = users;
    self.index = -1;
    
    [self getNextUser];
}

- (void)getNextUser {
    self.index++;
    if (self.index >= self.users.count) {
        return;
    }
    
    NSArray *user = self.users[self.index];
    [self getAge:user];
}

- (void)getAge:(NSArray *)userInfo {
    NSString *serial = userInfo[0]; // 用户序号，对应照片名
    
    NSString *path = [[NSBundle mainBundle] pathForResource:serial ofType:@"png"];
    if (![path isNotBlank]) {
//        NSLog(@"找不到序号：【%@】的照片", serial);
        [self getNextUser];
        return;
    }
    
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@"mYiEK5EzegjJP1VNg-4FoTHqFhvaZExQ" forKey:@"api_key"];
    [dict setObject:@"ld2rYGcpwRZdrvX-bsJoz_Fow-KKnCz5" forKey:@"api_secret"];
//    [dict setObject:@"http://avatar.csdn.net/5/7/E/1_qq_31810357.jpg" forKey:@"image_url"];
    [dict setObject:@"0" forKey:@"return_landmark"]; // 检测 83个点返回结果,1检测, 0不检测
    // 根据人脸特征判断出的年龄，性别，微笑、人脸质量等属性
    [dict setObject:@"gender,age" forKey:@"return_attributes"]; // 检测属性
    
    [JQUploadPicRequest requestToUploadImage:image parmete:dict completion:^(NSDictionary * responDic, NSError *error) {
        if ([responDic[@"faces"] count] != 0) {
            NSDictionary *dict = ((NSArray *)responDic[@"faces"]).firstObject;
            NSInteger age = [dict[@"attributes"][@"age"][@"value"] intValue];
            NSString *time = [self calcDate:userInfo age:age];
            
            NSMutableArray *array = [NSMutableArray arrayWithArray:userInfo];
            [array addObject:time];
            [array addObject:[NSString stringWithFormat:@"%ld", age]];
            
            // 性别判断
            NSString *gender = dict[@"attributes"][@"gender"][@"value"];
            NSString *string = [gender isEqualToString:@"Female"] ? @"女" : @"男";
            if (![userInfo[2] isEqualToString:string]) {
                NSLog(@"%@-%@ : 【%@】 性别有问题", userInfo[0], userInfo[1], userInfo[2]);
            }
            
            [self writeToFile:array];
        } else {
            NSLog(@"面部识别返回错误：【%@】", serial);
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self getNextUser];
        });
    }];
}

// 计算签发日期
- (NSString *)calcDate:(NSArray *)userInfo age:(NSInteger)age {
    NSInteger y = [userInfo[6] intValue]; // 身份证年份
    NSInteger m = [userInfo[7] intValue];
    NSInteger d = [userInfo[8] intValue];
    NSDate *birthday = [NSDate dateWithString:[NSString stringWithFormat:@"%ld.%02ld.%02ld", y, m, d]
                                       format:@"yyyy.MM.dd"];
    
    NSDate *now = NSDate.now;
    
    
    NSDate *start = [birthday dateByAddingYears:age];
    NSDate *end;
    
    while (true) {
        if ([start timeIntervalSinceNow] > 0) {
            NSInteger r = arc4random() % (365 * 2);
            start = [now dateByAddingDays:-r];
            end = [self endOfValid:start birthday:birthday];
        } else {
            NSInteger r = arc4random() % 365;
            start = [start dateByAddingDays:-r];
            end = [self endOfValid:start birthday:birthday];
        }
        
        if (end && [end timeIntervalSinceNow] < 0) {
            start = [start dateByAddingYears:1];
        } else {
            break;
        }
    }
    
    return [NSString stringWithFormat:@"%@-%@",
                [start stringWithFormat:@"yyyy.MM.dd"],
                end ? [end stringWithFormat:@"yyyy.MM.dd"] : @"长期"];
}

- (NSDate *)endOfValid:(NSDate *)start birthday:(NSDate *)birthday {
    // 计算周岁
    NSInteger age = start.year - birthday.year;
    if ([[birthday dateByAddingYears:age] timeIntervalSinceDate:start] > 0) {
        age--;
    }
    
    NSDate *end;
    if (age < 16) {
        end = [start dateByAddingYears:5];
    } else if (age < 25) {
        end = [start dateByAddingYears:10];
    } else if (age < 45) {
        end = [start dateByAddingYears:20];
    }
    return end;
}

- (void)writeToFile:(NSArray *)values {
    NSString *name = [NSString stringWithFormat:@"%@-%@", values[0], values[1]];
    
    NSString *dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [dir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt", name]];
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL isExit = [manager fileExistsAtPath:path];
    if (!isExit) {
        [manager createFileAtPath:path contents:nil attributes:nil];
    }
    
    NSString *content = [values componentsJoinedByString:@"\r\n"];
    [content writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
//    NSLog(@"values : %@", values);
}

#pragma mark - 地址

- (void)getAddressList {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"BRCity" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSArray *cityArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    self.provinceModelArr = [self getProvinceModelArr:cityArray];
}

- (NSArray <BRProvinceModel *>*)getProvinceModelArr:(NSArray *)dataSourceArr {
    NSMutableArray *tempArr1 = [NSMutableArray array];
    for (NSDictionary *proviceDic in dataSourceArr) {
        BRProvinceModel *proviceModel = [[BRProvinceModel alloc]init];
        proviceModel.code = [proviceDic objectForKey:@"code"];
        proviceModel.name = [proviceDic objectForKey:@"name"];
        proviceModel.index = [dataSourceArr indexOfObject:proviceDic];
        NSArray *cityList = [proviceDic.allKeys containsObject:@"cityList"] ? [proviceDic objectForKey:@"cityList"] : [proviceDic objectForKey:@"citylist"];
        NSMutableArray *tempArr2 = [NSMutableArray array];
        for (NSDictionary *cityDic in cityList) {
            BRCityModel *cityModel = [[BRCityModel alloc]init];
            cityModel.code = [cityDic objectForKey:@"code"];
            cityModel.name = [cityDic objectForKey:@"name"];
            cityModel.index = [cityList indexOfObject:cityDic];
            NSArray *areaList = [cityDic.allKeys containsObject:@"areaList"] ? [cityDic objectForKey:@"areaList"] : [cityDic objectForKey:@"arealist"];
            NSMutableArray *tempArr3 = [NSMutableArray array];
            for (NSDictionary *areaDic in areaList) {
                BRAreaModel *areaModel = [[BRAreaModel alloc]init];
                areaModel.code = [areaDic objectForKey:@"code"];
                areaModel.name = [areaDic objectForKey:@"name"];
                areaModel.index = [areaList indexOfObject:areaDic];
                [tempArr3 addObject:areaModel];
            }
            cityModel.arealist = [tempArr3 copy];
            [tempArr2 addObject:cityModel];
        }
        proviceModel.citylist = [tempArr2 copy];
        [tempArr1 addObject:proviceModel];
    }
    return [tempArr1 copy];
}

- (NSArray *)getSSQOfAddress:(NSString *)address {
    if (![address isNotBlank]) {
        return nil;
    }
    
    NSArray *zzq = @[@"内蒙古",@"新疆",@"广西",@"西藏",@"宁夏"]; // 自治区
    NSArray *zxs = @[@"北京",@"上海",@"天津",@"重庆"]; // 直辖市
    NSArray *tbxzq = @[@"香港", @"澳门", @"台湾"]; // 特别行政区
    
    NSString *p;
    NSString *c;
    NSString *a;
    NSString *o;
    for (BRProvinceModel *province in self.provinceModelArr) {
        if ([address hasPrefix:province.name]) {
            NSString *tmp = [address substringFromIndex:province.name.length];
            if ([zzq containsObject:province.name]) {
                if ([tmp hasPrefix:@"自治区"]) {
                    tmp = [tmp substringFromIndex:3];
                }
                p = province.name;
            } else if ([zxs containsObject:province.name] || [tbxzq containsObject:province.name]) {
                tmp = address;
                p = @"";
            } else {
                if ([tmp hasPrefix:@"省"]) {
                    tmp = [tmp substringFromIndex:1];
                }
                p = [province.name stringByAppendingString:@"省"];
            }
            
            for (BRCityModel *city in province.citylist) {
                if ([tmp hasPrefix:city.name]) {
                    tmp = [tmp substringFromIndex:city.name.length];
                    if ([zxs containsObject:city.name]) {
                        if ([tmp hasPrefix:@"市"]) {
                            tmp = [tmp substringFromIndex:1];
                        }
                        c = [city.name stringByAppendingString:@"市"];
                    } else if ([tbxzq containsObject:city.name]) {
                        c = city.name;
                    } else {
                        if ([tmp hasPrefix:@"市"]) {
                            tmp = [tmp substringFromIndex:1];
                            c = [city.name stringByAppendingString:@"市"];
                        } else if ([tmp hasPrefix:@"县"]) {
                            tmp = [tmp substringFromIndex:1];
                            c = [city.name stringByAppendingString:@"县"];
                        } else {
                            c = [city.name stringByAppendingString:@"市"];
                        }
                    }
                    
                    for (BRAreaModel *area in city.arealist) {
                        if ([tmp hasPrefix:area.name]) {
                            a = area.name;
                            
                            o = [tmp substringFromIndex:area.name.length];
                            // 补齐括号
                            if ([o containsString:@"（"] && ![o containsString:@"）"]) {
                                o = [o stringByAppendingString:@"）"];
                            }
                            if ([o containsString:@"("] && ![o containsString:@")"]) {
                                o = [o stringByAppendingString:@")"];
                            }
                        }
                    }
                }
            }
            
            if (!a || !o) {
                a = @"";
                o = tmp ? tmp : @"";
            }
            
            break;
        }
    }
    
    if ([c isNotBlank]) {
        return @[p, c, a, o];
    }
    
    return nil;
}

@end
