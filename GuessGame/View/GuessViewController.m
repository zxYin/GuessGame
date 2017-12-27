//
//  ViewController.m
//  GuessGame
//
//  Created by 殷子欣 on 2017/12/24.
//  Copyright © 2017年 殷子欣. All rights reserved.
//

#import "GuessViewController.h"
#import "GuessNumberView.h"
#import "GuessHistoryCell.h"
#import "GuessHistoryViewModels.h"
#import "GuessInputView.h"
#import "Masonry.h"
#import "ReactiveCocoa/ReactiveCocoa.h"
#import "GuessWinView.h"

#define buttonCenterY 45.0
#define normalButtonRadius 20.0
#define smallButtonRadius 15.0
#define lineImageViewHeight 10.0
#define guessNumberViewHeight 90.0

typedef NS_ENUM(NSInteger, ConfirmAndCancelButtonMode) {
    GuessInputMode,
    GuessSettingMode,
    GuessshareMode,
    GuessWinMode,
};

@interface GuessViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) GuessNumberView *guessNumberView;
@property (strong, nonatomic) GuessInputView *guessInputView;
@property (strong, nonatomic) GuessHistoryViewModels *viewModel;
@property (strong, nonatomic) GuessWinView *guessWinView;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIImageView *lineImageView;
@property (strong, nonatomic) UIButton *addButton;
@property (strong, nonatomic) UIButton *settingButton;
@property (strong, nonatomic) UIButton *shareButton;
@property (strong, nonatomic) UIButton *confirmButton;
@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) UILabel *addTitleLabel;
@property (assign, nonatomic) CGFloat guessInputViewHeight;
@property (assign, nonatomic) ConfirmAndCancelButtonMode mode;
@end

@implementation GuessViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.guessInputViewHeight = self.view.frame.size.height - buttonCenterY - normalButtonRadius - 10 - lineImageViewHeight;
    [self.view addSubview:self.guessInputView];
    [self.view addSubview:self.guessNumberView];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.lineImageView];
    [self.view addSubview:self.addTitleLabel];
    [self initButtons];
    [self.view addSubview:self.guessWinView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = [UIColor whiteColor];
    }
    [self setupRAC];
    [self.viewModel reset];
}

- (void)initButtons {
    self.addButton = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width) / 2  - normalButtonRadius, buttonCenterY - normalButtonRadius,  2 * normalButtonRadius, 2 * normalButtonRadius)];
    self.addButton.layer.cornerRadius = normalButtonRadius;
    [self.addButton setImage:[UIImage imageNamed: @"add_button"] forState:UIControlStateNormal];
    self.addButton.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.addButton];
    [self.addButton addTarget:self action:@selector(addButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self.addButton setExclusiveTouch:YES];
    
    self.settingButton = [[UIButton alloc] initWithFrame:CGRectMake(20, buttonCenterY - smallButtonRadius, 2 * smallButtonRadius, 2 * smallButtonRadius)];
    self.settingButton.layer.cornerRadius = 0;
    [self.settingButton setImage:[UIImage imageNamed: @"setting_button"] forState:UIControlStateNormal];
    self.settingButton.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.settingButton];
    [self.settingButton addTarget:self action:@selector(settingButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self.settingButton setExclusiveTouch:YES];
    
    self.shareButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 20 - 2 * smallButtonRadius, buttonCenterY - smallButtonRadius, 2 * smallButtonRadius, 2 * smallButtonRadius)];
    self.shareButton.layer.cornerRadius = 0;
    [self.shareButton setImage:[UIImage imageNamed: @"share_button"] forState:UIControlStateNormal];
    self.shareButton.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.shareButton];
    [self.shareButton addTarget:self action:@selector(shareButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self.shareButton setExclusiveTouch:YES];
    
    self.confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2, buttonCenterY, 0, 0)];
    self.confirmButton.layer.cornerRadius = 0;
    [self.confirmButton setImage:[UIImage imageNamed: @"confirm_button"] forState:UIControlStateNormal];
    self.confirmButton.backgroundColor = [UIColor whiteColor];
    self.confirmButton.transform = CGAffineTransformRotate (self.confirmButton.transform, -M_PI_2);
    [self.view addSubview:self.confirmButton];
    self.confirmButton.hidden = YES;
    [self.confirmButton addTarget:self action:@selector(confirmButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self.confirmButton setExclusiveTouch:YES];
    
    self.cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2, buttonCenterY, 0, 0)];
    self.cancelButton.layer.cornerRadius = 0;
    [self.cancelButton setImage:[UIImage imageNamed: @"cancel_button"] forState:UIControlStateNormal];
    self.cancelButton.backgroundColor = [UIColor whiteColor];
    self.cancelButton.transform = CGAffineTransformRotate (self.cancelButton.transform, M_PI_2);
    [self.view addSubview:self.cancelButton];
    self.cancelButton.hidden = YES;
    [self.cancelButton addTarget:self action:@selector(cancelButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelButton setExclusiveTouch:YES];
}

