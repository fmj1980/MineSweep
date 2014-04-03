//
//  minesweepViewController.m
//  MineSweep
//
//  Created by fmj on 14-3-28.
//  Copyright (c) 2014年 lenovo. All rights reserved.
//

#import "minesweepViewController.h"
#import "MineView.h"

//保证每一个View Tag唯一
#define CONTROL_TAG(x,y) ((x+1)*100+(y+1))

@interface minesweepViewController ()
{
    bool _autoSelectMines[40][40];
    bool _mines[40][40];
    BOOL _started;
    int _mineViewSize;
    CGFloat _lastScale;
    NSTimer* _timer;
    int _startSeconds;
}

//@property (weak, nonatomic) IBOutlet UIButton *newButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollVIew;

@end

@implementation minesweepViewController

- (void)viewDidLoad
{
    _mineViewSize = MINE_SIZE;
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [(UIImageView*)self.view setImage:[UIImage imageNamed:@"bg"]];
    [self startNewGame];
  
}

-(void)startNewGame
{
    [_timer invalidate];
    _timer = nil;
    _started = NO;
    _startSeconds = 0;
    [self showMineCounts:MINE_COUNT];
    [self showTime];
    
    [self initMineViews];
    self.scrollVIew.contentSize = CGSizeMake(_mineViewSize*MINE_COLUMNCOUNT+40, _mineViewSize*MINE_ROWCOUNT +40);
}
-(void)initMineViews
{
    for(UIView *subView in [self.scrollVIew subviews]){
        [subView removeFromSuperview];
    }
    for(int i = 0; i < MINE_ROWCOUNT; i++) {
        for(int j = 0; j < MINE_COLUMNCOUNT; j++) {
            CGRect rect = CGRectMake( _mineViewSize*j+10 , _mineViewSize*i+10, _mineViewSize, _mineViewSize);
            MineView *view = [[MineView alloc] initWithFrame:rect];
            view.tag = CONTROL_TAG(i,j);
            view.enabled = YES;
            view.x = i;
            view.y = j;
            view.delegate = self;
            [self.scrollVIew addSubview: view];
        }
    }
}

-(void)resizeMineViews
{
    for(int i = 0; i < MINE_ROWCOUNT; i++) {
        for(int j = 0; j < MINE_COLUMNCOUNT; j++) {
            MineView* view = (MineView*)[self.scrollVIew viewWithTag:CONTROL_TAG(i, j)];
            CGRect rect = CGRectMake( _mineViewSize*j , _mineViewSize*i, _mineViewSize, _mineViewSize);
            view.frame = rect;
        }
    }
    self.scrollVIew.contentSize = CGSizeMake(_mineViewSize*MINE_COLUMNCOUNT+40, _mineViewSize*MINE_ROWCOUNT +40);
}
-(void)initMines:(int)xcoord ycoord:(int)ycoord
{
    NSLog(@"初始化雷%f",[[NSDate date] timeIntervalSinceReferenceDate]);
    memset(_mines, 0, sizeof(_mines));
    //随机初始化雷
    int mineCount = MINE_COUNT;
    while ( mineCount >0 ) {
        int x = arc4random()%MINE_ROWCOUNT;
        int y = arc4random()%MINE_COLUMNCOUNT;
        //如果已经是雷了 则继续随机处理
        if (_mines[x][y]) {
            continue;
        }
        //保证第一次点击的View周围没有雷，降低游戏的难度
        BOOL exclusive = NO;
        for (int i=xcoord-1;i-xcoord<=1;i++) {
            if(exclusive) break;
            for (int j=ycoord-1; j-ycoord<=1; j++) {
                if (i==x && j == y) {
                    exclusive = YES;
                    break;
                }
            }
        }
        if (exclusive) {
            continue;
        }
        
        _mines[x][y]=true;
        MineView* view = (MineView*)[self.scrollVIew viewWithTag:CONTROL_TAG(x,y)];
        view.isMine = YES;
        mineCount--;
    }
    NSLog(@"初始化雷结束%f",[[NSDate date] timeIntervalSinceReferenceDate]);
}

-(void)initMineCounts
{
    NSLog(@"开始计算每个View周围雷的个数%f",[[NSDate date] timeIntervalSinceReferenceDate]);
    //计算每个View周围有几颗雷 优化完成
    for(MineView *subView in [self.scrollVIew subviews]){
        int x = subView.x;
        int y = subView.y;
        int count  = 0;
        for (int i=x-1;i-x<=1;i++) {
            if (i<0) continue;
            if (i>=MINE_ROWCOUNT)continue;
            for (int j=y-1; j-y<=1; j++) {
                if (j<0) continue;
                if (j>=MINE_COLUMNCOUNT)continue;
                if (_mines[i][j]) count++;
            }
        }
        subView.aroundMines = count;
    }
    NSLog(@"计算每个View周围雷的个数结束%f",[[NSDate date] timeIntervalSinceReferenceDate]);
}
-(void)startGameAt:(MineView*)view
{
    [self initMines:view.x ycoord:view.y];
    [self initMineCounts];
    _started = YES;
    _startSeconds = 0;
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
}

-(void)onTimer:(id)sender
{
    _startSeconds++;
    [self showTime];
}

-(void)showTime
{
    self.lblTimer.text = [NSString stringWithFormat:@"%.3d",_startSeconds];
}

