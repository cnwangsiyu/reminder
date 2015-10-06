//
//  reminderManager.m
//  reminder
//
//  Created by WangSiyu on 15/10/1.
//  Copyright © 2015年 SeenVoice_Tech. All rights reserved.
//

#import "ReminderManager.h"
#define ITEM_DEFAULT 10

static NSMutableArray *itemQueue;
static NSUInteger itemCountToRemind;
static UITableView *mainTableView;
static NSInteger currentIndex;
static ReminderViewController *reminder;

@implementation ReminderManager

+ (void)addItem:(EventItem *)item;
{
    [ReminderManager initUserInfo];
    [itemQueue addObject:item];
    [ReminderManager saveUserInfoToDatabase];
}

+ (void)removeItemAtIndex:(NSUInteger)index
{
    [ReminderManager initUserInfo];
    if (itemQueue.count > index) {
        [itemQueue removeObjectAtIndex:index];
        [ReminderManager saveUserInfoToDatabase];
    }
}

+ (EventItem *)getItemAtIndex:(NSUInteger)index
{
    [ReminderManager initUserInfo];
    if (itemQueue.count > index) {
        return [itemQueue objectAtIndex:index];
    }
    else
        return nil;
}

+ (void)setItem:(EventItem *)newItem AtIndex:(NSUInteger)index
{
    [ReminderManager initUserInfo];
    if (itemQueue.count > index) {
        [itemQueue replaceObjectAtIndex:index withObject:newItem];
        [ReminderManager saveUserInfoToDatabase];
    }
}

+ (void)markAsIHaveDoneItAtIndex:(NSUInteger)index
{
    [ReminderManager initUserInfo];
    if (itemQueue.count > index) {
        EventItem *item = [itemQueue objectAtIndex:index];
        item.haveBeenDone = YES;
        [ReminderManager saveUserInfoToDatabase];
    }
}

+ (void)markAsRemindMeLaterAtIndex:(NSUInteger)index
{
    [ReminderManager initUserInfo];
    if (itemQueue.count > index) {
        EventItem *item = [itemQueue objectAtIndex:index];
        item.lastClickRemindLaterTime = [NSDate date];
    }
}

+ (NSUInteger)getTotalItemCount
{
    [ReminderManager initUserInfo];
    return itemQueue.count;
}

+ (NSArray *)getAllItemsInCreateTimeOrder
{
    [ReminderManager initUserInfo];
    return [itemQueue copy];
}

+ (NSArray *)getAllItemsInRemindOrder
{
    NSComparator cmptr = ^(EventItem *obj1, EventItem *obj2){
        
        NSDate *time1 = obj1.lastClickRemindLaterTime ? obj1.lastClickRemindLaterTime : obj1.createTime;
        NSDate *time2 = obj2.lastClickRemindLaterTime ? obj2.lastClickRemindLaterTime : obj2.createTime;
        if ([[NSDate date] timeIntervalSinceDate:time1] > [[NSDate date] timeIntervalSinceDate:time2]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if ([[NSDate date] timeIntervalSinceDate:time1] < [[NSDate date] timeIntervalSinceDate:time2]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    };
        return [itemQueue sortedArrayUsingComparator:cmptr];
}

+ (NSArray *)getItemsNeedBeenRemind;
{
    [ReminderManager initUserInfo];

    NSUInteger maxIndex = itemQueue.count > itemCountToRemind ? itemCountToRemind : itemQueue.count;
    NSUInteger chosenCount = 0;
    NSMutableArray *returnItemList = [NSMutableArray new];
    NSArray *tempList = [self getAllItemsInRemindOrder];
    for (EventItem *item in tempList) {
        if ([item needBeenRemind]) {
            chosenCount ++;
            [returnItemList addObject:item];
        }
        if (chosenCount == maxIndex) {
            break;
        }
    }
    return returnItemList;
}

+ (NSUInteger)getItemsNeedBeenRemindCount
{
    return [ReminderManager getItemsNeedBeenRemind].count;
}

+ (void)setItemCountToRemindPerDay:(NSUInteger)count;
{
    [ReminderManager initUserInfo];

    itemCountToRemind = count;
}

+ (NSUInteger)getItemCountToRemindPerDay;
{
    [ReminderManager initUserInfo];

    return itemCountToRemind;
}

+ (void)initUserInfo
{
    if (!itemQueue)
    {
        itemQueue = [NSMutableArray new];
        NSDictionary *dic = [ReminderManager getUserInfoFromDatabase];
        NSMutableArray *itemQueueFromDB = [[dic objectForKey:@"itemqueue"] mutableCopy];
        for (NSDictionary *dic in itemQueueFromDB) {
            [itemQueue addObject:[[EventItem alloc] initWithDictionary:dic]];
        }
        itemCountToRemind = [[dic objectForKey:@"itemCountToRemind"] longValue];
        if (!itemCountToRemind) {
            itemCountToRemind = ITEM_DEFAULT;
        }
    }
}

+ (NSDictionary *)getUserInfoFromDatabase
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"userInfo"];
}

+ (void)saveUserInfoToDatabase
{
    NSMutableArray *itemQueueToSave = [NSMutableArray new];
    for (EventItem *item in itemQueue) {
        [itemQueueToSave addObject:[item toDictionary]];
    }
    NSDictionary * dic = @{@"itemqueue":itemQueueToSave, @"itemCountToRemind":[NSNumber numberWithLong:itemCountToRemind]};
    [[NSUserDefaults standardUserDefaults]setObject:dic forKey:@"userInfo"];
}

+ (void)setMainTableView:(UITableView *)tableView
{
    mainTableView = tableView;
}

+ (UITableView *)getMainTableView
{
    return mainTableView;
}

+ (void)setReminderViewController:(ReminderViewController *)reminderVC
{
    reminder = reminderVC;
}

+ (ReminderViewController *)getReminderViewController
{
    return reminder;
}

+ (void)setCurrentItemIndex:(NSUInteger)index
{
    currentIndex = index;
}

+ (NSInteger)getCurrentItemIndex
{
    return currentIndex;
}

@end
