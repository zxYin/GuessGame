//
//  GuessNumberView.m
//  GuessGame
//
//  Created by 殷子欣 on 2017/12/24.
//  Copyright © 2017年 殷子欣. All rights reserved.
//

#import "GuessNumberView.h"

@implementation GuessNumberView
- (void)awakeFromNib {
    [super awakeFromNib];
}

+ (instancetype)guessNumberView {
    GuessNumberView *guessNumberView = [[[NSBundle mainBundle] loadNibNamed:@"GuessNumberView" owner:self options:nil] firstObject];
    return guessNumberView;
}
@end
