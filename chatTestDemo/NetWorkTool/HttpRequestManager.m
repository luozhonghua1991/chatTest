//
//  HttpRequestManager.m
//  PokectDog
//
//  Created by 石少庸 on 15/7/12.
//  Copyright (c) 2015年 Baimifan. All rights reserved.
//


#define SERVERURL @"http://139.224.32.181/Tt/Public/demo/"



#import "HttpRequestManager.h"
#import "AFNetworking.h"

@implementation HttpRequestManager

/** GET请求*/
+ (void)GET:(NSString *)url parameters:(id)parameters success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    [session.requestSerializer setValue:@"oni7W9C44U0n_MIUFs_UT49NJwM" forHTTPHeaderField:@"Authorization"];
    session.responseSerializer.acceptableContentTypes=[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/plain", nil];
    [session GET:url parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}

/** POST请求*/
+ (void)POST:(NSString *)url parameters:(id)parameters success:(void (^)(id))success failure:(void (^)(NSError *))failure
{



    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    [session.requestSerializer setValue:@"oni7W9C44U0n_MIUFs_UT49NJwM" forHTTPHeaderField:@"Authorization"];
    session.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
    [session POST:url parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {

    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}

@end


