//
//  settingViewController.m
//  MineSweep
//
//  Created by fmj on 14-3-29.
//  Copyright (c) 2014年 lenovo. All rights reserved.
//

#import "settingViewController.h"

@interface settingViewController ()
{
    NSArray* arryTypeNames;
    NSArray* arryCustomName;
    NSArray* arryTypeDescrptions;
    UISlider* widthSlider;
    UISlider* heightSlider;
    UISlider* minesSlider;
}
@end

@implementation settingViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    arryTypeNames = [[NSArray alloc] initWithObjects:@"初级", @"中级", @"高级", @"自定义",nil];
    arryTypeDescrptions= @[ @"9*9,10雷",@"16*16,40雷",@"16*30,99雷"];
    arryCustomName = [[NSArray alloc] initWithObjects:@"宽度", @"高度", @"地雷", nil];    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)backButtonClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ( APP_CONFIG.gameType == MINE_GAMETYPE_CUSTOM ) {
        return  2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 4;
    }
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
     if (indexPath.section == 0 ) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"levelIdentifier" forIndexPath:indexPath];
        MINE_GAMETYPE type = (MINE_GAMETYPE)indexPath.row;
        if (APP_CONFIG.gameType == type) {
            [cell setBackgroundColor:[UIColor orangeColor]];
        }
        else
        {
            [cell setBackgroundColor:[UIColor whiteColor]];
        }
        [cell textLabel].text = [arryTypeNames objectAtIndex:indexPath.row];
        [cell detailTextLabel].text = [self typeDescription:type];
        [cell.detailTextLabel setTextColor:[cell.textLabel textColor]];
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"customIdentifer" forIndexPath:indexPath];
        UILabel* lblTitle = (UILabel*)[cell viewWithTag:100];
        UISlider* slider = (UISlider*)[cell viewWithTag:101];
        lblTitle.text = [arryCustomName objectAtIndex:indexPath.row];
        if (indexPath.row == 0) {
            if (widthSlider == nil) widthSlider = slider;
            slider.value = MINE_ROWCOUNT;
        }
        else if(indexPath.row == 1 )
        {
            if (heightSlider == nil) heightSlider = slider;
            slider.value = MINE_COLUMNCOUNT;
        }
        else if (indexPath.row == 2 ) {
            if(minesSlider == nil) minesSlider = slider;
            slider.value = MINE_COUNT;
        }
    }
    return cell;
}

-(NSString*)typeDescription:(MINE_GAMETYPE)type
{
    if (type != MINE_GAMETYPE_CUSTOM) {
        return [arryTypeDescrptions objectAtIndex:type];
    }
    return [NSString stringWithFormat:@"%d*%d,%d雷",APP_CONFIG.customRowCount,APP_CONFIG.customColumCount,APP_CONFIG.customMineCount];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
{
    if (section == 1) {
        return @"自定义设置";
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0 ) {
        return 0.0f;
    }
    return 50.0f;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( indexPath.section == 0 ) {
        if (APP_CONFIG.gameType == indexPath.row) {
            return;
        }
        APP_CONFIG.gameType = indexPath.row;
        [tableView reloadData];
    }
}

-(IBAction)customValueChanged:(UISlider*)slider
{
    if (slider==widthSlider ) {
        APP_CONFIG.rowCount = (int)slider.value;
    }
    else if(slider == heightSlider )
    {
        APP_CONFIG.columCount = (int)slider.value;
    }
    else if(slider == minesSlider )
    {
        APP_CONFIG.mineCount = (int)slider.value;
    }
    minesSlider.maximumValue = MINE_COLUMNCOUNT*MINE_ROWCOUNT/2.0;
    if ( APP_CONFIG.mineCount> minesSlider.maximumValue) {
        APP_CONFIG.mineCount = minesSlider.maximumValue;
    }

    [self.tableView reloadData];
}


@end
