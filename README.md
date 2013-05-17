CocoaMulticast
==============

Multicast client and server written in Objective-C for iOS or OS X

Simply copy and paste the contents of the "Files" folder into an XCode project for either iOS or OS X and
initialize them as follows:

Client:

client = [[MulticastClient alloc] initWithPort:12345 address:@"239.254.254.251" andDelegate:self];
[client start];

Server:
server = [[MulticastServer alloc] initWithPort:12345 address:@"239.254.254.251" andDelegate:self];


Both server and client have optional delegate methods that will be called when important events happen.
Please view the *.h files for each object to see the names of these methods. 

Files are currently configured for another project but should be simple enough to edit for whatever

I do not promise functionality. Feel free to edit however you may want. 