- (void)setupRAC {
    @weakify(self);
    [[RACObserve(self.viewModel, guessHistoryViewModels) skip:1] subscribeNext:^(id x) {
        @strongify(self);
        [self.tableView reloadData];
    }];
    [[RACObserve(self.viewModel, upperNumber) skip:1] subscribeNext:^(NSNumber *x) {
        @strongify(self);
        self.guessInputView.upperNumberLabel.text = [NSString stringWithFormat:@"%ld", (long)[x integerValue]];
        self.guessNumberView.upperNumberLabel.text = [NSString stringWithFormat:@"%ld", (long)[x integerValue]];
    }];
    [[RACObserve(self.viewModel, lowerNumber) skip:1] subscribeNext:^(NSNumber *x) {
        @strongify(self);
        self.guessInputView.lowerNumberLabel.text = [NSString stringWithFormat:@"%ld", (long)[x integerValue]];
        self.guessNumberView.lowerNumberLabel.text = [NSString stringWithFormat:@"%ld", (long)[x integerValue]];
    }];
}

#pragma mark - animation
- (void)pushButtonAction {
    //addButton disappear
    switch (self.mode) {
        case GuessInputMode:
            self.confirmButton.frame = CGRectMake(self.view.frame.size.width/2, buttonCenterY, 0, 0);
            self.cancelButton.frame = CGRectMake(self.view.frame.size.width/2, buttonCenterY, 0, 0);
            [self changeToGuessInputViewAction];
            break;
        case GuessSettingMode:
            self.confirmButton.frame = CGRectMake(20 + smallButtonRadius, buttonCenterY, 0, 0);
            self.cancelButton.frame = CGRectMake(20 + smallButtonRadius, buttonCenterY, 0, 0);
            [self changeToGuessInputViewAction];
            break;
        case GuessshareMode:
            self.confirmButton.frame = CGRectMake(self.view.frame.size.width - 20 - smallButtonRadius, buttonCenterY, 0, 0);
            self.cancelButton.frame = CGRectMake(self.view.frame.size.width - 20 - smallButtonRadius, buttonCenterY, 0, 0);
            break;
        default:
            self.confirmButton.frame = CGRectMake(self.view.frame.size.width/2, buttonCenterY, 0, 0);
            self.cancelButton.frame = CGRectMake(self.view.frame.size.width/2, buttonCenterY, 0, 0);
            break;
    }

    self.guessInputView.hidden = NO;
    self.addButton.transform = CGAffineTransformMakeScale(0.7, 0.7);
    [UIView animateWithDuration:0.7 delay:0 usingSpringWithDamping:0.3 initialSpringVelocity:0.3 options:0 animations:^{
        self.addButton.transform = CGAffineTransformMakeScale(1, 1);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 delay:0 usingSpringWithDamping:0.3 initialSpringVelocity:0.3 options:0 animations:^{
            self.addButton.transform = CGAffineTransformMakeScale(0.7, 0.7);
        } completion:nil];
    }];
    [UIView animateWithDuration:0.2 delay:0.3 options: UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.addButton setFrame:CGRectMake(self.view.frame.size.width/2, buttonCenterY, 0, 0)];
        self.addButton.layer.cornerRadius = 0;
    } completion:^(BOOL finished) {
        //confirmButton & cancelButton appear
        [UIView animateWithDuration:1.2 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:0.5 options:0 animations:^{
            self.confirmButton.transform = CGAffineTransformScale(self.confirmButton.transform, 1, 1);
            self.confirmButton.transform = CGAffineTransformRotate (self.confirmButton.transform, M_PI_2);
            self.confirmButton.hidden = NO;
            self.confirmButton.layer.cornerRadius = normalButtonRadius;
            [self.confirmButton setFrame:CGRectMake(20, buttonCenterY - normalButtonRadius, 2 * normalButtonRadius, 2 * normalButtonRadius)];
            
            self.cancelButton.transform = CGAffineTransformScale(self.cancelButton.transform, 1, 1);
            self.cancelButton.transform = CGAffineTransformRotate (self.cancelButton.transform, -M_PI_2);
            self.cancelButton.hidden = NO;
            self.cancelButton.layer.cornerRadius = normalButtonRadius;
            [self.cancelButton setFrame:CGRectMake(self.view.frame.size.width - 20 - 2 * normalButtonRadius, buttonCenterY - normalButtonRadius, 2 * normalButtonRadius, 2 * normalButtonRadius)];
        } completion:nil];
    }];
    
    //settingButton & shareButton disappear
    [UIView animateWithDuration:0.5 delay:0.1 usingSpringWithDamping:0.3 initialSpringVelocity:0.3 options:0 animations:^{
        [self.settingButton setFrame:CGRectMake(18, buttonCenterY - smallButtonRadius - 2, 2 * smallButtonRadius + 4, 2 * smallButtonRadius + 4)];
        [self.shareButton setFrame:CGRectMake(self.view.frame.size.width - 18 - smallButtonRadius * 2 - 4, buttonCenterY - smallButtonRadius - 2, 2 * smallButtonRadius + 4, 2 * smallButtonRadius + 4)];
    } completion:nil];
    [UIView animateWithDuration:0.2 delay:0.4 options: UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.settingButton setFrame:CGRectMake(20 + smallButtonRadius, buttonCenterY, 0, 0)];
        self.settingButton.layer.cornerRadius = 0;
        [self.shareButton setFrame:CGRectMake(self.view.frame.size.width - 20 - smallButtonRadius, buttonCenterY, 0, 0)];
        self.shareButton.layer.cornerRadius = 0;
    } completion:nil];
    
    //guessNumberView disappear & move lineImageView
    [UIView animateWithDuration:0.1 delay:0.65 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.guessNumberView.frame = CGRectMake(0, buttonCenterY + normalButtonRadius + 10, self.view.frame.size.width, guessNumberViewHeight);
        self.lineImageView.frame = CGRectMake(5, buttonCenterY + normalButtonRadius + 100, self.view.frame.size.width - 10, lineImageViewHeight);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.guessNumberView.transform = CGAffineTransformMakeScale(0.1, 0.1);
            self.guessNumberView.frame = CGRectMake(self.view.frame.size.width * 0.45, -25, self.view.frame.size.width * 0.1, guessNumberViewHeight * 0.1);
            self.lineImageView.frame = CGRectMake(5, buttonCenterY + normalButtonRadius + 10, self.view.frame.size.width - 10, lineImageViewHeight);
        } completion:^(BOOL finished) {
            self.guessNumberView.hidden = YES;
            
            //addTitleLabel appear
            [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:0 animations:^{
                self.addTitleLabel.hidden = NO;
                self.addTitleLabel.transform = CGAffineTransformMakeScale(1, 1);
                self.addTitleLabel.frame = CGRectMake(0, buttonCenterY - 20, self.view.frame.size.width, 40);
            } completion:nil];
        }];
    }];
}

