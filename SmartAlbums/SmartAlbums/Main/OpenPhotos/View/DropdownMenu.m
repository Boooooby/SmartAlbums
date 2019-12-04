//
//  DropdownMenu.m
//  SmartAlbums
//
//  Created by Booooby on 2019/11/26.
//  Copyright © 2019 Booooby. All rights reserved.
//

#import "DropdownMenu.h"
#import "Masonry.h"

@interface DropdownMenu() <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIImageView *menuBtn;
@property (nonatomic, strong) UIImageView *triangle;
@property (nonatomic, strong) UITableView *optionsList;

@property (nonatomic, assign) BOOL isMenuShown;

@end

@implementation DropdownMenu


#pragma mark - HitTest

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (view == nil) {
        for (UIView *subView in self.subviews) {
            CGPoint myPoint = [subView convertPoint:point fromView:self];
            if (CGRectContainsPoint(subView.bounds, myPoint)) {
                view = subView;
            }
        }
    }
    return view;
}


#pragma mark - Initialization

- (id)init {
    self = [super init];
    if (self) {
        [self initProperty];
        [self initView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initProperty];
        [self initView];
    }
    return self;
}

- (void)initProperty {
    _isMenuShown = NO;
    
    _menuIcon = [UIImage imageNamed:@"menu.png"];
    _backgroundColor = [UIColor clearColor];
    _font = [UIFont systemFontOfSize:15];
    _textColor = [UIColor blackColor];
    _textAlignment = NSTextAlignmentCenter;

    _animateTime = 0.25f;
}

- (void)initView {
    // 主按钮 显示在界面上的点击按钮
    _menuBtn = [[UIImageView alloc] initWithImage:self.menuIcon];
    _menuBtn.userInteractionEnabled = YES;
    UITapGestureRecognizer *menuTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(menuBtnClick)];
    [_menuBtn addGestureRecognizer:menuTap];
    [self addSubview:_menuBtn];
    
    // 小三角形
    UIImage *imageTriangle = [UIImage imageNamed:@"triangle.png"];
    _triangle = [[UIImageView alloc] initWithImage:imageTriangle];
    _triangle.hidden = YES;
    [self addSubview:_triangle];
    
    // 下拉列表
    _optionsList = [[UITableView alloc] init];
    _optionsList.delegate = self;
    _optionsList.dataSource = self;
    _optionsList.hidden = YES;
    _optionsList.separatorColor = [UIColor whiteColor];
    _optionsList.layer.cornerRadius = 5;
    [self addSubview:_optionsList];
}

- (void)layoutSubviews {
    [_menuBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.and.height.equalTo(self);
    }];
    
    [_triangle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.and.height.equalTo(@30);
        make.top.equalTo(_menuBtn.mas_bottom).offset(5);
        make.centerX.equalTo(self);
    }];
    
    [_optionsList mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_triangle.mas_bottom).offset(-12);
        make.right.equalTo(self).offset(5);
        make.width.equalTo(@150);
        make.height.equalTo(@150);
    }];
}


#pragma mark - Selector

- (void)menuBtnClick {
    NSLog(@"menuBtnClick");
    
    if (self.isMenuShown == YES) {
        [self hideDropDownMenu];
    }
    else {
        [self showDropDownMenu];
    }
}


#pragma mark - Private Method

- (void)showDropDownMenu {
    if ([self.delegate respondsToSelector:@selector(dropDownMenuWillShow:)]) {
        [self.delegate dropDownMenuWillShow:self];
    }
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:self.animateTime animations:^{
        weakSelf.triangle.hidden = NO;
        weakSelf.optionsList.hidden = NO;
    } completion:^(BOOL finished) {
        if ([self.delegate respondsToSelector:@selector(dropDownMenuDidShow:)]) {
            [self.delegate dropDownMenuDidShow:self];
        }
    }];
    
    _isMenuShown = YES;
}

- (void)hideDropDownMenu {
    if ([self.delegate respondsToSelector:@selector(dropDownMenuWillHid:)]) {
        [self.delegate dropDownMenuWillHid:self];
    }
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:self.animateTime animations:^{
        weakSelf.triangle.hidden = YES;
        weakSelf.optionsList.hidden = YES;
    } completion:^(BOOL finished) {
        if ([self.delegate respondsToSelector:@selector(dropDownMenuDidHid:)]) {
            [self.delegate dropDownMenuDidHid:self];
        }
    }];
    
    _isMenuShown = NO;
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource numberOfOptionsInDropDownMenu:self];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.dataSource dropDownMenu:self heightForOptionAtIndex:indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"MenuOptionCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = self.backgroundColor;
        
        cell.separatorInset = UIEdgeInsetsMake(0, 50, 0, 5);
        
        UILabel *label = [[UILabel alloc] init];
        label.text = [self.dataSource dropDownMenu:self titleForOptionAtIndex:indexPath.row];
        label.font = self.font;
        label.textColor = self.textColor;
        label.textAlignment = self.textAlignment;
        label.tag = 10086;
        [cell addSubview:label];

        if ([self.delegate respondsToSelector:@selector(dropDownMenu:iconForOptionAtIndex:)]) {
            UIImageView *icon = [[UIImageView alloc] init];
            icon.image = [self.dataSource dropDownMenu:self iconForOptionAtIndex:indexPath.row];
            [cell addSubview:icon];
            
            [icon mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(cell.mas_left).offset(10);
                make.centerY.equalTo(cell);
                make.width.and.height.equalTo(@30);
            }];
            
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(icon.mas_right).offset(10);
                make.centerY.equalTo(cell);
            }];
        }
        else {
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(cell.mas_left).offset(10);
                make.centerY.equalTo(cell);
            }];
        }
    }
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UILabel *label = [cell viewWithTag:10086];
    if ([self.delegate respondsToSelector:@selector(dropDownMenu:didSelectOptionAtIndex:withTitle:)]) {
        [self.delegate dropDownMenu:self didSelectOptionAtIndex:indexPath.row withTitle:label.text];
    }
    [self hideDropDownMenu];
}


@end
