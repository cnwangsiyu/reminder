//
//  reminderManager.h
//  reminder
//
//  Created by WangSiyu on 15/10/1.
//  Copyright © 2015年 WangSiyu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ReminderViewController.h"
#import "EditViewController.h"
#import "EventItem.h"
#import "common.h"
#define FULLSCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define FULLSCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface ReminderManager : NSObject

+ (void)addItem:(EventItem *)newItem;
+ (void)removeItemAtIndex:(NSUInteger)index;

+ (EventItem *)getItemAtIndex:(NSUInteger)index;
+ (void)setItem:(EventItem *)newItem AtIndex:(NSUInteger)index;

+ (void)markAsIHaveDoneItAtIndex:(NSUInteger)index;
+ (void)markAsRemindMeLaterAtIndex:(NSUInteger)index;

+ (NSUInteger)getTotalItemCount;

+ (NSArray *)getAllItemsInCreateTimeOrder;
+ (NSArray *)getAllItemsInRemindOrder;

+ (NSArray *)getItemsNeedBeenRemind;
+ (NSUInteger)getItemsNeedBeenRemindCount;

+ (void)setItemCountToRemindPerDay:(NSUInteger)count;
+ (NSUInteger)getItemCountToRemindPerDay;

+ (void)setMainTableView:(UITableView *)tableView;
+ (UITableView *)getMainTableView;

+ (void)setReminderViewController:(ReminderViewController *)reminderVC;
+ (ReminderViewController *)getReminderViewController;

+ (BOOL)saveImageToFile:(UIImage *)image ForItem:(EventItem *)item index:(NSUInteger)index;
+ (BOOL)removeImageInFileForItem:(EventItem *)item index:(NSUInteger)index;
+ (BOOL)saveImageChangesForItem:(EventItem *)item;
+ (BOOL)dismissImageChangesForItem:(EventItem *)item;

+ (void)removeEventImagesInFile:(EventItem *)item;

+ (void)setCurrentItemIndex:(NSInteger)index;
+ (NSInteger)getCurrentItemIndex;

NSString* pathInDocumentDirectory(NSString* name);
bool createDirInDocument(NSString *dirName);
bool saveImageToDirectory(NSString *directoryPath, UIImage *image, NSString *imageName, NSString *imageType);
UIImage* loadImage(NSString *directoryPath, NSString *imageName);

@end
