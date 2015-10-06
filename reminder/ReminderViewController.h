//
//  reminderViewController.h
//  reminder
//
//  Created by WangSiyu on 15/10/2.
//  Copyright © 2015年 SeenVoice_Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

enum reminderViewType
{
    reminderViewTypeReview = 0,
    reminderViewTypeRemind
};

@interface ReminderViewController : UIViewController

@property (nonatomic, assign) enum reminderViewType type;

- (void)refreshCurrentDisplay:(id)sender;

@end
