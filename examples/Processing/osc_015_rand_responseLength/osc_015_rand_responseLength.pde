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
Circle[] responseObjects = new Circle[0];
PFont font;
PVector[] responsePositions = new PVector[0];
float hypoMax = 100;

void setup() {
  size(800,400);
  
  oscP5 = new OscP5(this, 1234); //input port
  
  font = loadFont("Didot-33.vlw");
  textFont(font);
  textAlign(CENTER);
  smooth();
}


void draw() {
  background(0); 
  // Update and display all user response objects
  for (int i = 0; i < responseObjects.length; i++ ) {
    responseObjects[i].display();
  }
  // Loop and draw a line between responses that are within X radius.
  for (int i = 0; i < responsePositions.length; i++ ) {
    // compare first position to rest in array.
    for (int j = 0; j < responsePositions.length; j++ ) {
      // (not compared to itself)
      if (i != j) {
        float xDist = abs(responsePositions[i].x - responsePositions[j].x);
        float yDist = abs(responsePositions[i].y - responsePositions[j].y);
        float resHypo = sqrt( pow(xDist, 2) + pow(yDist, 2));
        //draw a line based upon hypotenuse maximum
        if (resHypo < hypoMax) {
          stroke(255);
          line( responsePositions[i].x, responsePositions[i].y, responsePositions[j].x, responsePositions[j].y);
        }
      }
    }
  }
}



void mousePressed() {
 createTestResponse();
 print_collected_responses();
}

void createTestResponse() {
  String alphabet = "abcdefghijklmnopqrstuvwxyz";
  String pingString = "";
  for (int i = 0; i < int(random(50)); i++){
    pingString += alphabet.charAt(int(random(0,25)));
  } 
  createResponse(pingString);
}

/*
 * Iterate through our hashMap (user generated responses) and print
 */
void print_collected_responses() {
  Iterator i = responses.entrySet().iterator();  // Get an iterator

  while (i.hasNext()) {
    Map.Entry me = (Map.Entry)i.next();
    print(me.getKey() + " is ");
    println(me.getValue());
  } 
}

/*
 * Takes user response and generates a new object.
 */
void createResponse(String response) {
  // A new object
  Circle c = new Circle(random(width),random(height),response);
  responseObjects = (Circle[]) append(responseObjects,c);
  // Add new object position to array
  PVector temp = c.getPos();
  responsePositions = (PVector[]) append(responsePositions,temp);
}
