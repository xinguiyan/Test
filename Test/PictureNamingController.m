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
#import <AFNetworking/AFNetworking.h>

@interface PictureNamingController ()

@property (nonatomic, copy) NSArray *photos;
@property (nonatomic, assign) NSInteger index;

@property (nonatomic, copy) NSString *accessToken;

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
    
    // 创建文件夹
    [self initDoc];
    
    NSLog(@"path : %@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]);
    
    // 获取百度Token
//    [self getAccessToken:^(NSString *token) {
//        NSLog(@"token : %@", token);
//    }];
    
    // 重命名、分组图片
    self.accessToken = @"24.35c12d4608cdd6fac1f3b38ab0732ac4.2592000.1626785212.282335-24151218";
    [self renamePhotos];
    
    // 根据execl表格查找、命名图片
//    NSArray *users = [self readCsv];
//    for (NSArray *info in users) {
//        [self findAndRenamePhotoWithUser:info];
//    }
    
    
    /*
    self.accessToken = @"24.4dc46f15630edeba419d891c98151b74.2592000.1623395213.282335-24151218";
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"1501" ofType:@"png"];
    [self getAge2:path success:^(NSString *age, NSString *gender) {
        NSLog(@"年龄：%@， 性别：%@", age, gender);
    } failure:^{
        NSLog(@"获取年龄失败");
    }];
     */
    
    
    /*
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *ggz = [doc stringByAppendingPathComponent:@"GGZ"];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *contents = [manager contentsOfDirectoryAtPath:ggz error:nil];
    for (NSString *name in contents) {
        if (![name containsString:@"公司"]) {
            NSString *path = [ggz stringByAppendingPathComponent:name];
            [manager removeItemAtPath:path error:nil];
        }
    }
     */
}

#pragma mark - 初始化UI

- (void)initUI {

}

#pragma mark - 懒加载

#pragma mark - 更新UI

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

#pragma mark - 获取目录

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
        name = [a indexOfObject:@"名字"];
        gender = [a indexOfObject:@"性别"];
        address = [a indexOfObject:@"个人地址"];
        cid = [a indexOfObject:@"证件号码"];
    }
    
    if (name == NSNotFound || gender == NSNotFound ||
        address == NSNotFound || cid == NSNotFound) {
        NSLog(@"表格缺少指定列名");
        return nil;
    }
    
    NSMutableArray *users = [NSMutableArray arrayWithCapacity:array.count-1];
    for (int i=1; i<array.count; i++) {
        NSArray *a = [array objectOrNilAtIndex:i];
        if (a) {
            NSString *s1 = [NSString stringWithFormat:@"%d", i]; // [a objectOrNilAtIndex:serial];
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
                    s1,
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
    
- (void)findAndRenamePhotoWithUser:(NSArray *)userInfo {
    NSString *serial = userInfo[0];
    NSString *name = userInfo[1];
    NSString *gender = userInfo[2];
    
    if ([self isNamed:serial]) {
//        NSLog(@"%@-%@ 图片已命名", userInfo[0], userInfo[1]);
        return;
    }
    
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
        
        NSLog(@"年龄：%ld 找不到相应年龄图片", age);
        age -= 10;
    }
    
    if (age <= 0) {
        age = now.year - [userInfo[4] intValue];
        NSLog(@"%@-%@ %@ 年龄：%ld 找不到相应年龄图片", serial, name, gender, age);
        return;
    }
    
    // 重命名文件
    NSString *n = path.lastPathComponent;
    NSMutableArray *a = [n componentsSeparatedByString:@"-"].mutableCopy;
    a[0] = serial;
    NSString *nn = [a componentsJoinedByString:@"-"];
    
    // 存放新命名的路径
    NSString *toPath = [[self docOfNamed] stringByAppendingFormat:@"/%@", nn];
    [self movePhotoAtPath:path toPath:toPath];
}

- (BOOL)isNamed:(NSString *)serial {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *path = [self docOfNamed];
    NSArray *array = [manager contentsOfDirectoryAtPath:path error:nil];
    for (NSString *name in array) {
        NSArray *tmp = [name componentsSeparatedByString:@"-"];
        if (tmp.count > 0 && [tmp[0] isEqualToString:serial]) {
            return YES;
        }
    }
    return NO;
}

- (NSString *)docOfNamed {
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *named = [doc stringByAppendingPathComponent:@"named"];
    return named;
}

#pragma mark - 获取年龄

- (void)getAccessToken:(void (^)(NSString *token))block {
//https://aip.baidubce.com/oauth/2.0/token?grant_type=client_credentials&client_id=Va5yQRHlA4Fq5eR3LT0vuXV4&client_secret=0rDSjzQ20XUj5itV6WRtznPQSzr5pVw2&

    AFHTTPSessionManager *Manager = [AFHTTPSessionManager manager];
    NSString *url = @"https://aip.baidubce.com/oauth/2.0/token";
    NSDictionary *dict = @{
        @"grant_type": @"client_credentials",
        @"client_id": @"CTM8LPtcwObaeAgR78xSG3Dl",
        @"client_secret": @"qkIhKkTvb6LSjZ29qR7c09gSVsGIzlxY",
    };
    //post 请求
    [Manager POST:url parameters:dict headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *accessToken = responseObject[@"access_token"];
        block(accessToken);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求失败");
    }];
}

