//
//  XIActionSheetView.m
//  XIActionSheetView
//
//  Created by jun.zhou on 2019/1/14.
//  Copyright © 2019 jun. All rights reserved.
//

#import "XIActionSheetView.h"

static const NSTimeInterval XIActionSheetAnimateDuration = 0.3f;
static NSString *kXIActionSheetCellIdentifier = @"kXIActionSheetCellIdentifier";

@interface XIActionSheetCell : UITableViewCell
@property (nonatomic, strong) UILabel *selTitleLabel;
@property (nonatomic, strong) UIImageView *selImgView;
@end

@implementation XIActionSheetCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _selTitleLabel = [[UILabel alloc] init];
        _selTitleLabel.font = [UIFont systemFontOfSize:16];
        _selTitleLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:_selTitleLabel];
        
        _selImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"selectIcon"]];
        [self.contentView addSubview:_selImgView];
        _selTitleLabel.frame = CGRectMake(15, 0, CGRectGetWidth(self.frame) - 100, CGRectGetHeight(self.frame));
        _selImgView.frame = CGRectMake(CGRectGetWidth(self.frame)-35,  CGRectGetHeight(self.frame)/2.f - 10, 20, 20);
        
    }
    return self;
}

@end


@interface XIActionSheetView ()<UITableViewDelegate,UITableViewDataSource>
/** block回调 */
@property (copy, nonatomic) XIActionSheetBlock actionSheetBlock;
/** 背景图片 */
@property (strong, nonatomic) UIView *backgroundView;
/** 弹出视图 */
@property (strong, nonatomic) UITableView *actionSheetView;
@property (nonatomic, copy) NSArray *buttonArray;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSIndexPath *indexPath;
@end


@implementation XIActionSheetView

- (instancetype)initWithTitle:(NSString *)title
            otherButtonTitles:(NSArray *)otherButtonTitles
                  selectIndex:(NSString *)selectIndex
                      handler:(XIActionSheetBlock)actionSheetBlock {
    self = [super init];
    if (!self) return nil;
    self.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    _actionSheetBlock = actionSheetBlock;
    _buttonArray = otherButtonTitles;
    _title = title;
    if (selectIndex) {
        _indexPath = [NSIndexPath indexPathForRow:selectIndex.integerValue inSection:0];
    }
    CGFloat actionSheetHeight = 0;
    
    _backgroundView = [[UIView alloc] initWithFrame:self.frame];
    _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _backgroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6f];
    _backgroundView.alpha = 0;
    [self addSubview:_backgroundView];
    CGFloat headerHeight = 42.f;
    CGFloat cellHeight = 47.f;
    
    _actionSheetView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, 0) style:UITableViewStylePlain];
    _actionSheetView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _actionSheetView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    _actionSheetView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self addSubview:_actionSheetView];
    _actionSheetView.delegate = self;
    _actionSheetView.dataSource = self;
    [_actionSheetView registerClass:[XIActionSheetCell class] forCellReuseIdentifier:kXIActionSheetCellIdentifier];
    _actionSheetView.rowHeight = cellHeight;
    _actionSheetView.sectionHeaderHeight = headerHeight;
    if (otherButtonTitles.count <= 4) {
        actionSheetHeight = headerHeight + cellHeight * otherButtonTitles.count ;
        _actionSheetView.scrollEnabled = NO;
    } else {
        actionSheetHeight = headerHeight + cellHeight * 4;
        _actionSheetView.alwaysBounceVertical = NO;
    }
    _actionSheetView.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, actionSheetHeight + 5);
    [_actionSheetView reloadData];
    return self;
}

+ (void)showActionSheetWithTitle:(NSString *)title
               otherButtonTitles:(NSArray *)otherButtonTitles
                     selectIndex:(NSString *)selectIndex
                         handler:(XIActionSheetBlock)actionSheetBlock {
    XIActionSheetView *selectView = [[self alloc] initWithTitle:title otherButtonTitles:otherButtonTitles selectIndex:selectIndex handler:actionSheetBlock];
    [selectView show];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.buttonArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XIActionSheetCell *cell = [tableView dequeueReusableCellWithIdentifier:kXIActionSheetCellIdentifier];
    if (indexPath.row == _indexPath.row) {
        cell.selImgView.hidden = NO;
    } else {
        cell.selImgView.hidden = YES;
    }
    cell.selTitleLabel.text = self.buttonArray[indexPath.row];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [self tableHeaderViewWithTitle:self.title];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.backgroundView];
    if (!CGRectContainsPoint(self.actionSheetView.frame, point)) {
        [self dismiss];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.actionSheetBlock) {
        self.actionSheetBlock(self, indexPath.row);
    }
    [self dismiss];
}

- (void)show {
    // 在主线程中处理,否则在viewDidLoad方法中直接调用,会先加本视图,后加控制器的视图到UIWindow上,导致本视图无法显示出来,这样处理后便会优先加控制器的视图到UIWindow上
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSEnumerator *frontToBackWindows = [UIApplication.sharedApplication.windows reverseObjectEnumerator];
        for (UIWindow *window in frontToBackWindows) {
            BOOL windowOnMainScreen = window.screen == UIScreen.mainScreen;
            BOOL windowIsVisible = !window.hidden && window.alpha > 0;
            BOOL windowLevelNormal = window.windowLevel == UIWindowLevelNormal;
            
            if(windowOnMainScreen && windowIsVisible && windowLevelNormal) {
                [window addSubview:self];
                break;
            }
        }
        
        [UIView animateWithDuration:XIActionSheetAnimateDuration delay:0 usingSpringWithDamping:0.7f initialSpringVelocity:0.7f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.backgroundView.alpha = 1.0f;
            self.actionSheetView.frame = CGRectMake(0, self.frame.size.height-self.actionSheetView.frame.size.height, self.frame.size.width, self.actionSheetView.frame.size.height);
        } completion:nil];
    }];
}

- (void)dismiss {
    [UIView animateWithDuration:XIActionSheetAnimateDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.backgroundView.alpha = 0.0f;
        self.actionSheetView.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, self.actionSheetView.frame.size.height);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (UIView *)tableHeaderViewWithTitle:(NSString *)title {
    UIView *bgView = [UIView new];
    bgView.backgroundColor = [UIColor redColor];
    return bgView;
}

@end
