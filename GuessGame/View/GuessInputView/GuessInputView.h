//
//  GuessInputView.h
//  GuessGame
//
//  Created by 殷子欣 on 2017/12/25.
//  Copyright © 2017年 殷子欣. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GuessInputView : UIView
@property (weak, nonatomic) IBOutlet UILabel *upperNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *lowerNumberLabel;
@property (weak, nonatomic) IBOutlet UITextField *guessInputTextField;

+ (instancetype)guessInputView;
@end
