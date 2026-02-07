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

@interface EditViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate>
{
    EventItem *selectedItem;
    UIView *imageContainer;
    UIButton *addImageButton;
    UIScrollView *scrollView;
    UITextField *titleText;
    UITextView *detailText;
    UIButton *deleteButton;
    float top;
    float imageWidth;
    enum EditViewControllerType type;
    //标记防止显示选择照片界面的时候误删除临时文件
    BOOL isShowImagePicker;
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (!isShowImagePicker) {
        [ReminderManager dismissImageChangesForItem:selectedItem];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
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
            saveButtonImage.userInteractionEnabled = YES;
            [saveButtonImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(save:)]];
            UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithCustomView:saveButtonImage];
            [self.navigationItem setRightBarButtonItem:saveItem];

            UIBarButtonItem *resighItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(resighed:)];
            [self.navigationItem setLeftBarButtonItem:resighItem];
        }
        else
        {
            self.navigationController.navigationBarHidden = YES;
            AddModeNavBar.barTintColor = COLOR_AG;
        }
    }

    {
        CGFloat topInset = 64;
        if (@available(iOS 11.0, *)) {
            UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
            topInset = window.safeAreaInsets.top + 44;
        }
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, topInset, FULLSCREEN_WIDTH, FULLSCREEN_HEIGHT - topInset)];
        scrollView.userInteractionEnabled = YES;
        [scrollView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyBoard:)]];
        scrollView.alwaysBounceVertical = YES;

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

- (void)showImagePickerWithSourceType:(UIImagePickerControllerSourceType)sourceType
{
    isShowImagePicker = YES;
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = NO;
    imagePickerController.sourceType = sourceType;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)pickImage:(id)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"选择" message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    // 判断是否支持相机
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [alertController addAction:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self showImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self showImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        }]];
    }
    else
    {
        [alertController addAction:[UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self showImagePickerWithSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
        }]];
    }

    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];

    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - image picker delegte
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    isShowImagePicker = NO;

    [picker dismissViewControllerAnimated:YES completion:^{}];

    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];

    [selectedItem.images addObject:image];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [ReminderManager saveImageToFile:image ForItem:selectedItem index:selectedItem.images.count - 1];
    });

    [self buildImageView:nil];
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
    isShowImagePicker = NO;
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil editViewControllerType:(enum EditViewControllerType)newType
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        type = newType;
        if (type == EditViewControllerTypeEdit) {
            selectedItem = [[ReminderManager getItemAtIndex:[ReminderManager getCurrentItemIndex]] copy];
        }
        if (!selectedItem) {
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
    if (type == EditViewControllerTypeEdit && isInvalid)
    {
        [ReminderManager removeItemAtIndex:[ReminderManager getCurrentItemIndex]];
    }
    else if(!isInvalid)
    {
        if (!selectedItem.title.length) {
            selectedItem.title = @"未命名事项";
        }
        [ReminderManager setItem:selectedItem AtIndex:[ReminderManager getCurrentItemIndex]];
    }
    [ReminderManager saveImageChangesForItem:selectedItem];

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
