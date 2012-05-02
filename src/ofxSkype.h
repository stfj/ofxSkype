//
//  ofxSkype.h
//  
//
//  Created by Zach Gage on 4/29/12 at Eyebeam Art+Technology Center -> eyebeam.org
//

#pragma once

#include "ofMain.h"

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

#import "Skype.h"

@interface SkypeController : NSObject {
	SkypeApplication *skype;
}

- (void) sendCommand:(NSString *)command;

- (void) skypeReady;

@end


class ofxSkype {
public:
	
	ofxSkype();
	~ofxSkype();
	
	void sendMessage(string message);
	
	SkypeController * controller;
};