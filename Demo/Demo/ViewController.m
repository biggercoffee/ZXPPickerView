//
//  ViewController.m
//  Demo
//
//  Created by 张孝平 on 16/3/23.
//  Copyright © 2016年 coffee. All rights reserved.
//

#import "ViewController.h"
#import "ZXPPickerView.h"
@interface ViewController () <ZXPPickerViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonAction:(id)sender {
    ZXPPickerView *picker = [ZXPPickerView new];
    //    picker.dataSource = @[@[@"1",@"1-2"],@[@"2",@"2-2",@"2-3"]];
    picker.delegate = self;
    [picker show];
}

- (void)zxp_pickerView:(ZXPPickerView *)pickerView didSelectRow:(NSInteger)row section:(NSInteger)component {
    //    NSMutableArray<NSArray<NSString *> *> *newDataSource = [pickerView.dataSource mutableCopy];
    //    if (component == 0 ) {
    //        newDataSource[1] = @[[NSString stringWithFormat:@"change%zi-1",row],[NSString stringWithFormat:@"change%zi-2",row]];
    //    }
    //    pickerView.dataSource = newDataSource;
    //    [pickerView reloadDataWithSection:1];
}

- (void)zxp_pickerViewConfirmAction:(ZXPPickerView *)pickerView didSelectArray:(NSArray<NSNumber *> *)selectedArray {
    NSLog(@"%@--%@",pickerView,selectedArray);
}

@end
