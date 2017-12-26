//
//  GuessHistoryCell.h
//  GuessGame
//
//  Created by 殷子欣 on 2017/12/24.
//  Copyright © 2017年 殷子欣. All rights reserved.
//

#import <UIKit/UIKit.h>
#define GuessHistoryCellHeight 61
@interface GuessHistoryCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *historyImageView;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;

+ (NSString *)identifier;
@end