-(void)showMineCounts:(int)count
{
    [self.lblMines setText:[NSString stringWithFormat:@"%.3d",count]];
}

-(void)gameOver
{
    for(MineView *subView in [self.scrollVIew subviews]){
        [subView showFinalState:NO];
    }
    [_timer invalidate];
    _timer = nil;
}

-(void)gameWin
{
    for(MineView *subView in [self.scrollVIew subviews]){
        [subView showFinalState:YES];
    }
    [self showMineCounts:0];
    [_timer invalidate];
    _timer = nil;
    [self showAlert:@"恭喜你，你赢了！"];
}

- (void)showAlert:(NSString*)message
{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alert show];
}

-(NSArray*)arroundView:(MineView*)view
{
    int x = view.x;
    int y = view.y;
    NSMutableArray* arry = [NSMutableArray new];
    for (int i=x-1;i-x<=1;i++) {
        for (int j=y-1; j-y<=1; j++) {
            MineView* view = (MineView*)[self.scrollVIew viewWithTag:CONTROL_TAG(i,j)];
            if (view && [view isKindOfClass:[MineView class]])
                [arry addObject:view];
        }
    }
    return arry;
}

- (IBAction)newButtonClicked:(id)sender {
    [self startNewGame];
}
-(IBAction)zoomInClicked:(id)sender
{
    if (_mineViewSize*1.1>60) {
        return;
    }
    _mineViewSize = _mineViewSize*1.1;
    [self resizeMineViews];
}

-(IBAction)zoomOutClicked:(id)sender
{
    if (_mineViewSize*0.9<25 ) {
        return;
    }
    _mineViewSize = _mineViewSize*0.9;
    [self resizeMineViews];
}
-(IBAction)pinkHandler:(UIPinchGestureRecognizer *)recognizer
{
    if([(UIPinchGestureRecognizer*)recognizer state] == UIGestureRecognizerStateBegan) {
        _lastScale = 1.0;
    }
    CGFloat scale = 1.0 - (_lastScale - [(UIPinchGestureRecognizer*)recognizer scale]);
    if (_mineViewSize*scale<25 || _mineViewSize*scale>50) {
        return;
    }
    _mineViewSize = _mineViewSize*scale;
    [self resizeMineViews];
    _lastScale = [(UIPinchGestureRecognizer*)recognizer scale];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)isWin
{
    int mines = 0;
    for(MineView *subView in [self.scrollVIew subviews]){
        if (!subView.isMine && subView.status != MIME_STATUS_NOMINE) {
            return NO;
        }
        if (subView.isMine && (subView.status == MINE_STATUS_MINEMARKED || subView.status == MINE_STATUS_NONE) ) {
            mines ++;
         }
    }
    if (mines != MINE_COUNT) {
        return NO;
    }
    return YES;
}

//MineViewDelegate:
-(void)sweepFailed:(MineView*)view
{
    [self gameOver];
}

-(void)sweepSuccessed:(MineView*)view
{
    if ( !_started ) {
        [self startGameAt:view];
    }
    if ([self isWin]) {
        [self gameWin];
        return;
    }
    //如果点中的周围没有雷，则自动显示周围的数据
    if ( view.aroundMines != 0 )
        return;
    
    memset(_autoSelectMines, 0, sizeof(_autoSelectMines));
    
     NSLog(@"开始自动扫雷%f",[[NSDate date] timeIntervalSinceReferenceDate]);
    [self sweepAutoFinished:view];
     NSLog(@"自动扫雷结束%f",[[NSDate date] timeIntervalSinceReferenceDate]);
}

-(void)mineMarked:(MineView*)view
{
    int marked = 0;
    for(MineView *subView in [self.scrollVIew subviews]){
        if (subView.status == MINE_STATUS_MINEMARKED) {
            marked++;
        }
    }
    [self showMineCounts:(MINE_COUNT-marked)];
    
}

-(void)autoSweepMine:(MineView*)view
{
    memset(_autoSelectMines, 0, sizeof(_autoSelectMines));
    
    int marked = 0;
    NSArray* arry = [self arroundView:view];
    for (MineView* subView in arry) {
        if (subView.status == MINE_STATUS_MINEMARKED) {
            marked++;
        }
    }
    if ( marked>= view.aroundMines ) {
        for (MineView* subView in arry) {
            if (subView.status == MINE_STATUS_NONE) {
                if (subView.isMine) {
                    [self gameOver];
                }
                else
                {
                    [subView doAutoSelect];
                }
            }
        }
    }
    if ([self isWin]) {
        [self gameWin];
        return;
    }
}

-(void)sweepAutoFinished:(MineView*)view
{
    if ( view.aroundMines != 0 )
        return;
    for (int i=view.x-1;i-view.x<=1;i++) {
        if (i<0) continue;
        if (i>=MINE_ROWCOUNT)continue;
        for (int j=view.y-1; j-view.y<=1; j++) {
            if (j<0) continue;
            if (j>=MINE_COLUMNCOUNT)continue;
            if (_mines[i][j]) continue;
            if (_autoSelectMines[i][j]) continue;
            _autoSelectMines[i][j] = YES;
            MineView* view = (MineView*)[self.scrollVIew viewWithTag:CONTROL_TAG(i,j)];
            if (view) {
                [view doAutoSelect];
            }
        }
    }
   
}
@end
