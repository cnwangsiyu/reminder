//
//  mainViewController.m
//  reminder
//
//  Created by WangSiyu on 15/10/1.
//  Copyright © 2015年 SeenVoice_Tech. All rights reserved.
//

#import "MainViewController.h"
#import "ReminderManager.h"
#import "EditViewController.h"
#import "SettingViewController.h"

@interface MainViewController ()
{
    UIButton *seeReminderViewButton;
    UIView *seeReminderViewContainer;
    UITableView *mainTableView;
}

@property (nonatomic, weak) IBOutlet UINavigationBar *navBar;


@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self buildView:nil];
    
    [ReminderManager setMainTableView:mainTableView];
    
    [self refreshRemindCount:nil];
}

- (void)buildView:(id)sender
{
    mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(200, 64, FULLSCREEN_WIDTH, FULLSCREEN_HEIGHT - 64)];
    mainTableView.delegate = self;
    mainTableView.dataSource = self;
    [self.view addSubview:mainTableView];
    [mainTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"mainTableViewCellIdentifier"];
    mainTableView.backgroundColor = COLOR_AB;
    
    seeReminderViewButton = [[UIButton alloc] initWithFrame:CGRectMake(0, FULLSCREEN_HEIGHT - 40, FULLSCREEN_WIDTH, 40)];
    seeReminderViewButton.backgroundColor = COLOR_AC;
    [seeReminderViewButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [seeReminderViewButton
     addTarget:self action:@selector(seeReminderView:)
     forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:seeReminderViewButton];
    
    UIImageView *rightArrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"right"]];
    rightArrowImageView.frame = CGRectMake(FULLSCREEN_WIDTH - 40, 12, 17, 15);
    [seeReminderViewButton addSubview:rightArrowImageView];
}

- (void)refreshRemindCount:(id)sender
{
    if ([ReminderManager getItemsNeedBeenRemindCount])
    {
        seeReminderViewButton.hidden = NO;
        [seeReminderViewButton
         setTitle:[NSString stringWithFormat:@"有%lu个事项需要处理",(unsigned long)[ReminderManager getItemsNeedBeenRemindCount]]
         forState:UIControlStateNormal];
        mainTableView.frame = CGRectMake(0, 64, FULLSCREEN_WIDTH, FULLSCREEN_HEIGHT - 64 - 40);
    }
    else
    {
        seeReminderViewButton.hidden = YES;
        
        mainTableView.frame = CGRectMake(0, 64, FULLSCREEN_WIDTH, FULLSCREEN_HEIGHT - 64);
    }
}

#pragma mark - TableView Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [mainTableView dequeueReusableCellWithIdentifier:@"mainTableViewCellIdentifier" forIndexPath:indexPath];
    
    cell.textLabel.text = [ReminderManager getItemAtIndex:indexPath.row].title;
    cell.detailTextLabel.text = [ReminderManager getItemAtIndex:indexPath.row].detail;
    cell.backgroundColor = COLOR_AB;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [ReminderManager getTotalItemCount];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [ReminderManager setCurrentItemIndex:indexPath.row];

    ReminderViewController *remindVC = [[ReminderViewController alloc] initWithNibName:nil bundle:nil];
    
    remindVC.type = reminderViewTypeReview;
    [self.navigationController pushViewController:remindVC animated:YES];
    
    [mainTableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - button events

- (IBAction)addItem:(id)sender
{
    EditViewController *editVC = [[EditViewController alloc] initWithNibName:nil bundle:nil editViewControllerType:EditViewControllerTypeAdd];
    
    [self presentViewController:editVC animated:YES completion:nil];
}

- (IBAction)setting:(id)sender
{
    SettingViewController *settingVC = [[SettingViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:settingVC animated:YES];
}

- (void )seeReminderView:(id)sender
{
    ReminderViewController *reminderVC = [[ReminderViewController alloc] initWithNibName:nil bundle:nil];
    reminderVC.type = reminderViewTypeRemind;
    [self.navigationController pushViewController:reminderVC animated:YES];
}

@end
