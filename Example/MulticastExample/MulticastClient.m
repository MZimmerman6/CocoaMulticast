//
//  MulticastClient.m
//  MulticastExample
//
//  Created by Matthew Prockup & Matthew Zimmerman on 5/16/13.
//  Copyright (c) 2013 Drexel University. All rights reserved.
//

#import "MulticastClient.h"

@implementation MulticastClient

@synthesize data;
@synthesize delegate;

-(id) initWithPort:(int)port address:(NSString*)add andDelegate:(id)del {
    
    self = [super init];
    if (self) {
        [self setDelegate:del];
        
        
        
        signal(SIGPIPE, SIG_IGN);
        address = [[NSString alloc] initWithString:add];
        kMulticastAddress = [address UTF8String];
        kPortNumber = port;
        //[super init];
        // Create socket
        sock_fd = socket(AF_INET, SOCK_DGRAM, 0);
        if ( sock_fd == -1 ) {
            // Error occurred
            return nil;
        }
        
        // Create address from which we want to receive, and bind it
        
        memset(&addr, 0, sizeof(addr));
        addr.sin_family = AF_INET;
        addr.sin_addr.s_addr = INADDR_ANY;
        addr.sin_port = htons(kPortNumber);
        if ( bind(sock_fd, (struct sockaddr*)&addr, sizeof(addr)) < 0 ) {
            // Error occurred
            return nil;
        }
        
        // Obtain list of all network interfaces
        struct ifaddrs *addrs;
        if ( getifaddrs(&addrs) < 0 ) {
            // Error occurred
            return nil;
        }
        
        // Loop through interfaces, selecting those AF_INET devices that support multicast, but aren't loopback or point-to-point
        const struct ifaddrs *cursor = addrs;
        while ( cursor != NULL ) {
            if ( cursor->ifa_addr->sa_family == AF_INET
                && !(cursor->ifa_flags & IFF_LOOPBACK)
                && !(cursor->ifa_flags & IFF_POINTOPOINT)
                &&  (cursor->ifa_flags & IFF_MULTICAST) )
            {
                
                // Prepare multicast group join request
                struct ip_mreq multicast_req;
                memset(&multicast_req, 0, sizeof(multicast_req));
                multicast_req.imr_multiaddr.s_addr = inet_addr(kMulticastAddress);
                multicast_req.imr_interface = ((struct sockaddr_in *)cursor->ifa_addr)->sin_addr;
                multicast_request = multicast_req;
                // Workaround for some odd join behaviour: It's perfectly legal to join the same group on more than one interface,
                // and up to 20 memberships may be added to the same socket (see ip(4)), but for some reason, OS X spews
                // 'Address already in use' errors when we actually attempt it.  As a workaround, we can 'drop' the membership
                // first, which would normally have no effect, as we have not yet joined on this interface.  However, it enables
                // us to perform the subsequent join, without dropping prior memberships.
                setsockopt(sock_fd, IPPROTO_IP, IP_DROP_MEMBERSHIP, &multicast_req, sizeof(multicast_req));
                
                // Join multicast group on this interface
                if (setsockopt(sock_fd, IPPROTO_IP, IP_ADD_MEMBERSHIP, &multicast_req, sizeof(multicast_req)) < 0 ) {
                    // Error occurred
                    return nil;
                }
            }
            cursor = cursor->ifa_next;
        }
        NSLog(@"Multicast Client Ready!");
        data = [[NSMutableData alloc] init];
        socketOpen = true;
    }
    return self;
}

-(void) start {
    [NSThread detachNewThreadSelector:@selector(listenLoop:) toTarget:self withObject:nil];
}

-(void) stop {
    socketOpen = NO;
    listenStarted = NO;
}

-(BOOL) running {
    return socketOpen;
}

