#include "testApp.h"

//--------------------------------------------------------------
void testApp::setup(){
	
	callIsActive = false;
	
	skypeConnection = new ofxSkype();
		
}

//--------------------------------------------------------------
void testApp::update(){
	
	ofBackground(0, 0, 0);

	if(callIsActive)
		ofBackground(100, 100, 100);
}

//--------------------------------------------------------------
void testApp::draw(){
	//ofDrawBitmapString("volume = "+ofToString(playerVolume, 2), 10, 10);
}

//--------------------------------------------------------------
void testApp::keyPressed(int key){
}

//--------------------------------------------------------------
void testApp::keyReleased(int key){
	
	if(!callIsActive)
		callNumber("5551237777"); //type some other number here
	else
		hangUp();
}

//--------------------------------------------------------------
void testApp::mouseMoved(int x, int y ){

}

//--------------------------------------------------------------
void testApp::mouseDragged(int x, int y, int button){

}

//--------------------------------------------------------------
void testApp::mousePressed(int x, int y, int button){
}

//--------------------------------------------------------------
void testApp::mouseReleased(int x, int y, int button){

}

//--------------------------------------------------------------
void testApp::windowResized(int w, int h){

}

//--------------------------------------------------------------
void testApp::gotMessage(ofMessage msg){

}

//--------------------------------------------------------------
void testApp::dragEvent(ofDragInfo dragInfo){ 

}

//--------------------------------------------------------------

void testApp::callNumber(string number){
	string command = "call +1"+number;
	skypeConnection->sendMessage(command);
}

void testApp::hangUp(){
	string command = "alter call "+curCallID+" hangup";
	skypeConnection->sendMessage(command);
	callIsActive = false;
}

void testApp::gotSkypeReply( string reply){
	if(reply.find("CALL") != -1){
		if(callIsActive){
			if(reply.find("EARLYMEDIA") != -1){
				ringStart = ofGetElapsedTimef();
				cout<<ringStart<<endl;
			} else if(reply.find("INPROGRESS") != -1){
				float delta = ofGetElapsedTimef() - ringStart;
				
				if(delta < 1.0)
					hangUp(); // auto message machine!
				else if(delta > 20.0)
					hangUp(); // too many rings, risking message machine
				cout<<delta<<endl;
			}
			else if(reply.find("FINISHED") != -1 || reply.find("FAILED") != -1 || reply.find("MISSED") != -1)
				callIsActive = false;
		} else {
			if(reply.find("ROUTING") != -1){
				callIsActive = true;
				//get and store call ID.
				
				int startLoc = reply.find("CALL ") + 5;
				int len = reply.substr(startLoc, reply.length()-startLoc).find(" ");
				curCallID = reply.substr(startLoc, len);
			}
		}
	}
}