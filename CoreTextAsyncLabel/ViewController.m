//
//  ViewController.m
//  CoreTextAsyncLabel
//
//  Created by Liang on 2018/5/9.
//  Copyright © 2018年 Liang. All rights reserved.
//

#import "ViewController.h"
#import "NormalTableViewCell.h"
#import "CoreTextTableViewCell.h"
#import "CTLabel.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
//	CTLabel *label = [[CTLabel alloc] initWithFrame:CGRectMake(100, 100, 100, 50)];
//	label.text = @"姓名老司机性别年龄18+姓名老司机性别年龄18+姓名老司机性别年龄18+姓名老司机性别年龄18+姓名老司机性别年龄18+";
//	label.numberOfLines = 2;
//	[self.view addSubview:label];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1000;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NormalTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"NormalTableViewCell" forIndexPath:indexPath];
//	CoreTextTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CoreTextTableViewCell" forIndexPath:indexPath];
	cell.content = @"contentstringByAppendingFormat:@, arc4random()contentstringByAppendingFormat:@, arc4random()contentstringByAppendingFormat:@, arc4random()contentstringByAppendingFormat:@, arc4random()";
	return cell;
}

@end
