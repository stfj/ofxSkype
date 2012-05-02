#pragma once

#include "ofMain.h"
#import "ofxSkype.h"


class testApp : public ofBaseApp{

	public:
		void setup();
		void update();
		void draw();

		void keyPressed  (int key);
		void keyReleased(int key);
		void mouseMoved(int x, int y );
		void mouseDragged(int x, int y, int button);
		void mousePressed(int x, int y, int button);
		void mouseReleased(int x, int y, int button);
		void windowResized(int w, int h);
		void dragEvent(ofDragInfo dragInfo);
		void gotMessage(ofMessage msg);
	
		string curCallID;
		bool callIsActive;
		float ringStart;
		ofxSkype * skypeConnection;
	
		void gotSkypeReply( string reply); //required to be implemented. in test app. this is my ghetto event
	
		void callNumber(string number);
		void hangUp();
};
