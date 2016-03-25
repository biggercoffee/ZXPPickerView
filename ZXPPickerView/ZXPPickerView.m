//
//  ZXPPickerView.m
//  Demo
//
//  Created by 张孝平 on 16/3/23.
//  Copyright © 2016年 coffee. All rights reserved.
//

#import "ZXPPickerView.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#define kZXPWeakSelf autoreleasepool {} __weak typeof(self) p_self_weak = self;
#define kZXPStrongSelf autoreleasepool {} __strong typeof(p_self_weak) self = p_self_weak;

static const CGFloat kAnimateDurationOfBackgroundView = 0.25;
static const CGFloat kHeightForPickerView = 216;
static const CGFloat kHeightForToolBarView = 40;
static const void * kZXPPickerViewKey = &kZXPPickerViewKey;

#pragma mark - toolBar class

@interface P_ZXPToolBarView : UIView

- (void)confirmButtonActionBlock:(nonnull void(^)(UIButton *btn))block;
- (void)cancelButtonActionBlock:(nonnull void(^)(UIButton *btn))block;

@end

@interface P_ZXPToolBarView ()

@property (nonatomic,strong) UIButton *cancelButton;
@property (nonatomic,strong) UIButton *confirmButton;

@property (nonatomic,copy) void(^confirmActionBlock)();
@property (nonatomic,copy) void(^cancelActionBlock)();

@end

@implementation P_ZXPToolBarView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        //init background color
        self.backgroundColor = [UIColor colorWithRed:0 green:187/255.0 blue:255/255.0 alpha:1];
        
        // add subviews
        [self addSubview:self.cancelButton];
        [self addSubview:self.confirmButton];
        
        [self p_initLayout];
        
    }
    return self;
}

#pragma mark - public

- (void)confirmButtonActionBlock:(void (^)(UIButton *))block {
    NSAssert(block, @"block can't nil");
    self.confirmActionBlock = [block copy];
}

- (void)cancelButtonActionBlock:(void (^)(UIButton *))block {
    NSAssert(block, @"block can't nil");
    self.cancelActionBlock = [block copy];
}

#pragma mark - private

- (void)p_initLayout {
    self.cancelButton.frame = CGRectMake(0, 0, 60, CGRectGetHeight(self.frame));
    self.confirmButton.frame = CGRectMake(CGRectGetWidth(self.frame) - 60 , 0, 60, CGRectGetHeight(self.frame));
}

- (__kindof UIButton * _Nonnull)p_initPropertiesForButtonWithTitle:(NSString *)title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    return button;
}

- (void)p_confirmActon:(UIButton *)sender {
    NSAssert(self.confirmActionBlock, @"block can't nil");
    self.confirmActionBlock(sender);
}

- (void)p_cancelActon:(UIButton *)sender {
    NSAssert(self.cancelActionBlock, @"block can't nil");
    self.cancelActionBlock(sender);
}

#pragma mark - getter

- (UIButton *)cancelButton {
    return _cancelButton?:(_cancelButton = ({
        UIButton *btn = [self p_initPropertiesForButtonWithTitle:@"取消"];
        [btn addTarget:self action:@selector(p_cancelActon:) forControlEvents:UIControlEventTouchUpInside];
        btn;
    }));
}

- (UIButton *)confirmButton {
    return _confirmButton?:(_confirmButton = ({
        UIButton *btn = [self p_initPropertiesForButtonWithTitle:@"确定"];
        [btn addTarget:self action:@selector(p_confirmActon:) forControlEvents:UIControlEventTouchUpInside];
        btn;
    }));
}

@end


#pragma mark - picker view class

@interface ZXPPickerView () <UIPickerViewDelegate,UIPickerViewDataSource>

@property (nonatomic,strong) UIView *backgroundView;

@property (nonatomic,strong) UIPickerView *pickerView;

@property (nonatomic,strong) P_ZXPToolBarView *toolBarView;

@property (nonatomic,assign) NSUInteger selectedOfRow;
@property (nonatomic,assign) NSUInteger selectedOfSection;

@property (nonatomic,strong) NSMutableArray<NSNumber *> *selectedIndexs;

@end

@implementation ZXPPickerView

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [[UIApplication sharedApplication].keyWindow addSubview:self.backgroundView];
        
        [self.backgroundView addSubview:self.pickerView];
        [self.backgroundView addSubview:self.toolBarView];
        
        [self p_initLayout];
        
        [self p_setupInitDataSource];
        
    }
    return self;
}

#pragma mark - public

- (void)show {
    CGRect frameForPicker = self.pickerView.frame;
    frameForPicker.origin.y = frameForPicker.origin.y - kHeightForPickerView - kHeightForToolBarView;
    
    __block CGRect frameForToolBar = self.toolBarView.frame;
    frameForToolBar.origin.y = frameForToolBar.origin.y - kHeightForToolBarView - kHeightForPickerView;
    
    [UIView animateWithDuration:kAnimateDurationOfBackgroundView animations:^{
        self.backgroundView.alpha = 1;
        self.pickerView.frame = frameForPicker;
        self.toolBarView.frame = frameForToolBar;
    }];
}

