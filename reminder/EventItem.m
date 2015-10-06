//
//  eventItem.m
//  reminder
//
//  Created by WangSiyu on 15/10/1.
//  Copyright © 2015年 SeenVoice_Tech. All rights reserved.
//

#import "EventItem.h"

@implementation EventItem

- (instancetype)init
{
    if (self = [super init]) {
        self.title = [NSString new];
        self.detail = [NSString new];
        self.createTime = [NSDate date];
        self.lastClickRemindLaterTime = [NSDate date];
        self.images = [NSMutableArray new];
        return self;
    }
    return nil;
}

- (BOOL) needBeenRemind;
{
    if ([[NSDate date] timeIntervalSinceDate:self.lastClickRemindLaterTime] >= 3 * 60 * 60 && !self.haveBeenDone) {
        return YES;
    }
    else
        return NO;
}

- (NSDictionary *)toDictionary
{
    NSDictionary *dic = @{
                          @"title":self.title,
                          @"detail":self.detail,
                          @"createTime":self.createTime,
                          @"lastClickRemindLaterTime":self.lastClickRemindLaterTime,
                          @"haveBeenDone":[NSNumber numberWithBool:self.haveBeenDone]
                          };
    return dic;
}

- (instancetype)initWithDictionary:(NSDictionary *)dic
{
    if (self = [self init]) {
        
        NSString *title_ = [dic objectForKey:@"title"];
        NSString *detail_ = [dic objectForKey:@"detail"];
        NSDate *createTime_ = [dic objectForKey:@"createTime"];
        NSDate *lastClickRemindLaterTime_ = [dic objectForKey:@"lastClickRemindLaterTime"];
        NSNumber *haveBeenDoneNumber_ = [dic objectForKey:@"haveBeenDone"];
        BOOL haveBeenDone_ = [haveBeenDoneNumber_ boolValue];
        
        if (title_) {
            self.title = title_;
        }
        if (detail_) {
            self.detail = detail_;
        }
        if (createTime_) {
            self.createTime = createTime_;
        }
        if (lastClickRemindLaterTime_) {
            self.lastClickRemindLaterTime = lastClickRemindLaterTime_;
        }
        if (haveBeenDone_) {
            self.haveBeenDone = haveBeenDone_;
        }
    }
    return self;
}

@end
