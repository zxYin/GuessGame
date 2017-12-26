//
//  GuessWinView.m
//  GuessGame
//
//  Created by 殷子欣 on 2017/12/26.
//  Copyright © 2017年 殷子欣. All rights reserved.
//

#import "GuessWinView.h"

@implementation GuessWinView
- (void)awakeFromNib {
    [super awakeFromNib];
}

+ (instancetype)guessWinView {
    GuessWinView *guessWinView = [[[NSBundle mainBundle] loadNibNamed:@"GuessWinView" owner:self options:nil] firstObject];
    return guessWinView;
}
@end
