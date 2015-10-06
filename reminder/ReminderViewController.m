//
//  reminderViewController.m
//  reminder
//
//  Created by WangSiyu on 15/10/2.
//  Copyright © 2015年 WangSiyu. All rights reserved.
//

#import "ReminderViewController.h"
#import "ReminderManager.h"
#import "EditViewController.h"
#import "MainViewController.h"
#import "PhotoBroswerVC.h"

#define IMAGE_TAG 17890

@interface ReminderViewController ()
{
    UILabel *titleText;
    UITextView *detailText;
    UIScrollView *scrollView;
    EventItem *selectedItem;
    UIView *imageContainer;
}

@property (nonatomic, weak) IBOutlet UIButton *leftButton;
@property (nonatomic, weak) IBOutlet UIButton * rightButton;

@end

@implementation ReminderViewController

@synthesize type;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    selectedItem = [ReminderManager getItemAtIndex:[ReminderManager getCurrentItemIndex]];
    
    [ReminderManager setReminderViewController:self];
    
    [self buildViews:nil];
    
}

- (void)buildViews:(id)sender
{
    self.view.backgroundColor = COLOR_AB;
    if (type == reminderViewTypeRemind)
    {
        self.title = @"提醒";
    }
    else
    {
        self.title = @"查看事项";
    }
    UIBarButtonItem *editItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStyleDone target:self action:@selector(edit:)];
    [self.navigationItem setRightBarButtonItem:editItem];
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, FULLSCREEN_WIDTH, FULLSCREEN_HEIGHT)];
    scrollView.contentSize = CGSizeMake(FULLSCREEN_WIDTH, FULLSCREEN_HEIGHT);
    [self.view addSubview:scrollView];
    
    titleText = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, FULLSCREEN_WIDTH - 20, 40)];
    titleText.text = selectedItem.title;
    titleText.textAlignment = NSTextAlignmentCenter;
    titleText.backgroundColor = [UIColor clearColor];
    [scrollView addSubview:titleText];
    
    detailText = [[UITextView alloc] initWithFrame:CGRectMake(10, 80, FULLSCREEN_WIDTH - 20, 200)];
    detailText.text = selectedItem.detail;
    detailText.backgroundColor = [UIColor clearColor];
    detailText.font = [UIFont systemFontOfSize:18];
    detailText.editable = NO;
    [scrollView addSubview:detailText];
    
    CGRect frame = detailText.frame;
    float top = frame.origin.y + frame.size.height + 10;
    imageContainer = [[UIView alloc] initWithFrame:CGRectMake(frame.origin.x, top, frame.size.width, 120)];
    imageContainer.backgroundColor = [UIColor clearColor];
    [scrollView addSubview:imageContainer];
    
    [self buildImageView:nil];
    
    [self refreshCurrentDisplay:nil];
    if (self.type == reminderViewTypeRemind)
    {
        [self.leftButton setTitle:@"稍后提醒" forState:UIControlStateNormal];
        [self.rightButton setTitle:@"我知道啦" forState:UIControlStateNormal];
        self.leftButton.hidden = NO;
        self.rightButton.hidden = NO;
    }
    else
    {
        [self.leftButton setTitle:@"上一个" forState:UIControlStateNormal];
        [self.rightButton setTitle:@"下一个" forState:UIControlStateNormal];
        [self setButtonState];
    }
}

- (void)refreshCurrentDisplay:(id)sender
{
    EventItem *item = [ReminderManager getItemAtIndex:[ReminderManager getCurrentItemIndex]];
    titleText.text = item.title;
    detailText.text = item.detail;
    if (self.type == reminderViewTypeReview) {
        [self setButtonState];
    }
    [self buildImageView:nil];
}

- (void)setButtonState
{
    self.leftButton.hidden = NO;
    self.rightButton.hidden = NO;
    
    if ([ReminderManager getCurrentItemIndex] == 0) {
        self.leftButton.hidden = YES;
    }
    if ([ReminderManager getCurrentItemIndex] == [ReminderManager getTotalItemCount] - 1) {
        self.rightButton.hidden = YES;
    }
}