- (void)restoreButtonAction {
    //confirmButton & cancelButton disappear
    [UIView animateWithDuration:0.5 animations:^{
        self.confirmButton.frame = CGRectMake(self.view.frame.size.width/2, buttonCenterY, 0, 0);
        self.confirmButton.transform = CGAffineTransformMakeRotation(-M_PI_2);
        self.confirmButton.layer.cornerRadius = 0;
        
        [self.cancelButton setFrame:CGRectMake(self.view.frame.size.width/2, buttonCenterY, 0, 0)];
        self.cancelButton.transform = CGAffineTransformMakeRotation(M_PI_2);
        self.cancelButton.layer.cornerRadius = 0;
    } completion:^(BOOL finished) {
        self.confirmButton.hidden = YES;
        self.cancelButton.hidden = YES;
        self.confirmButton.layer.cornerRadius = 0;
        self.cancelButton.layer.cornerRadius = 0;
        
        //addButton appear
        self.addButton.transform = CGAffineTransformMakeScale(1, 1);
        [UIView animateWithDuration:0.7 delay:0 usingSpringWithDamping:0.3 initialSpringVelocity:0.3 options:0 animations:^{
            [self.addButton setFrame:CGRectMake(self.view.frame.size.width/2 - normalButtonRadius, buttonCenterY - normalButtonRadius, 2 * normalButtonRadius, 2 * normalButtonRadius)];
            self.addButton.layer.cornerRadius = normalButtonRadius;
        } completion:nil];
    }];
    
    //settingButton & shareButton appear
    [UIView animateWithDuration:0.3 delay:0.35 options:0 animations:^{
        self.settingButton.frame = CGRectMake(18, buttonCenterY - smallButtonRadius - 2, 2 * smallButtonRadius + 4, 2 * smallButtonRadius + 4);
        [self.shareButton setFrame:CGRectMake(self.view.frame.size.width - 18 - smallButtonRadius * 2 - 4, buttonCenterY - smallButtonRadius - 2, 2 * smallButtonRadius + 4, 2 * smallButtonRadius + 4)];
    } completion:nil];
    [UIView animateWithDuration:0.4 delay:0.75 usingSpringWithDamping:0.3 initialSpringVelocity:0.3 options:0 animations:^{
        [self.settingButton setFrame:CGRectMake(20, buttonCenterY - smallButtonRadius, 2 * smallButtonRadius, 2 * smallButtonRadius)];
        self.settingButton.layer.cornerRadius = 0;
        [self.shareButton setFrame:CGRectMake(self.view.frame.size.width - 20 - 2 * smallButtonRadius, buttonCenterY - smallButtonRadius, 2 * smallButtonRadius, 2 * smallButtonRadius)];
        self.shareButton.layer.cornerRadius = 0;
    } completion:nil];
    
    //guessNumberView appear & move lineImageView
    [UIView animateWithDuration:0.4 delay:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.guessNumberView.hidden = NO;
        self.lineImageView.frame = CGRectMake(5, buttonCenterY + normalButtonRadius + 100, self.view.frame.size.width - 10, lineImageViewHeight);
        self.guessNumberView.transform = CGAffineTransformMakeScale(1, 1);
        self.guessNumberView.frame = CGRectMake(0, buttonCenterY + normalButtonRadius + 10, self.view.frame.size.width, guessNumberViewHeight);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.guessNumberView.frame = CGRectMake(0, buttonCenterY + normalButtonRadius, self.view.frame.size.width, guessNumberViewHeight);
            self.lineImageView.frame = CGRectMake(5, buttonCenterY + normalButtonRadius + guessNumberViewHeight, self.view.frame.size.width - 10, lineImageViewHeight);
        } completion:nil];
    }];
    
    //addTitleLabel disappear
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.addTitleLabel.transform = CGAffineTransformMakeScale(0.1, 0.1);
        self.addTitleLabel.frame = CGRectMake(self.view.frame.size.width * 0.45, buttonCenterY - 2, self.view.frame.size.width * 0.1, 4);
    } completion:^(BOOL finished) {
        self.addTitleLabel.hidden = YES;
    }];
    
    [self changeToTableViewAction];
}

