//
//  MineView.m
//  MineSweep
//
//  Created by fmj on 14-3-28.
//  Copyright (c) 2014年 lenovo. All rights reserved.
//

#import "MineView.h"

@implementation MineView
{
    UILongPressGestureRecognizer* _longPressGesture;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initialize];
       
    }
    return self;
}

-(void)initialize
{
    self.status = MINE_STATUS_NONE;
    self.isMine = NO;
    [self showStatusImage:MINE_STATUS_NONE];
    
    [self addTarget:self action:@selector(btnClick:forEvent:) forControlEvents:UIControlEventTouchUpInside];
    _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressHandler:)];
    _longPressGesture.minimumPressDuration = .5f;
    [self addGestureRecognizer:_longPressGesture];
}

-(void)longPressHandler:(UIGestureRecognizer *)recognizer
{
    if (self.status != MINE_STATUS_NONE && self.status != MINE_STATUS_MINEMARKED) {
        return;
    }
    if ( recognizer.state != UIGestureRecognizerStateBegan ) {
        return;
    }
    //TODO:需要更合适的动画
    CGRect rect = CGRectMake(self.frame.origin.x, self.frame.origin.y-40, self.frame.size.width+20, self.frame.size.height+20 );
    MineView* mineView = [[MineView alloc] initWithFrame:rect];
    [mineView showStatusImage:MINE_STATUS_MINEMARKED];
    [self.superview addSubview:mineView];
    [UIView animateWithDuration:.5f delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        mineView.frame = self.frame;
    } completion:^(BOOL finished) {
        [mineView removeFromSuperview];
        if (self.status == MINE_STATUS_MINEMARKED) {
            self.status = MINE_STATUS_NONE;
            [self.delegate mineMarked:self];
        }
        else if (self.status == MINE_STATUS_NONE) {
            self.status = MINE_STATUS_MINEMARKED;
            [self.delegate mineMarked:self];
        }
        else
        {
            return;
        }
        [self showStatusImage:self.status];
    }];
}

-(void)btnClick:(MineView*)view forEvent:(UIEvent *)event
{
    //不太清楚怎么更合理，在按钮内点击，按钮外松开，理论上不应该触发clicked事件
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint point = [touch locationInView:self];
    if (point.x>self.frame.size.width || point.y>self.frame.size.height) {
        return;
    }

    if(self.status == MINE_STATUS_MINEMARKED)
        return;
    
    if ( self.status == MINE_STATUS_NONE) {
        if (view.isMine) {
            self.status = MIME_STATUS_FAILED;
            [self.delegate sweepFailed:self];
        }
        else
        {
            self.status = MIME_STATUS_NOMINE;
            [self.delegate sweepSuccessed:self];
            [self showMineState];
        }
        [self showStatusImage:self.status];
    }
    else if(self.status == MIME_STATUS_NOMINE)
    {
        //开启其他的雷
        [self.delegate autoSweepMine:self];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)showStatusImage:(MINE_STATUS)status
{
    UIImage* image = nil;
    if (status == MINE_STATUS_NONE ) {
        image = [UIImage imageNamed:@"new"];
    }
    else if(status == MINE_STATUS_MINEMARKED)
    {
        image = [UIImage imageNamed:@"marked"];
    }
    else if(status == MIME_STATUS_FAILED)
    {
        image = [UIImage imageNamed:@"markfailed"];
    }
    else if(status == MIME_STATUS_NOMINE)
    {
        image = [UIImage imageNamed:@"empty"];
    }
    [self setBackgroundImage:image forState:UIControlStateNormal];
}

-(void)showFinalState:(BOOL)win
{
    [self removeTarget:self action:@selector(btnClick:forEvent:)  forControlEvents:UIControlEventTouchUpInside];
    [self removeGestureRecognizer:_longPressGesture];
    
    if (self.status == MINE_STATUS_NONE) {
        if (self.isMine) {
            if (win) {
                 [self showStatusImage:MINE_STATUS_MINEMARKED];
            }
            else
            {
                [self setBackgroundImage:[UIImage imageNamed:@"mine"] forState:UIControlStateNormal];
            }
        }
    }
    else if(self.status == MIME_STATUS_FAILED)
    {
        [self showStatusImage:MIME_STATUS_FAILED];
    }
    else if(self.status == MINE_STATUS_MINEMARKED)
    {
        if (!self.isMine) {
            [self setBackgroundImage:[UIImage imageNamed:@"markerror"] forState:UIControlStateNormal];
        }
    }
}

-(void)showMineState
{
    if (self.isMine)
        return;
    UIColor* color = [UIColor redColor];
    switch (self.aroundMines) {
        case 0:
            return;
        case 1:
            color = [UIColor blueColor];
            break;
        case 2:
            color = [UIColor greenColor];
            break;
        case 3:
            color = [UIColor redColor];
            break;
        case 4:
            color = [UIColor purpleColor];
            break;
        case 5:
            color = [UIColor orangeColor];
            break;
        default:
            color = [UIColor blackColor];
            break;
    }
    [self setTitleColor:color forState:UIControlStateNormal];
    NSString* title = [NSString stringWithFormat:@"%d",[self aroundMines]];
    [self setTitle:title forState:UIControlStateNormal];
    [self.titleLabel setFont:[UIFont boldSystemFontOfSize:20.f]];
}

-(void)doAutoSelect
{
    if (self.status != MINE_STATUS_NONE ) {
        return;
    }
    if (self.isMine)
    {
        NSLog(@"怎么可能是一颗雷？ must be some wrong!");
        return;
    }
    self.status = MIME_STATUS_NOMINE;
    [self showStatusImage:self.status];
    [self showMineState];
    //递归继续操作
    [self.delegate sweepSuccessed:self];
    
}

@end
