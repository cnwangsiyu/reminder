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
}

- (void)buildViews:(id)sender
{
    self.view.backgroundColor = COLOR_AB;
    
    if (type == EditViewControllerTypeEdit)
    {
        self.title = @"编辑";
        AddModeNavBar.hidden = YES;
        
        UIImageView *saveButtonImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"save"]];
        saveButtonImage.frame = CGRectMake(0, 0, 24, 24);
        [saveButtonImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(save:)]];
        UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithCustomView:saveButtonImage];
        [self.navigationItem setRightBarButtonItem:saveItem];
    }
    else
    {
        self.navigationController.navigationBarHidden = YES;
        AddModeNavBar.barTintColor = COLOR_AG;
    }
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, FULLSCREEN_WIDTH, FULLSCREEN_HEIGHT - 64)];
    scrollView.contentSize = CGSizeMake(FULLSCREEN_WIDTH, FULLSCREEN_HEIGHT - 64);
    
    scrollView.userInteractionEnabled = YES;
    [scrollView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyBoard:)]];
    
    [self.view addSubview:scrollView];
    
    titleText = [[UITextField alloc] initWithFrame:CGRectMake(10, 20, FULLSCREEN_WIDTH - 20, 40)];
    titleText.borderStyle = UITextBorderStyleRoundedRect;
    titleText.text = selectedItem.title;
    titleText.textAlignment = NSTextAlignmentCenter;
    titleText.placeholder = @"请输入标题";
    titleText.backgroundColor = [UIColor clearColor];
    [scrollView addSubview:titleText];
    
    detailText = [[UITextView alloc] initWithFrame:CGRectMake(10, 80, FULLSCREEN_WIDTH - 20, 200)];
    detailText.text = selectedItem.detail;
    detailText.layer.borderColor = COLOR_AD.CGColor;
    detailText.layer.borderWidth = 1;
    detailText.layer.cornerRadius = 5;
    detailText.layer.masksToBounds = YES;
    detailText.backgroundColor = [UIColor clearColor];
    detailText.font = [UIFont systemFontOfSize:18];
    detailText.delegate = self;
    [scrollView addSubview:detailText];
    
    UILabel *placeHolder = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 200, 30)];
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
    
    CGRect frame = detailText.frame;
    top = frame.origin.y + frame.size.height + 10;
    imageContainer = [[UIView alloc] initWithFrame:CGRectMake(frame.origin.x, top, frame.size.width, 120)];
    imageContainer.backgroundColor = [UIColor clearColor];
    [scrollView addSubview:imageContainer];
    
    addImageButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    addImageButton.frame = CGRectMake(10, 0, 60, 60);
    [addImageButton addTarget:self action:@selector(pickImage:) forControlEvents:UIControlEventTouchUpInside];
    addImageButton.tintColor = [UIColor darkGrayColor];
    addImageButton.tag = 99999;
    [imageContainer addSubview:addImageButton];
    
    [self buildImageView:nil];
    
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
    }
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
    
    [self buildImageView:nil];
}

- (void)buildImageView:(id)sender
{
    int imageTag = IMAGE_TAG;
    
    for (UIView *childView in imageContainer.subviews)
    {
        if (childView.tag != 99999) {
            [childView removeFromSuperview];
        }
    }
    
    for (UIImage *image in selectedItem.images) {
        
        UIImageView *imageView = [[UIImageView alloc]
                                  initWithFrame:CGRectMake(70 * ((imageTag - IMAGE_TAG) % 4) + 10,
                                                           70 * ((imageTag - IMAGE_TAG) / 4),
                                                           60, 60)];
        
        imageView.image = image;
        
        imageView.tag = imageTag;
        
        imageView.userInteractionEnabled = YES;
        
        [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openImageScaleInView:)]];
        
        imageTag ++ ;
        
        [imageContainer addSubview:imageView];
        
    }
    scrollView.contentSize = CGSizeMake(FULLSCREEN_WIDTH, deleteButton.frame.origin.y + deleteButton.frame.size.height + 50);
    addImageButton.frame =
    CGRectMake(70 * ((imageTag - IMAGE_TAG) % 4) + 10, 70 * ((imageTag - IMAGE_TAG) / 4), 60, 60);
    if (type == EditViewControllerTypeEdit) {
        deleteButton.frame = CGRectMake(deleteButton.frame.origin.x, top + 80 + 70 * ((imageTag - IMAGE_TAG) / 4), deleteButton.frame.size.width, deleteButton.frame.size.height);
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

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    if (!selectedItem.title.length) {
        selectedItem.title = @"未命名事项";
    }
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
            [ReminderManager addItem:selectedItem];
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
    
    [(MainViewController *)[self.navigationController.viewControllers objectAtIndex:0] refreshRemindCount:nil];
    
    [self closeKeyBoard:nil];
    self.navigationController.navigationBarHidden = NO;
}

- (void)cancel:(id)sender
{
    [self closeKeyBoard:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)close:(id)sender
{
    [self closeKeyBoard:nil];
    self.navigationController.navigationBarHidden = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
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
