//
//  HttpRequestManager.h
//  PokectDog
//
//  Created by 石少庸 on 15/7/12.
//  Copyright (c) 2015年 Baimifan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpRequestManager : NSObject

/**
 *  GET请求
 *
 *  @param url        url路径
 *  @param parameters 参数
 *  @param success    成功回调
 *  @param failure    失败回调
 */
+ (void)GET:(NSString *)url parameters:(NSDictionary *)parameters success:(void(^)(id responseObject))success failure:(void(^)(NSError * error))failure;

/**
 *  POST请求
 *
 *  @param url        url路径
 *  @param parameters 参数
 *  @param success    成功回调
 *  @param failure    失败回调
 */
+ (void)POST:(NSString *)url parameters:(NSDictionary *)parameters success:(void(^)(id responseObject))success failure:(void(^)(NSError * error))failure;

@end
