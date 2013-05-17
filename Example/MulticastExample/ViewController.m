//
//  ViewController.m
//  MulticastExample
//
//  Created by Matthew Zimmerman on 5/16/13.
//  Copyright (c) 2013 Matthew Zimmerman. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)sendPressed:(id)sender {
    
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
//    [appDelegate setSomLoaded:YES];
    [appDelegate sendTestSignal];
    
}

@end
