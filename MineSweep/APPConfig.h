//
//  APPConfig.h
//  MineSweep
//
//  Created by fmj on 14-3-28.
//  Copyright (c) 2014年 lenovo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,MINE_GAMETYPE)
{
    //9*9 10个雷
    MINE_GAMETYPE_10 = 0,
    //16*16, 40个雷
    MINE_GAMETYPE_40 = 1,
    //16*30 99个雷
    MINE_GAMETYPE_99 = 2,
    //自定义
    MINE_GAMETYPE_CUSTOM = 3
    
};

@interface APPConfig : NSObject
+(APPConfig*)instance;
@property(nonatomic) MINE_GAMETYPE gameType;
//行数
@property(nonatomic) int rowCount;
//列数
@property(nonatomic) int columCount;
//雷数
@property(nonatomic) int mineCount;
@end
#define APP_CONFIG [APPConfig instance]
#define MINE_SIZE  35
#define MINE_ROWCOUNT [APPConfig instance].rowCount
#define MINE_COLUMNCOUNT [APPConfig instance].columCount
#define MINE_COUNT [APPConfig instance].mineCount
