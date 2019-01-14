//
//  XIActionSheetView.h
//  XIActionSheetView
//
//  Created by jun.zhou on 2019/1/14.
//  Copyright © 2019 jun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class XIActionSheetView;

typedef void (^XIActionSheetBlock)(XIActionSheetView *sheetView, NSInteger selectIndex);

@interface XIActionSheetView : UIView

- (instancetype)initWithTitle:(NSString *)title
            otherButtonTitles:(NSArray *)otherButtonTitles
                     selectIndex:(NSString *)selectIndex
                      handler:(XIActionSheetBlock)actionSheetBlock;


+ (void)showActionSheetWithTitle:(NSString *)title
               otherButtonTitles:(NSArray *)otherButtonTitles
                        selectIndex:(NSString *)selectIndex
                         handler:(XIActionSheetBlock)actionSheetBlock;
@end

NS_ASSUME_NONNULL_END
