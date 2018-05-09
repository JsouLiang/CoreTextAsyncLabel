//
//  ViewController.m
//  CoreTextAsyncLabel
//
//  Created by Liang on 2018/5/9.
//  Copyright © 2018年 Liang. All rights reserved.
//

#import "ViewController.h"
#import "CTLabel.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	CTLabel *label = [[CTLabel alloc] initWithFrame:CGRectMake(100, 100, 100, 50)];
	label.text = @"Hello Core Text";
	[self.view addSubview:label];
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}


@end
