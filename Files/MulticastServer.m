//
//  MulticastServer.m
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


#import "MulticastServer.h"

@implementation MulticastServer
@synthesize delegate;

-(id) initWithPort:(int)port address:(NSString *)add andDelegate:(id)del {
    
    self = [super init];
    if (self) {
        
        address = [[NSString alloc] initWithString:add];
        kMulticastAddress = [address UTF8String];
        kPortNumber = port;
        
        // Obtain list of all network interfaces
        
        if ( getifaddrs(&addrs) < 0 ) {
            // Error occurred
            return nil;
        }
        
        // Loop through interfaces, selecting those AF_INET devices that support multicast, but aren't loopback or point-to-point
        cursor = addrs;
        number_sockets = 0;
        
        while ( cursor != NULL && number_sockets < kMaxSockets ) {
            if ( cursor->ifa_addr->sa_family == AF_INET
                && !(cursor->ifa_flags & IFF_LOOPBACK)
                && !(cursor->ifa_flags & IFF_POINTOPOINT)
                &&  (cursor->ifa_flags & IFF_BROADCAST) ) {
                
                // Create socket
                sock_fds[number_sockets] = socket(AF_INET, SOCK_DGRAM, 0);
                if ( sock_fds[number_sockets] == -1 ) {
                    // Error occurred
                    return nil;
                }
                if ( setsockopt(sock_fds[number_sockets], IPPROTO_IP, IP_MULTICAST_IF, &((struct sockaddr_in *)cursor->ifa_addr)->sin_addr, sizeof(struct in_addr)) != 0  ) {
                    // Error occurred
                    return nil;
                }
                // We're not interested in receiving our own messages, so we can disable loopback (don't rely solely on this - in some cases you can still receive your own messages)
                u_char loop;
                if ( setsockopt(sock_fds[number_sockets], IPPROTO_IP, IP_MULTICAST_LOOP, &loop, sizeof(loop)) != 0 ) {
                    // Error occurred
                    return nil;
                }
                
                number_sockets++;
            }
            cursor = cursor->ifa_next;
        }
        
        // Initialise multicast address
        memset(&addr, 0, sizeof(addr));
        addr.sin_family = AF_INET;
        addr.sin_addr.s_addr = inet_addr(kMulticastAddress);
        addr.sin_port = htons(kPortNumber);
        
        networkPrepared = true;
        socketOpen = true;
    }
    NSLog(@"Multicast Server Created Successfully!");
    return self;
}

-(BOOL)sendMulticast:(float*)data withLength:(int)lengthBytes
{
    //    Sends out a buffer of float values across the multicast network from element 0 to lengthBytes
    
    BOOL success = NO;
    
    if(networkPrepared && socketOpen) {
        int i;
        success = YES;
        for ( i=0; i<number_sockets; i++ ) {
            int num =  sendto(sock_fds[i], data, lengthBytes, 0, (struct sockaddr*)&addr, sizeof(addr));
            if ( num < 0 ) {
                success = NO;;
            }
        }
        if (success) {
            NSLog(@"Multicast Send Successful");
        } else {
            NSLog(@"Multicast Send Failed");
        }
    }
    
//    Tell delegate whether the send succeeded or failed, if the delegate exists and wants that information
    if ([delegate respondsToSelector:@selector(multicastSendSuccessful)] && success) {
        [delegate multicastSendSuccessful];
    } else if ([delegate respondsToSelector:@selector(multicastSendFailed)] && !success) {
        [delegate multicastSendFailed];
    }
    
    return success;
}

-(void)stop
{
    //    Closes all open sockets and lets object know the sockets are closed and that the network is not available
    for (int i=0; i<number_sockets; i++ ) {
        close(sock_fds[i]);
    }
    socketOpen = false;
    networkPrepared = false;
    
//    Let delegate know that the server stopped, if it exists and wants that information
    if ([delegate respondsToSelector:@selector(multicastServerStopped)]) {
        [delegate multicastServerStopped];
    }
}




@end
