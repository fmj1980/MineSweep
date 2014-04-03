//
//  MineView.h
//  MineSweep
//
//  Created by fmj on 14-3-28.
//  Copyright (c) 2014年 lenovo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,MINE_STATUS)
{
    //默认状态
    MINE_STATUS_NONE = 0,
    //标记为雷
    MINE_STATUS_MINEMARKED,
    //标记为问号
    MINE_STATUS_QUESTIONMARKED,
    //已经确认不是雷
    MIME_STATUS_NOMINE,
    //失败
    MIME_STATUS_FAILED
};

@protocol MineViewDelegate;

@interface MineView : UIButton

//当前状态
@property(nonatomic) MINE_STATUS status;
//是否是一颗雷
@property(nonatomic) BOOL isMine;
//周围雷的个数
@property(nonatomic) int aroundMines;
//delegate委托
@property(nonatomic,retain) id<MineViewDelegate> delegate;
//x坐标
@property(nonatomic) int x;
//y坐标
@property(nonatomic) int y;

//自动选择（确认当前不是雷） 递归扫雷使用
-(void)doAutoSelect;
//显示最终的的状态信息,gameover或者gameWin使用
-(void)showFinalState:(BOOL)win;
@end

@protocol MineViewDelegate <NSObject>
//长按，标记为雷,或者取消标记雷
-(void)mineMarked:(MineView*)view;
//点击，踩到雷了
-(void)sweepFailed:(MineView*)view;
//点击，没有踩到雷
-(void)sweepSuccessed:(MineView*)view;
//当前已经确认不是雷，点击自动计算周围的雷
-(void)autoSweepMine:(MineView*)view;
//自动扫雷完成，需要继续递归扫雷
-(void)sweepAutoFinished:(MineView*)view;
@end