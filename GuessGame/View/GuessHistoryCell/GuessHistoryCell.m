//
//  GuessHistoryCell.m
//  GuessGame
//
//  Created by 殷子欣 on 2017/12/24.
//  Copyright © 2017年 殷子欣. All rights reserved.
//

#import "GuessHistoryCell.h"

@implementation GuessHistoryCell
- (void)awakeFromNib {
    [super awakeFromNib];
    self.separatorInset = UIEdgeInsetsZero;
    self.layoutMargins = UIEdgeInsetsZero;
}

+ (NSString *)identifier {
    return NSStringFromClass(self);
}
@end
