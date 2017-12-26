//
//  GuessHistoryViewModels.h
//  GuessGame
//
//  Created by 殷子欣 on 2017/12/24.
//  Copyright © 2017年 殷子欣. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GuessHistoryModel.h"

#define defaultUnsetSettingNumber -1
@interface GuessHistoryViewModels : NSObject
@property (strong, nonatomic) NSMutableArray<GuessHistoryViewModel *> *guessHistoryViewModels;
@property (assign, nonatomic) NSInteger upperNumber;
@property (assign, nonatomic) NSInteger lowerNumber;
@property (assign, nonatomic) NSInteger settingNumber;

- (void)insertWithNumber:(NSInteger)number;
- (void)reset;
@end
