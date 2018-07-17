//
//  XMGridModel.h
//  XMGridMoveLayout
//
//  Created by 钱海超 on 2018/7/17.
//  Copyright © 2018年 北京大账房信息技术有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMGridModel : NSObject

@property (nonatomic,copy)   NSString       *icon;
@property (nonatomic,copy)   NSString       *title;
@property (nonatomic,assign) BOOL            allowDelete; //是否允许删除

@end
