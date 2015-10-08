//
//  reminderManager.m
//  reminder
//
//  Created by WangSiyu on 15/10/1.
//  Copyright © 2015年 WangSiyu. All rights reserved.
//

#import "ReminderManager.h"
#define ITEM_DEFAULT 10

static NSMutableArray *itemQueue;
static NSUInteger itemCountToRemind;
static UITableView *mainTableView;
static NSInteger currentIndex;
static ReminderViewController *reminder;

@implementation ReminderManager

+ (void)addItem:(EventItem *)newItem;
{
    [ReminderManager initUserInfo];
    [itemQueue addObject:newItem];
    [ReminderManager saveUserInfoToDatabase];
}

+ (void)removeItemAtIndex:(NSUInteger)index
{
    [ReminderManager initUserInfo];
    if (itemQueue.count > index) {
        EventItem *item = [itemQueue objectAtIndex:index];
        [itemQueue removeObjectAtIndex:index];
        [ReminderManager saveUserInfoToDatabase];
        [ReminderManager removeEventImagesInFile:item];
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
        if (chosenCount == maxIndex) {
            break;
        }
        if ([item needBeenRemind]) {
            chosenCount ++;
            [returnItemList addObject:item];
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
    
    [ReminderManager saveUserInfoToDatabase];
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

+ (void)saveEventImagesToFile:(EventItem *)item
{
    NSString *dirName = [NSString stringWithFormat:@"%f",[item.createTime timeIntervalSince1970]];
    deleteDirInDocument(dirName);
    createDirInDocument(dirName);
    int index = 0;
    for (UIImage *image in item.images) {
        saveImageToDirectory(pathInDocumentDirectory(dirName), image, [NSString stringWithFormat:@"%d", index], @"png");
        index ++;
    }
}

+ (void)removeEventImagesInFile:(EventItem *)item
{
    NSString *dirName = [NSString stringWithFormat:@"%f",[item.createTime timeIntervalSince1970]];
    deleteDirInDocument(dirName);
}

+ (BOOL)saveImageToFile:(UIImage *)image ForItem:(EventItem *)item index:(NSUInteger)index
{
    NSString *dirName = [NSString stringWithFormat:@"%f",[item.createTime timeIntervalSince1970]];
    
    return saveImageToDirectory(pathInDocumentDirectory(dirName), image, [NSString stringWithFormat:@"%lu", (unsigned long)index], @"png");
}

+ (BOOL)removeImageInFileForItem:(EventItem *)item index:(NSUInteger)index
{
    BOOL success = NO;
    NSString *dirName = [NSString stringWithFormat:@"%f",[item.createTime timeIntervalSince1970]];
    NSString *dirPath = pathInDocumentDirectory(dirName);
    success = removeFileInDirectory(dirPath, [NSString stringWithFormat:@"%lu.png", (unsigned long)index]);
    for (NSUInteger i = index; i < item.images.count; i++) {
        success = changeFileNameInDirectory(dirPath, [NSString stringWithFormat:@"%u",i+1], [NSString stringWithFormat:@"%lu",(unsigned long)i]);
    }
    return success;
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
NSString* pathInDocumentDirectory(NSString* name)
{
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [documentPaths objectAtIndex:0];
    return [documentPath stringByAppendingPathComponent:name];
}

bool createDirInDocument(NSString *dirName)
{
    NSString *imageDir = pathInDocumentDirectory(dirName);
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:imageDir isDirectory:&isDir];
    bool isCreated = false;
    if ( !(isDir == YES && existed == YES) )
    {
        isCreated = [fileManager createDirectoryAtPath:imageDir withIntermediateDirectories:YES attributes:nil error:nil];
        NSLog(@"directory created at path:%@",imageDir);
    }
    return isCreated;
}

// delete directory in the caches directory
bool deleteDirInDocument(NSString *dirName)
{
    NSString *imageDir = pathInDocumentDirectory(dirName);
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:imageDir isDirectory:&isDir];
    bool isDeleted = false;
    if ( isDir == YES && existed == YES )
    {
        isDeleted = [fileManager removeItemAtPath:imageDir error:nil];
        NSLog(@"directory deleted at path:%@",imageDir);
    }
    
    return isDeleted;
}

// save Image to the caches directory
bool saveImageToDirectory(NSString *directoryPath, UIImage *image, NSString *imageName, NSString *imageType)
{
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:directoryPath isDirectory:&isDir];
    if (!existed || !isDir) {
        [fileManager createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
        NSLog(@"directory created at Path:%@", directoryPath);
    }
    bool isSaved = false;
    if ([[imageType lowercaseString] isEqualToString:@"png"])
    {
        isSaved = [UIImagePNGRepresentation(image) writeToFile:[directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"png"]] options:NSAtomicWrite error:nil];
    }
    else if ([[imageType lowercaseString] isEqualToString:@"jpg"] || [[imageType lowercaseString] isEqualToString:@"jpeg"])
    {
        isSaved = [UIImageJPEGRepresentation(image, 1.0) writeToFile:[directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"jpg"]] options:NSAtomicWrite error:nil];
    }
    else
    {
        NSLog(@"Image Save Failed\nExtension: (%@) is not recognized, use (PNG/JPG)", imageType);
    }
    return isSaved;
}

bool removeFileInDirectory(NSString *directoryPath, NSString *fileName)
{
    NSString *filePath = [directoryPath stringByAppendingPathComponent:fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:filePath])
    {
        NSError *err;
        [fileManager removeItemAtPath:filePath error:&err];
        if (err)
        {
            return false;
        }
        else
        {
            return true;
        }
    }
    return false;
}

bool changeFileNameInDirectory(NSString *directoryPath, NSString *oldfileName, NSString *newfileName)
{
    NSString *oldPath = [directoryPath stringByAppendingPathComponent:oldfileName];
    NSString *newPath = [directoryPath stringByAppendingPathComponent:newfileName];
    
    return [[NSFileManager defaultManager] moveItemAtPath:oldPath toPath:newPath error:nil];
}


// load Image from caches dir to imageview
UIImage* loadImage(NSString *directoryPath, NSString *imageName)
{
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL dirExisted = [fileManager fileExistsAtPath:directoryPath isDirectory:&isDir];
    if ( isDir == YES && dirExisted == YES )
    {
        NSString *imagePath = [directoryPath stringByAppendingPathComponent : imageName];
        BOOL fileExisted = [fileManager fileExistsAtPath:imagePath];
        if (!fileExisted) {
            return nil;
        }
        NSData *imageData = [NSData dataWithContentsOfFile : imagePath];
        UIImage *image = [UIImage imageWithData:imageData];
        return image;
    }
    else
    {
        return nil;
    }
}

@end
