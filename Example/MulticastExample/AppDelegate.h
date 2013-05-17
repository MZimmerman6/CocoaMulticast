//
//  AppDelegate.h
//  MulticastExample
//
//  Created by Matthew Zimmerman on 5/16/13.
//  Copyright (c) 2013 Matthew Zimmerman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MulticastClient.h"
#import "MulticastServer.h"

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate,MulticastClientDelegate,MulticastServerDelegate> {
    
    
    MulticastClient *client;
    MulticastServer *server;
    
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;

@end
