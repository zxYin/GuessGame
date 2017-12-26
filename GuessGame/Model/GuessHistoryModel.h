//
//  GuessHistoryModel.h
//  GuessGame
//
//  Created by 殷子欣 on 2017/12/24.
//  Copyright © 2017年 殷子欣. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface GuessHistoryModel : NSObject
@property (strong, nonatomic) UIImage *image;
@property (assign, nonatomic) NSInteger number;
@end

typedef GuessHistoryModel GuessHistoryViewModel;
