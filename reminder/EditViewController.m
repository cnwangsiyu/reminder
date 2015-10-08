//
//  editViewController.m
//  reminder
//
//  Created by WangSiyu on 15/10/1.
//  Copyright © 2015年 WangSiyu. All rights reserved.
//

#import "EditViewController.h"
#import "ReminderManager.h"
#import "MainViewController.h"
#import "PhotoBroswerVC.h"

#define IMAGE_TAG 1441

@interface EditViewController ()<UIImagePickerControllerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UITextViewDelegate>
{
    EventItem *selectedItem;
    UIView *imageContainer;
    UIButton *addImageButton;
    UIActionSheet *sheet;
    UIScrollView *scrollView;
    UITextField *titleText;
    UITextView *detailText;
    UIButton *deleteButton;
    float top;
    float imageWidth;
    enum EditViewControllerType type;
}

@property (nonatomic, weak) IBOutlet UIButton *saveButton;
@property (nonatomic, weak) IBOutlet UIButton *closeButton;
@property (nonatomic, weak) IBOutlet UINavigationBar *AddModeNavBar;

@end

@implementation EditViewController

@synthesize saveButton;
@synthesize closeButton;
@synthesize AddModeNavBar;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self buildViews:nil];
    
    [self registerObservers:nil];
}

- (void)buildViews:(id)sender
{
    {
        self.view.backgroundColor = COLOR_AB;
    }
    
    {
        if (type == EditViewControllerTypeEdit)
        {
            self.title = @"编辑";
            AddModeNavBar.hidden = YES;
            
            UIImageView *saveButtonImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"save"]];
            saveButtonImage.frame = CGRectMake(0, 0, 24, 24);
            [saveButtonImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(save:)]];
            UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithCustomView:saveButtonImage];
            [self.navigationItem setRightBarButtonItem:saveItem];
            
            UIBarButtonItem *resighItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleBordered target:self action:@selector(resighed:)];
            [self.navigationItem setLeftBarButtonItem:resighItem];
        }
        else
        {
            self.navigationController.navigationBarHidden = YES;
            AddModeNavBar.barTintColor = COLOR_AG;
        }
    }
    
    {
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, FULLSCREEN_WIDTH, FULLSCREEN_HEIGHT - 64)];
        scrollView.userInteractionEnabled = YES;
        [scrollView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyBoard:)]];
        
        [self.view addSubview:scrollView];
    }
    
    {
        titleText = [[UITextField alloc] initWithFrame:CGRectMake(10, 20, FULLSCREEN_WIDTH - 20, 40)];
        titleText.borderStyle = UITextBorderStyleRoundedRect;
        titleText.text = selectedItem.title;
        titleText.textAlignment = NSTextAlignmentLeft;
        titleText.placeholder = @"请输入标题";
        titleText.backgroundColor = [UIColor clearColor];
        titleText.tintColor = [UIColor blackColor];
        [scrollView addSubview:titleText];
    }
    
    {
        detailText = [[UITextView alloc] initWithFrame:CGRectMake(10, 80, FULLSCREEN_WIDTH - 20, 200)];
        detailText.text = selectedItem.detail;
        detailText.layer.borderColor = COLOR_AD.CGColor;
        detailText.layer.borderWidth = 1;
        detailText.layer.cornerRadius = 5;
        detailText.layer.masksToBounds = YES;
        detailText.backgroundColor = [UIColor clearColor];
        detailText.font = [UIFont systemFontOfSize:18];
        detailText.tintColor = titleText.tintColor;
        detailText.delegate = self;
        [scrollView addSubview:detailText];
    }
    
    {
        UILabel *placeHolder = [[UILabel alloc] initWithFrame:CGRectMake(5, 3, 200, 30)];
        placeHolder.textColor = [UIColor lightGrayColor];
        if (detailText.text.length)
        {
            placeHolder.text = @"";
        }
        else
        {
            placeHolder.text = @"请输入事件内容";
        }
        placeHolder.alpha = 0.5;
        placeHolder.tag = 7658;
        [detailText addSubview:placeHolder];
    }
    
    
    CGRect frame = detailText.frame;
    top = frame.origin.y + frame.size.height + 20;
    imageWidth = (frame.size.width - 3*10) / 4;
    
    {
        imageContainer = [[UIView alloc] initWithFrame:CGRectMake(frame.origin.x, top, frame.size.width, imageWidth)];
        imageContainer.backgroundColor = [UIColor clearColor];
        [scrollView addSubview:imageContainer];
        
        addImageButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
        addImageButton.frame = CGRectMake(0, 0, imageWidth, imageWidth);
        [addImageButton addTarget:self action:@selector(pickImage:) forControlEvents:UIControlEventTouchUpInside];
        addImageButton.tintColor = [UIColor darkGrayColor];
        addImageButton.layer.borderColor = addImageButton.tintColor.CGColor;
        addImageButton.layer.borderWidth = 1;
        addImageButton.layer.cornerRadius = 5;
        addImageButton.layer.masksToBounds = YES;
        addImageButton.tag = 99999;
        [imageContainer addSubview:addImageButton];
        scrollView.contentSize = CGSizeMake(FULLSCREEN_WIDTH, imageContainer.frame.origin.y + addImageButton.frame.origin.y + addImageButton.frame.size.height + 50);
        
    }
    
    {
        if (type == EditViewControllerTypeEdit) {
            deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.origin.x, top + 80, FULLSCREEN_WIDTH - 2*frame.origin.x, 40)];
            deleteButton.layer.borderColor = COLOR_AD.CGColor;
            deleteButton.layer.borderWidth = 1;
            deleteButton.layer.cornerRadius = 5;
            deleteButton.layer.masksToBounds = YES;
            [deleteButton setTitle:@"删  除" forState:UIControlStateNormal];
            [deleteButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            deleteButton.backgroundColor = COLOR_AC;
            [deleteButton addTarget:self action:@selector(deleteItem:) forControlEvents:UIControlEventTouchUpInside];
            [scrollView addSubview:deleteButton];
            scrollView.contentSize = CGSizeMake(FULLSCREEN_WIDTH, deleteButton.frame.origin.y + deleteButton.frame.size.height + 20);
        }
        [self buildImageView:nil];
    }
}