-(void)listenLoop:(id)param
{
    socklen_t addr_len = sizeof(addr);
    float buffer [kBufferSize];
    BOOL error = false;
    while(!error && socketOpen)
    {
        NSLog(@"listening");
//        Receive a message, waiting if there's nothing there yet
        int bytes_received = recvfrom(sock_fd, buffer, sizeof(float)*kBufferSize, 0, (struct sockaddr*)&addr, &addr_len);
        
//        if nothing was received, show error
        if ( bytes_received < 0 ) {
            NSLog(@"error receiving");
            error=true;
        }
        
//        Make sure this is the multicast string we are looking for.
        if(buffer[0]==1 && buffer[1]==2 && buffer[2]==3 && buffer[3]==4)
        {
            NSLog(@"got data");
            if ([delegate respondsToSelector:@selector(gotMulticastData)]) {
                [delegate gotMulticastData];
            }
            
//            empty current data
            [data setLength:0];
            data = [NSMutableData dataWithBytes:(const void *)buffer length:sizeof(float)*kBufferSize];
            
            if ([delegate respondsToSelector:@selector(processMulticastData:)]) {
                float *buffCopy = (float*)calloc(kBufferSize, sizeof(float));
                for (int i = 0;i<kBufferSize;i++) {
                    buffCopy[i] = buffer[i];
                }
                [delegate processMulticastData:buffCopy];
            }
            
            if ([delegate respondsToSelector:@selector(processSpectrumData:)]) {
                [delegate processSpectrumData:[self getTrackSpectrum]];
            }
            
            if ([delegate respondsToSelector:@selector(processChromaData:)]) {
                [delegate processChromaData:[self getTrackChroma]];
            }
        }
    }
    close(sock_fd);
}

-(NSData*)getCurrentData
{
    return [[NSData alloc] initWithData:data];
}

-(NSMutableArray*) getVUMeters {
    float *buff = (float*)[data bytes];
    int numTracks = 4;
    if ([data length]/sizeof(float) >= kBufferSize-1) {
        NSMutableArray *output = [[NSMutableArray alloc] init];
        for (int i = 243;i<243+numTracks;i++) {
            [output addObject:[NSNumber numberWithFloat:buff[i]]];;
        }
        return output;
    }
    return nil;
}


-(NSMutableDictionary*) getTrackChroma {
    
    float* buffer = (float*)[data bytes];
    if ([data length]/sizeof(float) >= kBufferSize-1) {
        NSMutableDictionary *trackChroma = [[NSMutableDictionary alloc] init];
        NSMutableArray *track1 = [[NSMutableArray alloc] init];
        NSMutableArray *track2 = [[NSMutableArray alloc] init];
        NSMutableArray *track3 = [[NSMutableArray alloc] init];
        for (int i = 0;i<12;i++) {
            [track1 addObject:[NSNumber numberWithFloat:buffer[i+4]]];
            [track2 addObject:[NSNumber numberWithFloat:buffer[i+4+12]]];
            [track3 addObject:[NSNumber numberWithFloat:buffer[i+4+12+12]]];
        }
        
        [trackChroma setObject:track1 forKey:@"track1"];
        [trackChroma setObject:track2 forKey:@"track2"];
        [trackChroma setObject:track3 forKey:@"track3"];
        return trackChroma;
    }
    return nil;
}

-(NSMutableDictionary*) getTrackSpectrum {
    
    float* buffer = (float*)[data bytes];
    if ([data length]/sizeof(float) >= kBufferSize-1) {
        NSMutableDictionary *trackSpectrum = [[NSMutableDictionary alloc] init];
        NSMutableArray *track1 = [[NSMutableArray alloc] init];
        NSMutableArray *track2 = [[NSMutableArray alloc] init];
        NSMutableArray *track3 = [[NSMutableArray alloc] init];
        NSMutableArray *track4 = [[NSMutableArray alloc] init];
        
        for (int i = 0;i<32;i++) {
            [track1 addObject:[NSNumber numberWithFloat:buffer[i+41]]];
            [track2 addObject:[NSNumber numberWithFloat:buffer[i+41+32]]];
            [track3 addObject:[NSNumber numberWithFloat:buffer[i+41+32+32]]];
            [track4 addObject:[NSNumber numberWithFloat:buffer[i+41+32+32+32]]];
        }
        
        [trackSpectrum setObject:track1 forKey:@"track1"];
        [trackSpectrum setObject:track2 forKey:@"track2"];
        [trackSpectrum setObject:track3 forKey:@"track3"];
        [trackSpectrum setObject:track4 forKey:@"track4"];
        return trackSpectrum;
    }
    return nil;
}

@end