- (void)changeToGuessInputViewAction {
    //tableView disappear & guessInputView appear
    if (self.mode == GuessWinMode) {
        [UIView animateWithDuration:0.6 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.guessInputView.hidden = NO;
            self.guessWinView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
            self.guessInputView.frame = CGRectMake(0, buttonCenterY + normalButtonRadius + 10 + lineImageViewHeight, self.view.frame.size.width, self.guessInputViewHeight);
        } completion:^(BOOL finished) {
            self.guessWinView.hidden = YES;
        }];
    } else {
        [UIView animateWithDuration:0.6 delay:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.guessInputView.hidden = NO;
            self.tableView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - buttonCenterY - normalButtonRadius - guessNumberViewHeight);
            self.guessInputView.frame = CGRectMake(0, buttonCenterY + normalButtonRadius + 10 + lineImageViewHeight, self.view.frame.size.width, self.guessInputViewHeight);
        } completion:^(BOOL finished) {
            self.tableView.hidden = YES;
        }];
    }
    [self.guessInputView.guessInputTextField becomeFirstResponder];
}

- (void)changeToTableViewAction {
    //tableView appear & guessInputView disappear
    [UIView animateWithDuration:0.6 delay:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.tableView.hidden = NO;
        self.guessInputView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.guessInputViewHeight);
        self.tableView.frame = CGRectMake(0, buttonCenterY + normalButtonRadius + guessNumberViewHeight + lineImageViewHeight, self.view.frame.size.width, self.view.frame.size.height - buttonCenterY - normalButtonRadius - guessNumberViewHeight - lineImageViewHeight);
    } completion:^(BOOL finished) {
        self.guessInputView.hidden = YES;
    }];
}

