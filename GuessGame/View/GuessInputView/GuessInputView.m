//
//  GuessInputView.m
//  GuessGame
//
//  Created by 殷子欣 on 2017/12/25.
//  Copyright © 2017年 殷子欣. All rights reserved.
//

#import "GuessInputView.h"
#import "ReactiveCocoa/ReactiveCocoa.h"

@implementation GuessInputView
- (void)awakeFromNib {
    [super awakeFromNib];
}

+ (instancetype)guessInputView {
    GuessInputView *guessInputView = [[[NSBundle mainBundle] loadNibNamed:@"GuessInputView" owner:self options:nil] firstObject];
    guessInputView.guessInputTextField.clearsOnBeginEditing = YES;
    guessInputView.guessInputTextField.keyboardType = UIKeyboardTypeNumberPad;
    return guessInputView;
}
@end
