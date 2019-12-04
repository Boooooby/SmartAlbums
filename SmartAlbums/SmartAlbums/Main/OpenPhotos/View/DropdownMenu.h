//
//  DropdownMenu.h
//  SmartAlbums
//
//  Created by Booooby on 2019/11/26.
//  Copyright © 2019 Booooby. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DropdownMenu; // 向前声明

NS_ASSUME_NONNULL_BEGIN


@protocol DropDownMenuDataSource <NSObject>

@required
- (NSInteger)numberOfOptionsInDropDownMenu:(DropdownMenu *)menu;
- (CGFloat)dropDownMenu:(DropdownMenu *)menu heightForOptionAtIndex:(NSInteger)index;
- (NSString *)dropDownMenu:(DropdownMenu *)menu titleForOptionAtIndex:(NSInteger)index;

@optional
- (UIImage *)dropDownMenu:(DropdownMenu *)menu iconForOptionAtIndex:(NSInteger)index;

@end


@protocol DropDownMenuDelegate <NSObject>

@optional
- (void)dropDownMenuWillShow:(DropdownMenu *)menu;
- (void)dropDownMenuDidShow:(DropdownMenu *)menu;
- (void)dropDownMenuWillHid:(DropdownMenu *)menu;
- (void)dropDownMenuDidHid:(DropdownMenu *)menu;

- (void)dropDownMenu:(DropdownMenu *)menu didSelectOptionAtIndex:(NSInteger)index withTitle:(NSString *)title;

@end


@interface DropdownMenu : UIView <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id <DropDownMenuDataSource> dataSource;
@property (nonatomic, weak) id <DropDownMenuDelegate> delegate;

@property (nonatomic, strong) UIImage *menuIcon;

@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic) NSTextAlignment textAlignment;

@property (nonatomic, assign) CGFloat animateTime;

- (void)showDropDownMenu;
- (void)hideDropDownMenu;


@end

NS_ASSUME_NONNULL_END
