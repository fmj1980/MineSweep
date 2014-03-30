//
//  APPConfig.m
//  MineSweep
//
//  Created by fmj on 14-3-28.
//  Copyright (c) 2014年 lenovo. All rights reserved.
//

#import "APPConfig.h"

@implementation APPConfig

+(APPConfig*)instance
{
    static APPConfig* config = nil;
    if (config == nil ) {
        config = [[APPConfig alloc ] init];
        [config initialize];
    }
    return config;
}
-(void)initialize
{
    _gameType = [[[NSUserDefaults standardUserDefaults]objectForKey:@"GAMETYPE"] intValue];;
}

-(void)setGameType:(MINE_GAMETYPE)gameType
{
    _gameType = gameType;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:gameType] forKey:@"GAMETYPE"];
}
-(int) rowCount
{
    if ( self.gameType == MINE_GAMETYPE_10 ) {
        return 9;
    }
    else if (self.gameType == MINE_GAMETYPE_40)
    {
        return 16;
    }
    else if (self.gameType == MINE_GAMETYPE_99)
    {
        return 16;
    }
    int count = [[[NSUserDefaults standardUserDefaults]objectForKey:@"ROWCOUNT"] intValue];
    return count == 0?9:count;
}

-(void)setRowCount:(int)rowCount
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:rowCount] forKey:@"ROWCOUNT"];
}

-(int) columCount
{
    if ( self.gameType == MINE_GAMETYPE_10 ) {
        return 9;
    }
    else if (self.gameType == MINE_GAMETYPE_40)
    {
        return 16;
    }
    else if (self.gameType == MINE_GAMETYPE_99)
    {
        return 30;
    }
    int count = [[[NSUserDefaults standardUserDefaults]objectForKey:@"COLUMNCOUNT"] intValue];
    return count == 0?9:count;
}

-(void)setColumCount:(int)columCount
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:columCount] forKey:@"COLUMNCOUNT"];
}

-(int) mineCount
{
    if ( self.gameType == MINE_GAMETYPE_10 ) {
        return 10;
    }
    else if (self.gameType == MINE_GAMETYPE_40)
    {
        return 40;
    }
    else if (self.gameType == MINE_GAMETYPE_99)
    {
        return 99;
    }
    int count = [[[NSUserDefaults standardUserDefaults]objectForKey:@"MINECOUNT"] intValue];
    return count == 0?10:count;
}

-(void)setMineCount:(int)mineCount
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:mineCount] forKey:@"MINECOUNT"];
}
@end
