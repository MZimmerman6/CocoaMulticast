//
//  MulticastServer.h
//  MulticastExample
//
//  Created by Matthew Prockup & Matthew Zimmerman on 5/16/13.
//  Copyright (c) 2013 Drexel University. All rights reserved.
//
//

//////////////
//          //
//  Usage   //
//          //
/////////////////////////////////////////////////////////////////////////////////////////////
//
//  Create the server:
//      MulticastServer* server = [[MulticastServer alloc] initWithPort:12345 address:@"239.254.254.251" andDelegate:nil];
//
//  Send data:
//      BOOL success = [server sendMulticast:(float*)data withLength:(int)lengthBytes];
//      
//
////////////////////////////////////////////////////////////////////////////////////////////



#import <Foundation/Foundation.h>
//Network
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <net/if.h>
#include <ifaddrs.h>
#include <string.h>
#include <stdio.h>
#include <errno.h>
#include <time.h>
#define kMaxSockets 16

@protocol MulticastServerDelegate <NSObject>

@optional

-(void) multicastSendSuccessful;

-(void) multicastSendFailed;

-(void) multicastServerStopped;

@end

@interface MulticastServer : NSObject {
    NSString* address;
    const char* kMulticastAddress;
    int kPortNumber;
    BOOL networkPrepared;
    int sock_fds[kMaxSockets];
    struct ifaddrs *addrs;
    const struct ifaddrs *cursor;
    struct sockaddr_in addr;
    int number_sockets;
    BOOL socketOpen;
}


@property (strong, nonatomic) id delegate;

-(id) initWithPort:(int)port address:(NSString*)add andDelegate:(id)del;

-(BOOL) sendMulticast:(float*)data withLength:(int)length;

-(void) stop;

@end