- (void)registerObservers:(id)sender
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteImage:) name:@"deleteImage" object:nil];
    if (type == EditViewControllerTypeAdd)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(close:) name:UIApplicationWillTerminateNotification object:nil];
    }
}

- (void)deleteImage:(NSNotification *)noti
{
    NSNumber *number = noti.object;
    NSUInteger index = [number unsignedIntegerValue];
    [ReminderManager removeImageInFileForItem:selectedItem index:index];
    [selectedItem.images removeObjectAtIndex:index];
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(buildImageView:) userInfo:nil repeats:NO];
}

- (void)textViewDidChange:(UITextView *)textView
{
    UILabel *placeHolder = (UILabel *)[textView viewWithTag:7658];
    if (textView.text.length == 0)
    {
        placeHolder.text = @"请输入事件内容";
    }
    else
    {
        placeHolder.text = @"";
    }
}

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 255)
    {
        
        NSUInteger sourceType = 0;
        
        // 判断是否支持相机
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            
            switch (buttonIndex)
            {
                case 0:
                    // 相机
                    sourceType = UIImagePickerControllerSourceTypeCamera;
                    break;
                case 1:
                    // 相册
                    sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    break;
                case 2:
                    // 取消
                    return;
            }
        }
        else
        {
            if (buttonIndex == 0)
            {
                sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            }
            else
            {
                return;
            }
        }
        // 跳转到相机或相册页面
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        
        imagePickerController.delegate = self;
        
        imagePickerController.allowsEditing = NO;
        
        imagePickerController.sourceType = sourceType;
        
        [self presentViewController:imagePickerController animated:YES completion:^{}];
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    }
}

- (void)pickImage:(id)sender
{
    
    // 判断是否支持相机
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        sheet  = [[UIActionSheet alloc] initWithTitle:@"选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"从相册选择" , nil];
    }
    else {
        
        sheet = [[UIActionSheet alloc] initWithTitle:@"选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从相册选择", nil];
    }
    
    sheet.tag = 255;
    
    [sheet showInView:self.view];
}

#pragma mark - image picker delegte
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{}];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    [selectedItem.images addObject:image];
    
    [ReminderManager saveImageToFile:image ForItem:selectedItem index:selectedItem.images.count - 1];
    
    [self buildImageView:nil];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