- (void)getAge2:(NSString *)photo
        success:(void (^)(NSString *age, NSString *gender))success
        failure:(void (^)(void))failure {
    UIImage *image = [UIImage imageWithContentsOfFile:photo];
    
    AFHTTPSessionManager *Manager = [AFHTTPSessionManager manager];
    NSString *url = @"https://aip.baidubce.com/rest/2.0/face/v3/detect";
    NSDictionary *dict = @{
        @"access_token": self.accessToken,
    };
    
    [Manager POST:url parameters:dict headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSData *data = UIImagePNGRepresentation(image);
        NSString *base64 = [data base64EncodedStringWithOptions:0];
        [formData appendPartWithFormData:[base64 dataUsingEncoding:NSUTF8StringEncoding]
                  name:@"image"];
        [formData appendPartWithFormData:[@"BASE64" dataUsingEncoding:NSUTF8StringEncoding]
                  name:@"image_type"];
        [formData appendPartWithFormData:[@"age,gender" dataUsingEncoding:NSUTF8StringEncoding]
                  name:@"face_field"];
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *age;
        NSString *gender;
        NSDictionary *result = responseObject[@"result"];
        if (result && [result isKindOfClass:NSDictionary.class]) {
            NSArray *array = result[@"face_list"];
            if (array && array.count > 0) {
                NSDictionary *dic = array[0];
                age = dic[@"age"];
                gender = dic[@"gender"][@"type"];
                gender = [gender isEqualToString:@"male"] ? @"男" : @"女";
                success(age, gender);
            } else {
                failure();
            }
        } else {
            failure();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求失败");
        failure();
    }];
}

#pragma mark - 照片重命名

- (void)renamePhotos {
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
        if ([name hasSuffix:@".png"] ||
            [name hasSuffix:@".jpeg"] ||
            [name hasSuffix:@".jpg"] ||
            [name hasSuffix:@".bmp"]) {
            [array addObject:[photos stringByAppendingFormat:@"/%@", name]];
        }
    }
    self.photos = array;
    
    // 开始获取
    self.index = -1;
    [self renameNextPhoto];
}

- (void)renameNextPhoto {
    self.index++;
    if (self.index >= self.photos.count) {
        NSLog(@"结束了");
        return;
    }
    
    NSString *photo = self.photos[self.index];
    [self getAge2:photo success:^(NSString *age, NSString *gender) {
        [self renamePhoto:photo age:age gender:gender];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self renameNextPhoto];
        });
    } failure:^{
        NSLog(@"获取年龄失败");
        [self renameNextPhoto];
    }];
}

- (void)renamePhoto:(NSString *)photo age:(NSString *)age gender:(NSString *)gender {
    NSString *name = photo.lastPathComponent;
    NSString *extension = photo.pathExtension;
    NSRange range = [name rangeOfString:[NSString stringWithFormat:@".%@", extension]];
    NSString *s1 = [NSString stringWithFormat:@"%ld", self.index]; // [name substringWithRange:NSMakeRange(0, range.location)];
    NSString *newname = [s1 stringByAppendingFormat:@"-%@-%@.%@", age, gender, extension];
    
    range = [photo rangeOfString:name];
    NSString *toPath = [self docOfGender:gender andAge:age.intValue]; // [photo substringWithRange:NSMakeRange(0, range.location)];
    toPath = [toPath stringByAppendingFormat:@"/%@", newname];
    
    NSInteger i = self.index;
    NSFileManager *manager = [NSFileManager defaultManager];
    while ([manager fileExistsAtPath:toPath]) {
        i++;
        newname = [NSString stringWithFormat:@"%ld-%@-%@.%@", i, age, gender, extension];
        
        toPath = [self docOfGender:gender andAge:age.intValue];
        toPath = [toPath stringByAppendingFormat:@"/%@", newname];
    }
    
    [self movePhotoAtPath:photo toPath:toPath];
}

@end
