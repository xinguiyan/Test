//
//  URLSchemeHandler.m
//  Test
//
//  Created by MMM on 2021/4/13.
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

#import "URLSchemeHandler.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AFNetworking/AFNetworking.h>

@implementation URLSchemeHandler

- (void)webView:(nonnull WKWebView *)webView startURLSchemeTask:(nonnull id<WKURLSchemeTask>)urlSchemeTask {
    /*
    NSLog(@"拦截到请求的URL：%@", urlSchemeTask.request.URL);
    NSString *localFileName = [urlSchemeTask.request.URL lastPathComponent];
    NSLog(@"本地文件名称：%@", localFileName);
    NSString *localFilePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    localFilePath = [localFilePath stringByAppendingPathComponent:@"hybrid-package"];
    localFilePath = [localFilePath stringByAppendingPathComponent:localFileName];
    NSLog(@"本地文件路径：%@", localFilePath);
    NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:localFilePath];
    NSData *data = [file readDataToEndOfFile];
    [file closeFile];
    NSString *fileMIME = [self getMIMETypeWithCAPIAtFilePath:localFilePath];
    NSLog(@"文件MIME：%@", fileMIME);
    NSDictionary *responseHeader = @{
        @"Content-type": fileMIME,
        @"Content-length": [NSString stringWithFormat:@"%lu", (unsigned long)[data length]]
    };
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", @"http://www.baseurl.com", localFilePath]] statusCode:200 HTTPVersion:@"HTTP/1.1" headerFields:responseHeader];
    [urlSchemeTask didReceiveResponse:response];
    [urlSchemeTask didReceiveData:data];
    [urlSchemeTask didFinish];
     */
    
    NSURLRequest *request = urlSchemeTask.request;
    NSLog(@"request = %@",request);
    
    //如果是我们替对方去处理请求的时候
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects: @"text/html", nil];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSURLSessionDataTask *task = [manager dataTaskWithRequest:request uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
        
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
        
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        [urlSchemeTask didReceiveResponse:response];
        [urlSchemeTask didReceiveData:responseObject];
        [urlSchemeTask didFinish];
    }];
    [task resume];
}

- (void)webView:(nonnull WKWebView *)webView stopURLSchemeTask:(nonnull id<WKURLSchemeTask>)urlSchemeTask {
    
}

#pragma mark - 内部方法

- (NSString *)getMIMETypeWithCAPIAtFilePath:(NSString *)path {
    if (![NSFileManager.defaultManager fileExistsAtPath:path]) {
        return nil;
    }
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[path pathExtension], NULL);
    CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    if (!MIMEType) {
        return @"application/octet-stream";
    }
    return (__bridge NSString *)(MIMEType);
}

@end