- (void)buildImageView:(id)sender
{
    int imageTag = IMAGE_TAG;
    
    for (UIView *childView in imageContainer.subviews)
    {
        [childView removeFromSuperview];
    }
    
    for (UIImage *image in selectedItem.images) {
        
        UIImageView *imageView = [[UIImageView alloc]
                                  initWithFrame:CGRectMake(70 * (imageTag - IMAGE_TAG) + 10,
                                                           70 * ((imageTag - IMAGE_TAG) / 4),
                                                           60, 60)];
        
        imageView.image = image;
        
        CGRectMake(70 * (imageTag - IMAGE_TAG) + 10, 70 * ((imageTag - IMAGE_TAG) / 4), 60, 60);
        
        imageView.userInteractionEnabled = YES;
        
        [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openImageScaleInView:)]];
        
        imageView.tag = imageTag;
        
        imageTag ++ ;
        
        [imageContainer addSubview:imageView];
    }
}

- (void)openImageScaleInView:(UITapGestureRecognizer *)tapGesture
{
    UIImageView *imageView = (UIImageView *)tapGesture.view;
    
    long index = imageView.tag - IMAGE_TAG;
    [PhotoBroswerVC show:self type:PhotoBroswerVCTypeZoom index:index photoModelBlock:
     ^NSArray *{
         NSArray *localImages = selectedItem.images;
         
         NSMutableArray *modelsM = [NSMutableArray arrayWithCapacity:localImages.count];
         for (NSUInteger i = 0; i< localImages.count; i++) {
             
             PhotoModel *pbModel=[[PhotoModel alloc] init];
             pbModel.mid = i + 1;
             pbModel.title = selectedItem.title;
             pbModel.desc = selectedItem.detail;
             pbModel.image = localImages[i];
             
             //源frame
             UIImageView *imageV = (UIImageView *)[imageContainer viewWithTag: IMAGE_TAG + i];
             pbModel.sourceImageView = imageV;
             [modelsM addObject:pbModel];
         }
         
         return modelsM;
         
     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)edit:(id)sender
{
    EditViewController *editVC = [[EditViewController alloc] initWithNibName:nil bundle:nil editViewControllerType:EditViewControllerTypeEdit];
    [self.navigationController pushViewController:editVC animated:YES];
}

- (IBAction)leftButtonEvent:(id)sender
{
    if (self.type == reminderViewTypeRemind)
    {
        [ReminderManager markAsRemindMeLaterAtIndex:[ReminderManager getCurrentItemIndex]];
        if ([ReminderManager getCurrentItemIndex] + 1 == [ReminderManager getItemsNeedBeenRemindCount]) {
            [ReminderManager setCurrentItemIndex:0];
        }
        else
        {
            [ReminderManager setCurrentItemIndex:[ReminderManager getCurrentItemIndex] + 1];
        }
        [self refreshCurrentDisplay:nil];
    }
    else
    {
        [ReminderManager setCurrentItemIndex:[ReminderManager getCurrentItemIndex] - 1];
        [self refreshCurrentDisplay:nil];
    }
}

- (IBAction)rightButtonEvent:(id)sender
{
    if (self.type == reminderViewTypeRemind)
    {
        [ReminderManager markAsIHaveDoneItAtIndex:[ReminderManager getCurrentItemIndex]];
        if ([ReminderManager getCurrentItemIndex] + 1 == [ReminderManager getItemsNeedBeenRemindCount])
        {
            [ReminderManager setCurrentItemIndex:0];
        }
        else
        {
            [ReminderManager setCurrentItemIndex:[ReminderManager getCurrentItemIndex] + 1];
        }
        [self refreshCurrentDisplay:nil];
    }
    else
    {
        [ReminderManager setCurrentItemIndex:[ReminderManager getCurrentItemIndex] + 1];
        [self refreshCurrentDisplay:nil];
    }
}

@end