- (void)buildImageView:(id)sender
{
    int index = 0;
    
    float imageCellWidth = imageWidth + 10;
    
    for (UIView *childView in imageContainer.subviews)
    {
        if (childView.tag != 99999) {
            [childView removeFromSuperview];
        }
    }
    
    for (UIImage *image in selectedItem.images) {
        
        UIImageView *imageView = [[UIImageView alloc]
                                  initWithFrame:CGRectMake(
                                                           imageCellWidth * (index % 4),
                                                           imageCellWidth * (index / 4),
                                                           imageWidth, imageWidth)];
        imageView.tintColor = [UIColor darkGrayColor];
        imageView.layer.borderColor = addImageButton.tintColor.CGColor;
        imageView.layer.borderWidth = 1;
        imageView.layer.cornerRadius = 5;
        imageView.layer.masksToBounds = YES;
        
        imageView.image = image;
        
        imageView.tag = IMAGE_TAG + index;
        
        imageView.userInteractionEnabled = YES;
        
        [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openImageScaleInView:)]];
        
        index ++ ;
        
        [imageContainer addSubview:imageView];
    }
    
    imageContainer.frame = CGRectMake(imageContainer.frame.origin.x, imageContainer.frame.origin.y, imageContainer.frame.size.width, (index / 4) * imageCellWidth + imageWidth);
    
    addImageButton.frame =
    CGRectMake(imageCellWidth * (index % 4), imageCellWidth * (index / 4), imageWidth, imageWidth);
    
    if (type == EditViewControllerTypeEdit)
    {
        deleteButton.frame = CGRectMake(deleteButton.frame.origin.x, top + 80 + imageCellWidth * (index / 4), deleteButton.frame.size.width, deleteButton.frame.size.height);
        
        scrollView.contentSize = CGSizeMake(FULLSCREEN_WIDTH, deleteButton.frame.origin.y + deleteButton.frame.size.height + 20);
    }
    else
    {
        scrollView.contentSize = CGSizeMake(FULLSCREEN_WIDTH, imageContainer.frame.origin.y + addImageButton.frame.origin.y + addImageButton.frame.size.height + 20);
    }
}

- (void)openImageScaleInView:(UITapGestureRecognizer *)tapGesture
{
    UIImageView *imageView = (UIImageView *)tapGesture.view;
    
    long index = imageView.tag - IMAGE_TAG;
    [PhotoBroswerVC show:self type:PhotoBroswerVCTypeZoom index:index showDeleteButton:YES photoModelBlock:
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

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil editViewControllerType:(enum EditViewControllerType)newType
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        type = newType;
        if (type == EditViewControllerTypeEdit)
        {
            selectedItem = [ReminderManager getItemAtIndex:[ReminderManager getCurrentItemIndex]];
            if (!selectedItem) {
                selectedItem = [EventItem new];
            }
        }
        else if (type == EditViewControllerTypeAdd)
        {
            selectedItem = [EventItem new];
        }
    }
    return self;
}

- (IBAction)save:(id)sender
{
    
    selectedItem.title = titleText.text;
    selectedItem.detail = detailText.text;
    BOOL isInvalid = !selectedItem.title.length && !selectedItem.detail.length && selectedItem.images.count == 0;
    if (type == EditViewControllerTypeEdit)
    {
        if (isInvalid) {
            [ReminderManager removeItemAtIndex:[ReminderManager getCurrentItemIndex]];
        }
        else
        {
            [ReminderManager setItem:selectedItem AtIndex:[ReminderManager getCurrentItemIndex]];
        }
    }
    else
    {
        if(!isInvalid)
        {
            if (!selectedItem.title.length) {
                selectedItem.title = @"未命名事项";
            }
            [ReminderManager addItem:selectedItem];
        }
    }
    
    [[ReminderManager getMainTableView] reloadData];
    [[ReminderManager getReminderViewController] refreshCurrentDisplay:nil];
    
    if (type == EditViewControllerTypeEdit)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NT_REFRESH_MAIN object:self];
    
    [self closeKeyBoard:nil];
    self.navigationController.navigationBarHidden = NO;
}

- (IBAction)close:(id)sender
{
    [self closeKeyBoard:nil];
    self.navigationController.navigationBarHidden = NO;
    [ReminderManager removeEventImagesInFile:selectedItem];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)resighed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)deleteItem:(id)sender
{
    if ([ReminderManager getCurrentItemIndex] >= 0){
        [ReminderManager removeItemAtIndex:[ReminderManager getCurrentItemIndex]];
    }
    [[ReminderManager getMainTableView] reloadData];
    [[ReminderManager getReminderViewController] refreshCurrentDisplay:nil];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)closeKeyBoard:(id)sender
{
    [titleText resignFirstResponder];
    [detailText resignFirstResponder];
}

@end
