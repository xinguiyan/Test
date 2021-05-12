//
//  PictureNamingController.m
//  Test
//
//  Created by MMM on 2021/5/10.
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

#import "PictureNamingController.h"

#import "JQUploadPicRequest.h"

@interface PictureNamingController ()

@property (nonatomic, copy) NSArray *photos;
@property (nonatomic, assign) NSInteger index;

@end


@implementation PictureNamingController

- (void)dealloc {
    NSLog(@"%s", __func__);
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	self.title = @"";
    self.view.backgroundColor = UIColor.whiteColor;

    [self initUI];
    
    [self initDoc];
    
    NSLog(@"path : %@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]);
//    [self groupPhotos];
    
    NSArray *users = [self readCsv];
    for (NSArray *info in users) {
        [self renamePhotoWithUser:info];
    }
}

#pragma mark - Notification

#pragma mark - 初始化UI

- (void)initUI {

}

#pragma mark - 懒加载

#pragma mark - 重建UI

- (void)rebuildUI {

}

#pragma mark - 更新UI

- (void)updateUI {

}

#pragma mark - 创建文件夹

- (void)initDoc {
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSFileManager *manager = [NSFileManager defaultManager];
    
    // 创建文件夹
    NSArray *genderArray = @[@"男", @"女"];
    for (NSString *gender in genderArray) {
        NSString *tmp = [doc stringByAppendingPathComponent:gender];
        BOOL isSuccess = [manager createDirectoryAtPath:tmp
                            withIntermediateDirectories:YES
                                             attributes:nil
                                                  error:nil];
        if (isSuccess) {
            NSArray *pathArray = @[
                @"0-20",
                @"20-30",
                @"30-40",
                @"40-50",
                @"50-60",
                @"60-70",
                @"70-80",
                @"80-90",
                @"90-100"
            ];
            for (NSString *name in pathArray) {
                NSString *tmp1 = [tmp stringByAppendingPathComponent:name];
                [manager createDirectoryAtPath:tmp1
                   withIntermediateDirectories:YES
                                    attributes:nil
                                         error:nil];
            }
        }
    }
    
    [manager createDirectoryAtPath:[self docOfNamed]
       withIntermediateDirectories:YES
                        attributes:nil
                             error:nil];
}

#pragma mark - 照片分组

- (void)groupPhotos {
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *photos = [doc stringByAppendingPathComponent:@"photos"];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL isDirectory;
    BOOL isExit = [manager fileExistsAtPath:photos isDirectory:&isDirectory];
    if (!isExit || !isDirectory) {
        NSLog(@"不存在photos文件夹");
        return;
    }
    
    NSError *error;
    NSArray *contents = [manager contentsOfDirectoryAtPath:photos error:&error];
    if (error) {
        NSLog(@"读取文件错误：%@", error);
        return;
    }
    
    NSMutableArray *array = [NSMutableArray array];
    for (NSString *name in contents) {
        if ([name hasSuffix:@".jpeg"]) {
            [array addObject:[photos stringByAppendingFormat:@"/%@", name]];
        }
    }
    self.photos = array;
    
    // 开始获取
    self.index = -1;
    [self getNextPhoto];
}

- (void)getNextPhoto {
    self.index++;
    if (self.index >= self.photos.count) {
        return;
    }
    
    NSString *photo = self.photos[self.index];
    [self getAge:photo];
}

- (void)getAge:(NSString *)photo {
    UIImage *image = [UIImage imageWithContentsOfFile:photo];
    
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

            // 性别判断
            NSString *gender = dict[@"attributes"][@"gender"][@"value"];
            NSString *genderStr = [gender isEqualToString:@"Female"] ? @"女" : @"男";
            
            NSString *toPath = [self docOfGender:genderStr andAge:age];
            toPath = [toPath stringByAppendingFormat:@"/%@", [photo lastPathComponent]];
            [self movePhotoAtPath:photo toPath:toPath];
        } else {
            NSLog(@"面部识别返回错误：【%@】", [photo lastPathComponent]);
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self getNextPhoto];
        });
    }];
}

