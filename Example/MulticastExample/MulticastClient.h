//
//  MulticastClient.h
//  MulticastExample
//
//  Created by Matthew Prockup & Matthew Zimmerman on 5/16/13.
//  Copyright (c) 2013 Drexel University. All rights reserved.
//


//////////////
//          //
//  Usage   //
//          //
/////////////////////////////////////////////////////////////////////////////////////////////
//
//  Create the client:
//      MulticastClient* client = [[MulticastClient alloc] init];
//
//  Setup the multicast parameters
//      [client startMulticastListenerOnPort:12345 withAddress:@"239.254.254.251"];
//
//  Start the listener thread
//      [client startListen];
//
//  Poll for most recent reveived data
//      NSData* buffer = [client getCurrentData];
//
////////////////////////////////////////////////////////////////////////////////////////////




#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <net/if.h>
#include <ifaddrs.h>
#include <string.h>
#include <stdio.h>
#include <errno.h>
//#define kMulticastAddress "239.255.255.251"
//#define kPortNumber 1234
#define kBufferSize 250
#define kMaxSockets 16

@protocol MulticastClientDelegate <NSObject>


@optional

-(void) processMulticastData:(float*)data;

-(void) gotMulticastData;

-(void) processChromaData:(NSMutableDictionary*)chroma;

-(void) processSpectrumData:(NSMutableDictionary*)spectrum;

@end

@interface MulticastClient : NSObject
{
    id delegate;
    int sock_fd;
    
    struct sockaddr_in addr;
    NSMutableData* data;
    NSString* address;
    const char* kMulticastAddress;
    int kPortNumber;
    NSMutableArray* fuckyeah;
    struct ip_mreq multicast_request;
    
    float band1;
    float band2;
    float band3;
    float band4;
    
    BOOL socketOpen;
    BOOL listenStarted;
}

@property id delegate;
@property (retain) NSData* data;

-(id) initWithPort:(int)port address:(NSString*)add andDelegate:(id)del;
-(NSData*)getCurrentData; //returns the latest data

-(NSMutableArray*) getVUMeters;
-(NSMutableDictionary*) getTrackChroma;
-(NSMutableDictionary*) getTrackSpectrum;

-(void) start;
-(void) stop;
-(BOOL) running;
@end
