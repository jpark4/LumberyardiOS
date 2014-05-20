//
//  ViewController.m
//  LumberyardPOC
//
//  Created by Jay Park on 11/18/13.
//  Copyright (c) 2013 SapientNitro. All rights reserved.
//

#import "ViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(log) userInfo:nil repeats:YES];
}

- (void)log
{
    DDLogVerbose(@"lumberyard reporting for duty");
}

- (IBAction)LogPressed:(id)sender
{
    DDLogVerbose(@"Log pressed");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