- (NSString *)docOfGender:(NSString *)gender andAge:(NSInteger)age {
    NSString *doc = [self docOfGender:gender];
    
    NSString *ageStr;
    if (age <= 20) {
        ageStr = @"0-20";
    } else if (age <= 30) {
        ageStr = @"20-30";
    } else if (age <= 40) {
        ageStr = @"30-40";
    } else if (age <= 50) {
        ageStr = @"40-50";
    } else if (age <= 60) {
        ageStr = @"50-60";
    } else if (age <= 70) {
        ageStr = @"60-70";
    } else if (age <= 80) {
        ageStr = @"70-80";
    } else if (age <= 90) {
        ageStr = @"80-90";
    } else {
        ageStr = @"90-100";
    }
    doc = [doc stringByAppendingPathComponent:ageStr];
    return doc;
}

- (NSString *)docOfGender:(NSString *)gender {
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *tmp = [doc stringByAppendingPathComponent:gender];
    return tmp;
}

- (BOOL)movePhotoAtPath:(NSString *)path toPath:(NSString *)toPath {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *error;
    
    if ([manager fileExistsAtPath:toPath]) {
        NSLog(@"【%@】文件重复", [toPath lastPathComponent]);
        return NO;
    }
    
    BOOL isSuccess = [manager moveItemAtPath:path toPath:toPath error:&error];
    if (!isSuccess && error) {
        NSLog(@"移动错误错误：%@", error);
        return NO;
    }
    return isSuccess;
}

#pragma mark - 读取execl，给照片命名

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
                
                NSArray *values = @[
                    [a objectOrNilAtIndex:serial],
                    [a objectOrNilAtIndex:name],
                    [a objectOrNilAtIndex:gender],
                    [a objectOrNilAtIndex:cid],
                    year, month, day,
                ];
                [users addObject:values];
            }
        }
    }
    return users;
}
    
- (void)renamePhotoWithUser:(NSArray *)userInfo {
    NSString *pname = [self nameOfPhoto:userInfo];
    if ([self isNamed:pname]) {
//        NSLog(@"%@-%@ 图片已命名", userInfo[0], userInfo[1]);
        return;
    }
    
    NSString *serial = userInfo[0];
    NSString *name = userInfo[1];
    NSString *gender = userInfo[2];
    
    NSDate *now = [NSDate date];
    NSInteger age = now.year - [userInfo[4] intValue];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *doc;
    NSString *path;
    
    while (age > 0) {
        // 待查找文件夹
        doc = [self docOfGender:gender andAge:age];
        NSArray *contents = [manager contentsOfDirectoryAtPath:doc error:nil];
        if (contents.count > 0) {
            path = [doc stringByAppendingFormat:@"/%@", contents[0]];
            break;
        }
        
        age -= 10;
    }
    
    if (age <= 0) {
        age = now.year - [userInfo[4] intValue];
        NSLog(@"%@-%@ %@ 年龄：%ld 找不到相应年龄图片", serial, name, gender, age);
        return;
    }
    
    // 存放新命名的路径
    NSString *toPath = [[self docOfNamed] stringByAppendingFormat:@"/%@", pname];
    
    [self movePhotoAtPath:path toPath:toPath];
    
}

- (NSString *)nameOfPhoto:(NSArray *)userInfo {
    NSString *serial = userInfo[0];
//    NSString *name = userInfo[1];
    return [NSString stringWithFormat:@"%@.jpeg", serial];
}

- (BOOL)isNamed:(NSString *)pname {
    NSString *named = [self docOfNamed];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *path = [named stringByAppendingFormat:@"/%@", pname];
    return [manager fileExistsAtPath:path];
}

- (NSString *)docOfNamed {
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *named = [doc stringByAppendingPathComponent:@"named"];
    return named;
}

@end