- (void)changeToWinViewAction {
    //guessWinView appear & guessInputView disappear
    [UIView animateWithDuration:0.6 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.guessWinView.hidden = NO;
        self.guessInputView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.guessInputViewHeight);
        self.guessWinView.frame = CGRectMake(0, 0,self.view.frame.size.width, self.view.frame.size.height);
    } completion:^(BOOL finished) {
        self.guessInputView.hidden = YES;
    }];
}

#pragma mark - buttonDidClick
- (void)settingButtonDidClick {
    self.mode = GuessSettingMode;
    self.addTitleLabel.text = @"set number";
    [self.viewModel reset];
    [self pushButtonAction];
}

- (void)shareButtonDidClick {
    self.mode = GuessshareMode;
    self.addTitleLabel.text = @"share number";
    [self pushButtonAction];
}

- (void)addButtonDidClick {
    self.mode = GuessInputMode;
    self.addTitleLabel.text = @"new number";
    [self pushButtonAction];
}

- (void)confirmButtonDidClick {
    [self.guessInputView.guessInputTextField resignFirstResponder];
    switch (self.mode) {
        case GuessInputMode: {
            NSInteger number = [self.guessInputView.guessInputTextField.text integerValue];
            if (number != self.viewModel.settingNumber && ![self.guessInputView.guessInputTextField.text  isEqual: @""]) {
                [self.viewModel insertWithNumber:number];
                [self.tableView reloadData];
            } else if (number == self.viewModel.settingNumber) {
                self.mode = GuessWinMode;
            }
            break;
        }
        case GuessSettingMode: {
            NSInteger number = [self.guessInputView.guessInputTextField.text integerValue];
            if (![self.guessInputView.guessInputTextField.text  isEqual: @""]) {
                self.viewModel.settingNumber = number;
            }
            break;
        }
        default:
            break;
    }
    if (self.mode != GuessWinMode) {
        [self restoreButtonAction];
        self.guessInputView.guessInputTextField.text = @"";
    } else {
        [self changeToWinViewAction];
    }
}

- (void)cancelButtonDidClick {
    self.guessInputView.guessInputTextField.text = @"";
    [self.guessInputView.guessInputTextField resignFirstResponder];
    [self restoreButtonAction];
}

- (void)againButtonDidClick {
    self.addTitleLabel.text = @"set number";
    [self.viewModel reset];
    self.guessInputView.guessInputTextField.text = @"";
    [self changeToGuessInputViewAction];
    self.mode = GuessSettingMode;
}

