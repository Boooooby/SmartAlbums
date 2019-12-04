//
//  OpenPhotosViewController.m
//  SmartAlbums
//
//  Created by Booooby on 2019/11/15.
//  Copyright © 2019 Booooby. All rights reserved.
//

#import "OpenPhotosViewController.h"
#import "Masonry.h"
#import "UIColor+Hex.h"
#import "DropdownMenu.h"

// 静态全局变量
static CGFloat screenHeight;
static CGFloat screenWidth;

@interface OpenPhotosViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, DropDownMenuDataSource, DropDownMenuDelegate>

@property (nonatomic, strong) DropdownMenu *dropDownMenu;
@property (nonatomic, copy) NSArray *menuOptionTitles;
@property (nonatomic, copy) NSArray *menuOptionIcons;

@property (nonatomic, strong) UIImageView *testPhotoHolder;

@property (nonatomic, strong) UIImageView *addPhotosBtn;
@property (nonatomic, strong) UIImageView *openMenuBtn;
@property (nonatomic, strong) UILabel *addPhotosText;

@end

@implementation OpenPhotosViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initVar];
    [self addSubViews];
    [self makeConstraints];
}


#pragma mark - Init

- (void)initVar {
    screenHeight = [UIScreen mainScreen].bounds.size.height;
    screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    _menuOptionTitles = @[@"教程", @"设置", @"帮助&反馈"];
    _menuOptionIcons = @[@"guide.png", @"setting.png", @"help.png"];
}

- (void)addSubViews {
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 测试
    UIImage *imageTest = [UIImage imageNamed:@"add.png"];
    self.testPhotoHolder = [[UIImageView alloc] initWithImage:imageTest];
    [self.view addSubview:self.testPhotoHolder];
    
    UIImage *imageMenu = [UIImage imageNamed:@"menu.png"];
    self.dropDownMenu = [[DropdownMenu alloc] init];
    self.dropDownMenu.dataSource = self;
    self.dropDownMenu.delegate = self;
    self.dropDownMenu.menuIcon = imageMenu;
    self.dropDownMenu.backgroundColor = [UIColor colorWithHexString:@"#6A6A6A"];
    self.dropDownMenu.textColor = [UIColor whiteColor];
    self.dropDownMenu.font = [UIFont systemFontOfSize:15];
    self.dropDownMenu.textAlignment = NSTextAlignmentLeft;
    self.dropDownMenu.animateTime = 0.25;
    [self.view addSubview:self.dropDownMenu];
    
    UIImage *imageAdd = [UIImage imageNamed:@"add.png"];
    self.addPhotosBtn = [[UIImageView alloc] initWithImage:imageAdd];
    self.addPhotosBtn.userInteractionEnabled = YES;
    UITapGestureRecognizer *addPhotos = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addPhotosBtnClick)];
    [self.addPhotosBtn addGestureRecognizer:addPhotos];
    [self.view addSubview:self.addPhotosBtn];
    
    self.addPhotosText = [[UILabel alloc] init];
    self.addPhotosText.text = @"打开您的图片";
    self.addPhotosText.textColor = [UIColor colorWithHexString:@"#BDBDBD"];
    self.addPhotosText.font = [UIFont systemFontOfSize:20];
    [self.view addSubview:self.addPhotosText];
}

- (void)makeConstraints {
    // 测试
    [self.testPhotoHolder mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(50);
        make.centerX.equalTo(self.view);
        make.height.and.width.equalTo(@100);
    }];
    
    [self.dropDownMenu mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(60);
        make.right.equalTo(self.view).offset(-20);
        make.width.and.height.equalTo(@30);
    }];
    
    [self.addPhotosBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view).offset(-30);
        make.width.and.height.equalTo(@150);
    }];
    
    [self.addPhotosText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.addPhotosBtn.mas_bottom).offset(20);
    }];
}


#pragma mark - TouchEvent

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint touchPoint = [[touches anyObject] locationInView:self.view];
    CALayer *viewLayer = _dropDownMenu.layer.presentationLayer;
    if (!CGRectContainsPoint(viewLayer.frame, touchPoint)) {
        [_dropDownMenu hideDropDownMenu];
    }
}


#pragma mark - TapGesture

- (void)addPhotosBtnClick {
    NSLog(@"addPhotosBtnClick");
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"拍照");
        // 获取相机权限
        AVAuthorizationStatus cameraStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (cameraStatus == AVAuthorizationStatusRestricted || cameraStatus == AVAuthorizationStatusDenied) {
            NSLog(@"无相机权限");
            UIAlertController *cameraAlert = [UIAlertController alertControllerWithTitle:nil message:@"请在\"设置 - 隐私 - 相机\"选项中允许访问您的相机" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:nil];
            [cameraAlert addAction:confirmAction];
            [self presentViewController:cameraAlert animated:YES completion:nil];
        }
        else {
            NSLog(@"有相机权限");
            // 判断是否有摄像头
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                NSLog(@"有摄像头");
                // 打开相机
                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                picker.delegate = self;
                picker.allowsEditing = YES;
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                [self presentViewController:picker animated:YES completion:nil];
            } else {
                NSLog(@"没有摄像头");
            }
        }
    }];
    UIAlertAction *albumAction = [UIAlertAction actionWithTitle:@"从手机相册中选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"从手机相册中选择");
        // 获取手机相册权限
        PHAuthorizationStatus albumStatus = [PHPhotoLibrary authorizationStatus];
        if (albumStatus == PHAuthorizationStatusRestricted || albumStatus == PHAuthorizationStatusDenied) {
            NSLog(@"无相册权限");
            UIAlertController *albumAlert = [UIAlertController alertControllerWithTitle:nil message:@"请在\"设置 - 隐私 - 相册\"选项中允许访问您的相册" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:nil];
            [albumAlert addAction:confirmAction];
            [self presentViewController:albumAlert animated:YES completion:nil];
        }
        else {
            NSLog(@"有相册权限");
            // 判断是否能打开相册
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                // 打开相册
                UIImagePickerController *picker = [[UIImagePickerController alloc]init];
                picker.allowsEditing = YES;
                picker.delegate = self;
                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                [self presentViewController:picker animated:YES completion:^{
                    NSLog(@"打开相册");
                }];
            } else {
                NSLog(@"不能打开相册");
            }
        }
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"取消");
    }];

    [alert addAction:cameraAction];
    [alert addAction:albumAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    UIImage *image = info[@"UIImagePickerControllerOriginalImage"];
    NSLog(@"获得图片");
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) { // 从相机拍照获得
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil); // 图片存入相册
        [self.testPhotoHolder setImage:image];
    }
    if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) { // 从相册获得
        [self.testPhotoHolder setImage:image];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - DropDownMenuDataSource

- (CGFloat)dropDownMenu:(nonnull DropdownMenu *)menu heightForOptionAtIndex:(NSInteger)index {
    return 50;
}

- (nonnull NSString *)dropDownMenu:(nonnull DropdownMenu *)menu titleForOptionAtIndex:(NSInteger)index {
    return _menuOptionTitles[index];
}

- (NSInteger)numberOfOptionsInDropDownMenu:(nonnull DropdownMenu *)menu {
    return _menuOptionTitles.count;
}

- (UIImage *)dropDownMenu:(DropdownMenu *)menu iconForOptionAtIndex:(NSInteger)index {
    return [UIImage imageNamed:_menuOptionIcons[index]];
}


#pragma mark - DropDownMenuDelegate

- (void)dropDownMenu:(DropdownMenu *)menu didSelectOptionAtIndex:(NSInteger)index withTitle:(nonnull NSString *)title {
    NSLog(@"%@", title);
}


@end
