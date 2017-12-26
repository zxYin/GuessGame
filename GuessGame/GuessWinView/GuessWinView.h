//
//  GuessWinView.h
//  GuessGame
//
//  Created by 殷子欣 on 2017/12/26.
//  Copyright © 2017年 殷子欣. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GuessWinView : UIView
@property (weak, nonatomic) IBOutlet UIButton *againButton;

+ (instancetype)guessWinView;
@end