- (void)dismiss {
    CGRect frameForPicker = self.pickerView.frame;
    frameForPicker.origin.y += kHeightForPickerView + kHeightForToolBarView;
    
    CGRect frameForToolBar = self.toolBarView.frame;
    frameForToolBar.origin.y = CGRectGetHeight(self.backgroundView.frame);
    
    [UIView animateWithDuration:kAnimateDurationOfBackgroundView animations:^{
        self.backgroundView.alpha = 0;
        self.pickerView.frame = frameForPicker;
        self.toolBarView.frame = frameForToolBar;
    } completion:^(BOOL finished) {
        [self.backgroundView removeFromSuperview];
        
        // dealloc self
        objc_setAssociatedObject(self, kZXPPickerViewKey, nil, OBJC_ASSOCIATION_ASSIGN);
    }];
}

- (void)selectedRow:(NSInteger)row section:(NSInteger)section animation:(BOOL)animation {
    [self.pickerView selectRow:row inComponent:section animated:animation];
    self.selectedIndexs[section] = @(row);
}

- (void)reloadData {
    [self.pickerView reloadAllComponents];
}

- (void)reloadDataWithSection:(NSInteger)section {
    [self.pickerView reloadComponent:section];
}

#pragma mark - UIPickerViewDelegate & UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return self.dataSource.count;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.dataSource[component].count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.dataSource[component][row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.selectedIndexs[component] = @(row);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(zxp_pickerView:didSelectRow:section:)]) {
        [self.delegate zxp_pickerView:self didSelectRow:row section:component];
    }
}

#pragma mark - private

- (void)p_initLayout {
    self.backgroundView.frame = [UIApplication sharedApplication].keyWindow.frame;
    
    self.pickerView.frame = CGRectMake(0, CGRectGetHeight([UIScreen mainScreen].bounds) + kHeightForToolBarView, CGRectGetWidth(UIScreen.mainScreen.bounds), kHeightForPickerView);
    
    self.toolBarView.frame = CGRectMake(0, CGRectGetHeight([UIScreen mainScreen].bounds), CGRectGetWidth(UIScreen.mainScreen.bounds), kHeightForToolBarView);
}

- (void)p_pickerConfirmAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(zxp_pickerViewConfirmAction:didSelectArray:)]) {
        [self.delegate zxp_pickerViewConfirmAction:self didSelectArray:self.selectedIndexs];
    }
}

- (void)p_setupInitDataSource {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM/dd"];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];

    NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday;
    
    NSMutableArray *arrayForYear = [NSMutableArray array];
    NSMutableArray *arrayForMonth = [NSMutableArray array];
    NSMutableArray *arrayForDay = [NSMutableArray array];
    
    NSDateComponents *component = [calendar components:unit fromDate:[NSDate date]];
    
    //add year
    for (long int i = component.year - 5; i < component.year + 5; i++) {
        [arrayForYear addObject:[NSString stringWithFormat:@"%zi年",i]];
    }
    
    //add month
    for (int i = 1; i<=12; i++) {
        [arrayForMonth addObject:[NSString stringWithFormat:@"%zi月",i]];
    }
    
    // add day
    NSDate *date = [formatter dateFromString:[NSString stringWithFormat:@"%zi/%zi/1",component.year,component.month]];
    NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    
    for (int j = 1; j <= range.length; j++) {
        [arrayForDay addObject:[NSString stringWithFormat:@"%zi日",j]];
    }

    self.dataSource = @[arrayForYear,arrayForMonth,arrayForDay];
    
    //selected row
    NSUInteger selectedYearIndex = [arrayForYear indexOfObject:[NSString stringWithFormat:@"%zi年",component.year]];
    NSUInteger selectedMonthIndex = [arrayForMonth indexOfObject:[NSString stringWithFormat:@"%zi月",component.month]];
    NSUInteger selectedDayIndex = [arrayForDay indexOfObject:[NSString stringWithFormat:@"%zi日",component.day]];
    [self selectedRow:selectedYearIndex section:0 animation:NO];
    [self selectedRow:selectedMonthIndex section:1 animation:NO];
    [self selectedRow:selectedDayIndex section:2 animation:NO];
}

#pragma mark - getter & setter

- (void)setDataSource:(NSArray<NSArray<NSString *> *> *)dataSource {
    _dataSource = dataSource;
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
}

- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [UIView new];
        _backgroundView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
        _backgroundView.alpha = 0;
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backgroundView addSubview:btn];
        btn.frame = [UIApplication sharedApplication].keyWindow.frame;
        
        // retain self
        objc_setAssociatedObject(self, kZXPPickerViewKey, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        [btn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backgroundView;
}

- (UIPickerView *)pickerView {
    if (_pickerView == nil) {
        _pickerView = [[UIPickerView alloc] init];
        _pickerView.backgroundColor = [UIColor whiteColor];
        _pickerView.dataSource = self;
        _pickerView.delegate = self;
    }
    return _pickerView;
}

- (NSMutableArray<NSNumber *> *)selectedIndexs {
    return _selectedIndexs?:(_selectedIndexs = ({
        NSMutableArray *array = [NSMutableArray array];
        for (long int i = 0; i<self.dataSource.count; i++) {
            [array addObject:@0];
        }
        array;
    }));
}

- (P_ZXPToolBarView *)toolBarView {
    return _toolBarView?:(_toolBarView = ({
        P_ZXPToolBarView *toolBar = [[P_ZXPToolBarView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(UIScreen.mainScreen.bounds), kHeightForToolBarView)];
        @kZXPWeakSelf;
        [toolBar confirmButtonActionBlock:^(UIButton *btn) {
            @kZXPStrongSelf;
            [self p_pickerConfirmAction];
            [self dismiss];
        }];
        [toolBar cancelButtonActionBlock:^(UIButton *btn) {
            @kZXPStrongSelf;
            [self dismiss];
        }];
        toolBar;
    }));
}

@end
