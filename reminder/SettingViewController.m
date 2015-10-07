//
//  settingViewController.m
//  reminder
//
//  Created by WangSiyu on 15/10/3.
//  Copyright © 2015年 WangSiyu. All rights reserved.
//

#import "SettingViewController.h"
#import "ReminderManager.h"
#import "MainViewController.h"

@interface SettingViewController ()<UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, weak) IBOutlet UINavigationBar *navBar;
@property (nonatomic, weak) IBOutlet UIPickerView *pickerView;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.pickerView selectRow:[ReminderManager getItemCountToRemindPerDay] inComponent:0 animated:NO];
    self.view.backgroundColor = COLOR_AB;
    self.navBar.barTintColor = COLOR_AG;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)close:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)save:(id)sender
{
    [ReminderManager setItemCountToRemindPerDay:[self.pickerView selectedRowInComponent:0]];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NT_REFRESH_MAIN object:self];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 100;
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [NSString stringWithFormat:@"%d",(int)row];
}

@end
