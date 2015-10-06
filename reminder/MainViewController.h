//
//  mainViewController.h
//  reminder
//
//  Created by WangSiyu on 15/10/1.
//  Copyright © 2015年 SeenVoice_Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

- (void)refreshRemindCount:(id)sender;

@end