#pragma mark - tableView
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return GuessHistoryCellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.viewModel.guessHistoryViewModels count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GuessHistoryCell *guessHistoryCell = [tableView dequeueReusableCellWithIdentifier:[GuessHistoryCell identifier] forIndexPath:indexPath];
    GuessHistoryViewModel *viewModel = self.viewModel.guessHistoryViewModels[indexPath.row];
    [guessHistoryCell.historyImageView setImage:viewModel.image];
    guessHistoryCell.numberLabel.text = [NSString stringWithFormat:@"%ld", (long)viewModel.number];;
    return guessHistoryCell;
}

#pragma mark - keyboard
- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *information = [notification userInfo];
    CGSize keyboardSize = [[information objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    if (self.guessInputViewHeight != self.view.frame.size.height - buttonCenterY - normalButtonRadius - 10 - lineImageViewHeight - keyboardSize.height) {
        self.guessInputViewHeight = self.view.frame.size.height - buttonCenterY - normalButtonRadius - 10 - lineImageViewHeight - keyboardSize.height;
        self.guessInputView.frame = CGRectMake(0, buttonCenterY + normalButtonRadius + 10 + lineImageViewHeight, self.view.frame.size.width, self.guessInputViewHeight);
    }
}

#pragma mark - getter & setter
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, buttonCenterY + normalButtonRadius + guessNumberViewHeight + lineImageViewHeight, self.view.frame.size.width, self.view.frame.size.height - buttonCenterY - normalButtonRadius - guessNumberViewHeight - lineImageViewHeight)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.allowsSelection = NO;
        _tableView.rowHeight = GuessHistoryCellHeight;
        
        UINib *nib = [UINib nibWithNibName:@"GuessHistoryCell" bundle:nil];
        [_tableView registerNib:nib forCellReuseIdentifier:[GuessHistoryCell identifier]];
        
    }
    return _tableView;
}

- (GuessInputView *)guessInputView {
    if (_guessInputView == nil) {
        _guessInputView = [GuessInputView guessInputView];
        _guessInputView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.guessInputViewHeight);
        _guessInputView.hidden = YES;
    }
    return _guessInputView;
}

- (GuessWinView *)guessWinView {
    if (_guessWinView == nil) {
        _guessWinView = [GuessWinView guessWinView];
        _guessWinView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
        _guessWinView.hidden = YES;
        [_guessWinView.againButton addTarget:self action:@selector(againButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _guessWinView;
}

- (GuessNumberView *)guessNumberView {
    if (_guessNumberView == nil) {
        _guessNumberView = [GuessNumberView guessNumberView];
        _guessNumberView.frame = CGRectMake(0, buttonCenterY + normalButtonRadius, self.view.frame.size.width, guessNumberViewHeight);
    }
    return _guessNumberView;
}

- (GuessHistoryViewModels *)viewModel {
    if (_viewModel == nil) {
        _viewModel = [[GuessHistoryViewModels alloc] init];
    }
    return _viewModel;
}

- (UILabel *)addTitleLabel {
    if (_addTitleLabel == nil) {
        _addTitleLabel = [[UILabel alloc] init];
        _addTitleLabel.text = @"";
        _addTitleLabel.textAlignment = NSTextAlignmentCenter;
        _addTitleLabel.frame = CGRectMake(0, buttonCenterY - 20, self.view.frame.size.width, 40);
        _addTitleLabel.transform = CGAffineTransformMakeScale(0.1, 0.1);
        _addTitleLabel.textColor = [UIColor colorWithRed:40/255.0 green:42/255.0 blue:56/255.0 alpha:1];
        _addTitleLabel.font = [UIFont systemFontOfSize:25];
        _addTitleLabel.hidden = YES;
    }
    return _addTitleLabel;
}

- (UIImageView *)lineImageView {
    if (_lineImageView == nil) {
        _lineImageView = [[UIImageView alloc] init];
        [_lineImageView setImage:[UIImage imageNamed:@"line"]];
        _lineImageView.frame = CGRectMake(5, buttonCenterY + normalButtonRadius + guessNumberViewHeight, self.view.frame.size.width - 10, lineImageViewHeight);
    }
    return _lineImageView;
}
@end
