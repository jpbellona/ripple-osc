/**
 * Example sketch for working with ARS system.
 * Prints out OSC messages into the compiler window
 *
 * See the README for the incoming OSC message syntax (or just run and print!)
 *
 * @author jpbellona
 * @link   http://jpbellona.com
 */

import oscP5.*;
import netP5.*;
  
OscP5 oscP5;
NetAddress myRemoteLocation;

void setup() {
  size(400,400);
  //input port
  oscP5 = new OscP5(this, 1234);
}


void draw() {
  background(0); 
}


/*
 * Incoming OSC message are forwarded to the oscEvent method and parsed here.
 */
void oscEvent(OscMessage theOscMessage) {
  
  String pattern = theOscMessage.addrPattern();
  String typetag = theOscMessage.typetag();
  
  print_response(theOscMessage, pattern, typetag);
  
  return;
}

/*
 * Print out any incoming OSC message out to the compiler window.
 */
void print_response(OscMessage theOscMessage, String pattern, String typetag ) {
  println("#######");
  for (int i=0; i< typetag.length(); i++) {
    char type = typetag.charAt(i);
    switch(type) {
      case 'i': 
        println(pattern + ": " + theOscMessage.get(i).intValue());
        break;
      case 'f': 
        println(pattern + ": " + theOscMessage.get(i).floatValue());
        break;
      case 's':
        println(pattern + ": " + theOscMessage.get(i).stringValue());
        break;
    } //end switch
  } //end for
}
