//
//  GuessHistoryViewModels.m
//  GuessGame
//
//  Created by 殷子欣 on 2017/12/24.
//  Copyright © 2017年 殷子欣. All rights reserved.
//

#import "GuessHistoryViewModels.h"

#define defaultUnsetUpperNumber 1000
#define defaultUnsetLowerNumber 0
@implementation GuessHistoryViewModels
- (instancetype)init {
    self = [super init];
    if (self) {
        [self reset];
        self.guessHistoryViewModels = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)insertWithNumber:(NSInteger)number {
    GuessHistoryModel *guessHistoryModel = [[GuessHistoryModel alloc] init];
    guessHistoryModel.number = number;
    if (number > self.settingNumber) {
        if (number < self.upperNumber) {
            self.upperNumber = number;
        }
        guessHistoryModel.image = [UIImage imageNamed:@"down_arrow"];
    } else if (number < self.settingNumber) {
        if (number > self.lowerNumber) {
            self.lowerNumber = number;
        }
        guessHistoryModel.image = [UIImage imageNamed:@"up_arrow"];
    }
    [self.guessHistoryViewModels insertObject:guessHistoryModel atIndex:0];
}

- (void)reset {
    self.upperNumber = defaultUnsetUpperNumber;
    self.lowerNumber = defaultUnsetLowerNumber;
    self.settingNumber = defaultUnsetSettingNumber;
    NSMutableArray *emptyArray = [[NSMutableArray alloc] init];
    self.guessHistoryViewModels = emptyArray;
}
@end
