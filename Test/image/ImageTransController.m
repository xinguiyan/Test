//
//  ImageTransController.m
//  Test
//
//  Created by Yan Xingui on 2022/4/20.
//

#import "ImageTransController.h"

#import <AFNetworking/AFNetworking.h>

@interface ImageTransController ()

@property (nonatomic, copy) NSString *accessToken;

@end


@implementation ImageTransController

- (void)dealloc {
    NSLog(@"%s", __func__);
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	self.title = @"";
    self.view.backgroundColor = UIColor.whiteColor;

    [self initUI];
    
    // 获取百度Token
//    [self getAccessToken:^(NSString *token) {
//        NSLog(@"token : %@", token);
//    }];
    
    self.accessToken = @"24.8ba326cf003af79628d20fe42de8a7ca.2592000.1653049003.282335-26018426";
    
    [self trans:@"" success:^(NSString *age, NSString *gender) {

    } failure:^{

    }];
}

#pragma mark - 初始化UI

- (void)initUI {

}

#pragma mark - 懒加载

#pragma mark - 更新UI

#pragma mark - 获取年龄

- (void)getAccessToken:(void (^)(NSString *token))block {

//    AppID: 26018426
//    API Key: gS0ggk1KzX8UdYDzPXKivDmT
//    Secret Key: agTGdrFgOekNngvdCFSv0BwrbQ6A3iaB

    AFHTTPSessionManager *Manager = [AFHTTPSessionManager manager];
    NSString *url = @"https://aip.baidubce.com/oauth/2.0/token";
    NSDictionary *dict = @{
        @"grant_type": @"client_credentials",
        @"client_id": @"gS0ggk1KzX8UdYDzPXKivDmT",
        @"client_secret": @"agTGdrFgOekNngvdCFSv0BwrbQ6A3iaB",
    };
    //post 请求
    [Manager POST:url parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *accessToken = responseObject[@"access_token"];
        block(accessToken);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"请求失败");
    }];
}

- (void)trans:(NSString *)photo
      success:(void (^)(NSString *age, NSString *gender))success
      failure:(void (^)(void))failure {
    
//    NSString *path = [NSBundle.mainBundle pathForResource:@"123.png" ofType:nil];
//    UIImage *image = [UIImage imageWithContentsOfFile:path];
    
    UIImage *image = [UIImage imageNamed:@"123.png"];
    
    AFHTTPSessionManager *Manager = [AFHTTPSessionManager manager];
    NSString *url = @"https://aip.baidubce.com/rest/2.0/image-process/v1/style_trans";
    url = [url stringByAppendingFormat:@"?access_token=%@", self.accessToken];
    
    NSData *data = UIImagePNGRepresentation(image);
    NSString *base64 = [data base64EncodedStringWithOptions:0];
    NSDictionary *params = @{
        @"image": base64,
        @"option": @"gothic"
    };
    
    NSDictionary *headers = @{
        @"Content-Type": @"application/x-www-form-urlencoded"
    };
    
//    [Manager POST:url parameters:params headers:headers progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSString *image = responseObject[@"image"];
//        if (image) {
//            NSData *data = [[NSData alloc] initWithBase64EncodedString:image options:NSDataBase64DecodingIgnoreUnknownCharacters];
//            UIImage *result = [UIImage imageWithData:data];
//            [self saveImage:result name:@"111.png"];
//        } else {
//            failure();
//        }
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"请求失败");
//        failure();
//    }];
}

#pragma mark - 保存图片

- (void)saveImage:(UIImage *)image name:(NSString *)name {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:name];
        
    BOOL result = [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
    if (result == YES) {
        NSLog(@"%@", filePath);
        NSLog(@"保存成功");
    }
}

@end
