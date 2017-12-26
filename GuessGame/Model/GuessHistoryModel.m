//
//  GuessHistoryModel.m
//  GuessGame
//
//  Created by 殷子欣 on 2017/12/24.
//  Copyright © 2017年 殷子欣. All rights reserved.
//

#import "GuessHistoryModel.h"

@implementation GuessHistoryModel
- (instancetype)init {
    self = [super init];
    if (self) {
        self.number = 0;
        self.image = nil;
        /*
        float random = arc4random() % 2;
        if (random == 1) {
            self.image = [UIImage imageNamed:@"up_arrow"];
        } else {
            self.image = [UIImage imageNamed:@"down_arrow"];
        }
        self.number = arc4random() % 1000;
         */
    }
    return self;
}
@end
