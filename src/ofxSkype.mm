//
//  ofxSkype.mm
//  
//
//  Created by Zach Gage on 4/29/12 at Eyebeam Art+Technology Center -> eyebeam.org
//  Almost Entirely based off of the code for Skype4cmd by Sushant Verma -> http://www.trynull.com/2011/02/01/controlling-skype-via-terminal-on-a-mac/

//  Important. This code controls the skype desktop application. It must be open for this code to work.

#import "ofxSkype.h"
#include "testApp.h"

#define SKYPE_EVENT @"SKSkypeAPINotification"
#define SKYPE_RESPONSE @"SKYPE_API_NOTIFICATION_STRING"

#define SKYPE_BUNDLE @"com.skype.skype"


ofxSkype::ofxSkype(){
	controller = [[SkypeController alloc] init];
}
ofxSkype::~ofxSkype(){
	[controller release];
}

void ofxSkype::sendMessage(string message){
	[controller sendCommand:[[[NSString alloc] initWithCString: message.c_str()] autorelease]];
}

@interface SkypeController()
- (void) recievedSkypeResponse:(NSNotification *)notification;
- (void) sendSkypeMessages:(NSFileHandle *)input;
@end

@implementation SkypeController

- (id) init
{
	self = [super init];
	if (self != nil) {
		skype = [SBApplication applicationWithBundleIdentifier:SKYPE_BUNDLE];
		
		NSDistributedNotificationCenter *notifications = [NSDistributedNotificationCenter defaultCenter];
		
		[notifications addObserver:self
						  selector:@selector(recievedSkypeResponse:)
							  name:SKYPE_EVENT
							object:nil];
	}
	
	NSArray* runningApplications = [[NSWorkspace sharedWorkspace] runningApplications];
    bool skypeRunning = false;
    for (NSRunningApplication *app in runningApplications)
    {
        if ([app.bundleIdentifier isEqualToString:SKYPE_BUNDLE])
        {
            skypeRunning = true;
            break;
        }
    }
    
    if (skypeRunning)
    {
        [self skypeReady];
    }
    else
    {
        NSNotificationCenter* center = [[NSWorkspace sharedWorkspace] notificationCenter];
        [center addObserver:self
                   selector:@selector(skypeLaunched:)
                       name:NSWorkspaceDidLaunchApplicationNotification
                     object:Nil];  
    }
	
	return self;
}

- (void) readCommandsAsyncFromFileHandle:(NSFileHandle *)fileHandle
{    
	[NSThread detachNewThreadSelector:@selector(sendSkypeMessages:)
							 toTarget:self
						   withObject:fileHandle];
    NSArray* runningApplications = [[NSWorkspace sharedWorkspace] runningApplications];
    bool skypeRunning = false;
    for (NSRunningApplication *app in runningApplications)
    {
        if ([app.bundleIdentifier isEqualToString:SKYPE_BUNDLE])
        {
            skypeRunning = true;
            break;
        }
    }
    
    if (skypeRunning)
    {
        [self skypeReady];
    }
    else
    {
        NSNotificationCenter* center = [[NSWorkspace sharedWorkspace] notificationCenter];
        [center addObserver:self
                   selector:@selector(skypeLaunched:)
                       name:NSWorkspaceDidLaunchApplicationNotification
                     object:Nil];  
    }
}

- (void) skypeReady
{
    fflush(stdin);
    
    NSNotificationCenter* center = [[NSWorkspace sharedWorkspace] notificationCenter];
    [center addObserver:self
               selector:@selector(skypeTerminated:)
                   name:NSWorkspaceDidTerminateApplicationNotification
                 object:Nil];
    
    printf("Skype Ready!\n");
    fflush(stdout);
}

- (void)skypeLaunched:(NSNotification *)notification
{
    NSString *appBundle = [[notification userInfo] valueForKey:@"NSApplicationBundleIdentifier"];
    if ([appBundle isEqualToString:SKYPE_BUNDLE])
    {
        NSNotificationCenter* center = [[NSWorkspace sharedWorkspace] notificationCenter];
        [center removeObserver:self];
        [self skypeReady];
    }
}

- (void)skypeTerminated:(NSNotification *)notification
{
    NSString *appBundle = [[notification userInfo] valueForKey:@"NSApplicationBundleIdentifier"];
    if ([appBundle isEqualToString:@"com.skype.skype"])
    {
        printf("Skype closed, exiting skype API too.\n");
        [[NSApplication sharedApplication]terminate:self];
    }
}

- (void) recievedSkypeResponse:(NSNotification *)notification
{
	NSDictionary *userinfo = [notification userInfo];
	NSString *responseMessage = [userinfo valueForKey:SKYPE_RESPONSE];
	printf("%s\n",[responseMessage UTF8String]);
	
	testApp * app = (testApp*)ofGetAppPtr();
	app->gotSkypeReply([responseMessage UTF8String]);
	
    fflush(stdout);
}

- (void) sendCommand:(NSString *)command
{
	[skype sendCommand:command
			scriptName:@"OpenFrameworks"];
}

- (void) sendSkypeMessages:(NSFileHandle *)input
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
	NSData *data = [input availableData];
	while (data) {
		NSString *command = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		[skype sendCommand:command
				scriptName:@"OpenFrameworks"];
		data = [input availableData];
	}
	[pool drain];
}

- (void) dealloc
{
	NSDistributedNotificationCenter *notifications = [NSDistributedNotificationCenter defaultCenter];
	
	[notifications removeObserver:self
							 name:SKYPE_EVENT
						   object:nil];
	[skype release];
	[super dealloc];
}

@end