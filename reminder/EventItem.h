//
//  eventItem.h
//  reminder
//
//  Created by WangSiyu on 15/10/1.
//  Copyright © 2015年 WangSiyu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EventItem : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *detail;

@property (nonatomic, strong) NSDate *createTime;
@property (nonatomic, strong) NSDate *lastClickRemindLaterTime;
@property (nonatomic, assign) BOOL haveBeenDone;

@property (nonatomic, strong) NSMutableArray *images;

- (NSDictionary *)toDictionary;
- (BOOL) needBeenRemind;

- (instancetype)initWithDictionary:(NSDictionary *)dic;
- (id)copy;

@end
