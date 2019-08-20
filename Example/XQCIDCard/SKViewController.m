//
//  SKViewController.m
//  XQCIDCard
//
//  Created by ZClee128 on 08/19/2019.
//  Copyright (c) 2019 ZClee128. All rights reserved.
//

#import "SKViewController.h"
#import <XQCCardScanViewController.h>
@interface SKViewController ()

@end

@implementation SKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
//    self.navigationController.navigationBar.hidden = YES;
}
- (IBAction)scan:(id)sender {
    XQCCardScanViewController *cardScan = [[XQCCardScanViewController alloc] init];
    cardScan.cardtype = ScaningCardIDWithDown;
    cardScan.complete = ^(XQCCardModel * _Nonnull model) {
        NSLog(@"model ==>%@",model);
    };
    [self.navigationController pushViewController:cardScan animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
