//
//  FDSJChatModel.h
//  chatTestDemo
//
//  Created by Linshi on 2018/4/19.
//  Copyright © 2018年 Linshi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FDSJChatModel : NSObject
//用户id
@property (assign, nonatomic) int         id;
//消息类型
@property (copy, nonatomic) NSString    *type;
//消息内容
@property (copy, nonatomic) NSString    *content;
//消息的创建时间
@property (copy, nonatomic) NSString    *created_at;


//昵称
@property (copy, nonatomic) NSString    *nick;
//头像
@property (copy, nonatomic) NSString    *avatar;

@end
