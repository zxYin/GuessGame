//
//  GuessNumberView.h
//  GuessGame
//
//  Created by 殷子欣 on 2017/12/24.
//  Copyright © 2017年 殷子欣. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GuessNumberView : UIView
@property (weak, nonatomic) IBOutlet UILabel *lowerNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *upperNumberLabel;

+ (instancetype)guessNumberView;
@end
