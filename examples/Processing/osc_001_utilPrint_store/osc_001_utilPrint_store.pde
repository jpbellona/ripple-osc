/**
 * Example sketch for working with ARS system.
 * Prints out OSC messages into the compiler window and stores user responses into a hashMap
 *
 * See the README for the incoming OSC message syntax (or just run and print!)
 *
 * @author jpbellona
 * @link   http://jpbellona.com
 */

import java.util.Iterator;
import java.util.Map;
import oscP5.*;
import netP5.*;
  
OscP5 oscP5;
NetAddress myRemoteLocation;
HashMap responses = new HashMap();

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
  store_response(theOscMessage, pattern, typetag);
  
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

/*
 * Store received OSC messages into a global hashMap (associative array).
 */
void store_response(OscMessage theOscMessage, String pattern, String typetag ) {
  
  // based on that we know the /url associated with the user specific message.
  // we also have a pre-established hashMap (setup as a global)
  //1. user ID
  //2. user response
  if (pattern.equals("/response/user") == true) {
    //We require that the user response typetag fits our mold 
    if (typetag.equals("ss")) {
      responses.put(theOscMessage.get(0).stringValue(), theOscMessage.get(1).stringValue());
      println("user value stored!");
    }
  }
}


void mousePressed() {
 print_collected_responses();
}

/*
 * Iterate through our hashMap (user generated responses) and print
 */
void print_collected_responses() {
  Iterator i = responses.entrySet().iterator();  // Get an iterator

  println("user values are:");
  while (i.hasNext()) {
    Map.Entry me = (Map.Entry)i.next();
    print(me.getKey() + " is ");
    println(me.getValue());
  } 
}
