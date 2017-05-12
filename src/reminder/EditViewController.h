//
//  editViewController.h
//  reminder
//
//  Created by WangSiyu on 15/10/1.
//  Copyright © 2015年 WangSiyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventItem.h"

enum EditViewControllerType
{
    EditViewControllerTypeEdit = 0,
    EditViewControllerTypeAdd
};

@interface EditViewController : UIViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil editViewControllerType:(enum EditViewControllerType)newType;

@end
