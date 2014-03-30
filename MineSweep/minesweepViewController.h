//
//  minesweepViewController.h
//  MineSweep
//
//  Created by fmj on 14-3-28.
//  Copyright (c) 2014年 lenovo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface minesweepViewController : UIViewController<MineViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lblMines;
@property (weak, nonatomic) IBOutlet UILabel *lblTimer;
@end
