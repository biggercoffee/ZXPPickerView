//
//  ZXPPickerView.h
//  Demo

//  version: 0.1

//  Created by 张孝平 on 16/3/23.
//  Copyright © 2016年 coffee. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZXPPickerView;
@protocol ZXPPickerViewDelegate <NSObject>

@optional
- (void)zxp_pickerView:(ZXPPickerView *)pickerView didSelectRow:(NSInteger)row section:(NSInteger)section;

- (void)zxp_pickerViewConfirmAction:(ZXPPickerView *)pickerView didSelectArray:(NSArray <NSNumber *> *)selectedArray;

@end

@interface ZXPPickerView : NSObject

@property (nonatomic,strong) NSArray<NSArray<NSString *> *> *dataSource;
@property (nonatomic,assign) id<ZXPPickerViewDelegate> delegate;

- (void)show;

- (void)dismiss;

- (void)selectedRow:(NSInteger)row section:(NSInteger)section animation:(BOOL)animation;

- (void)reloadData;
- (void)reloadDataWithSection:(NSInteger)section;

@end
