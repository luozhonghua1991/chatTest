//
//  UUMessageFrame.m
//  UUChatDemoForTextVoicePicture
//
//  Created by shake on 14-8-26.
//  Copyright (c) 2014年 uyiuyao. All rights reserved.
//

#import "UUMessageFrame.h"
#import "UUMessage.h"
#import "UUChatCategory.h"


@implementation UUMessageFrame

- (void)setChatModel:(FDSJChatModel *)chatModel{
    
    _chatModel = chatModel;
    
    CGFloat const screenW = [UIScreen uu_screenWidth];
    
    // 1、计算时间的位置
    
		CGSize timeSize = [_chatModel.created_at uu_sizeWithFont:ChatTimeFont constrainedToSize:CGSizeMake(300, 100)];
        _timeF = CGRectMake((screenW - timeSize.width) / 2, ChatMargin, timeSize.width, timeSize.height);
  
    
    // 2、计算头像位置
//    CGFloat const iconX = _message.from == UUMessageFromOther ? ChatMargin : (screenW - ChatMargin - ChatIconWH);
    CGFloat const iconX = ChatMargin;
    _iconF = CGRectMake(iconX, CGRectGetMaxY(_timeF) + ChatMargin, ChatIconWH, ChatIconWH);
    
    // 3、计算ID位置
	CGSize nameSize = [_chatModel.nick uu_sizeWithFont:ChatTimeFont constrainedToSize:CGSizeMake(ChatIconWH+ChatMargin, 50)];
    _nameF = CGRectMake(iconX-ChatMargin/2.0, CGRectGetMaxY(_iconF) + ChatMargin/2.0, ChatIconWH+ChatMargin, nameSize.height);
    
    // 4、计算内容位置
    CGFloat contentX = CGRectGetMaxX(_iconF) + ChatMargin;
   
    //根据种类分
    CGSize contentSize;
    contentSize = [_chatModel.content uu_sizeWithFont:ChatContentFont constrainedToSize:CGSizeMake(MAX(ChatContentW, screenW*0.6), CGFLOAT_MAX)];
    contentSize.height = MAX(contentSize.height, 30);
    contentSize.width = MAX(contentSize.width, 40);
			

    
    
//    if (_chatModel.from == UUMessageFromMe) {
        contentX = screenW - (contentSize.width + ChatContentBiger + ChatContentSmaller + ChatMargin + ChatIconWH + ChatMargin);
//    }
    _contentF = CGRectMake(contentX, CGRectGetMinY(_iconF) + 5, contentSize.width + ChatContentBiger + ChatContentSmaller, contentSize.height + ChatContentTopBottom * 2);
    
    _cellHeight = MAX(CGRectGetMaxY(_contentF), CGRectGetMaxY(_nameF))  + ChatMargin;
}


@end
