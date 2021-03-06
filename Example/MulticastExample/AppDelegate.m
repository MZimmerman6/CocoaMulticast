//
//  AppDelegate.m
//  MulticastExample
//
//  Created by Matthew Zimmerman on 5/16/13.
//  Copyright (c) 2013 Matthew Zimmerman. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.viewController = [[ViewController alloc] initWithNibName:@"ViewController_iPhone" bundle:nil];
    } else {
        self.viewController = [[ViewController alloc] initWithNibName:@"ViewController_iPad" bundle:nil];
    }
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    client = [[MulticastClient alloc] initWithPort:12345 address:@"239.254.254.251" andDelegate:self];
    [client start];
    server = [[MulticastServer alloc] initWithPort:12345 address:@"239.254.254.251" andDelegate:self];
    
    return YES;
}

-(void) processMulticastData:(float *)data {
    NSLog(@"procesing multicast data");
}

-(void) processChromaData:(NSMutableDictionary *)chroma {
    
    NSLog(@"processing chroma data");
    NSLog(@"%@",chroma);
}

-(void) processSpectrumData:(NSMutableDictionary *)spectrum {
    
    NSLog(@"processing spectrum data");
    NSLog(@"%@",spectrum);
    
}

-(void) multicastSendSuccessful {
    NSLog(@"multicast success");
}

-(void) multicastSendFailed {
    NSLog(@"multicast failed");
}

-(void) multicastServerStopped {
    NSLog(@"multicast stopped");
}

-(void) sendTestSignal {
    
    float* buffer = (float*)calloc(256, sizeof(float));
    for (int i = 0;i<256;i++) {
        buffer[i] = (float)i+1;
    }
    [server sendMulticast:buffer withLength:256];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
