//
//  ViewController.m
//  XIActionSheetView
//
//  Created by jun.zhou on 2019/1/14.
//  Copyright © 2019 jun. All rights reserved.
//

#import "ViewController.h"
#import "XIActionSheetView.h"

@interface ViewController ()

@end

@implementation ViewController
- (IBAction)buttonClick:(id)sender {
    NSArray *array = @[@"A",@"B",@"C",@"D",@"E"];
    [XIActionSheetView showActionSheetWithTitle:@"abc" otherButtonTitles:array selectIndex:@(0).stringValue handler:^(XIActionSheetView * _Nonnull sheetView, NSInteger selectIndex) {
        NSLog(@"选中了--%ld",(long)selectIndex);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


@end
