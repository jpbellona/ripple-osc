/**
 * Example sketch for working with ARS system.
 *
 * Takes dial information sent by users and diplays them as a vertical bar graph on the screen.
 * See the README for the syntax of incoming OSC messages. 
 *
 * @author jpbellona
 * @link   http://jpbellona.com 
 */

import java.util.Iterator;
import java.util.Map;
import oscP5.*;
import netP5.*;
OscP5 oscP5;

//sketch specific globals
HashMap responses = new HashMap();
PFont font;
String current_question = "";
String[] current_questionObj = new String[2];
float sliderRange = 100;

/*
 * setup our sketch
 */
void setup() {
  size(600,600);
  //input port
  oscP5 = new OscP5(this, 1234);
  
  font = loadFont("Didot-33.vlw");
  textFont(font);
  frameRate(5);
  smooth();
  textAlign(CENTER);
}


void draw() {
  background(0); 
  // Display the question
  fill(255);
  text(current_question, 10, 75, width-20, 200);
  
  // Draw a bar graph based upon the number of user responses
  draw_spectrum();
}

/*
 * Takes the user generated responses (ints) and draws a bar graph
 *
 * The number of bars is equal to the number of users
 * The maximum height is scaled to the maximum range of the OSC dial (24)
 * Might be great for using this bar graph to control a oscillator spectrum.
 */
void draw_spectrum() {
  //show if hashMap is not empty
  if (!responses.isEmpty()) {
    Iterator i = responses.entrySet().iterator();  // Get an iterator
    int userNum = 0;
    int numBars = responses.size();
    int eqlSpacing = 0;
    float barWidth = width/numBars;
    float barHeight = 0;
     
    stroke(0);
    strokeWeight(2);
    fill(255, 70);
  
    while (i.hasNext()) {
      Map.Entry me = (Map.Entry)i.next();
      //print(me.getKey() + " is ");
      //println(me);
      userNum = int(me.getValue().toString());
//      println(userNum);
      barHeight = map(userNum, 0, sliderRange, height, 0);
      rect(eqlSpacing, height, barWidth,(height-barHeight)*-1, 4, 4, 0, 0);
      eqlSpacing += barWidth;
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

  while (i.hasNext()) {
    Map.Entry me = (Map.Entry)i.next();
    print(me.getKey() + " is ");
    println(me.getValue());
  } 
}
