/**
 * Example sketch for working with ARS system.
 *
 * Takes words generated by users and diplays them randomly on the screen as a tag cloud.
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
NetAddress myRemoteLocation;
HashMap responses = new HashMap();
PFont font;

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
  show_tagCloud();
}

/*
 * Takes global hashMap responses and displays the text as a tagCloud.
 */
void show_tagCloud() {
  
  //show if hashMap is not empty
  if (!responses.isEmpty()) {
    Iterator i = responses.entrySet().iterator();  // Get an iterator
    String word;
    int wordLength;
    float wordDistance;
    int[] plusMinus = {-1, 1};
   
    while (i.hasNext()) {
      Map.Entry me = (Map.Entry)i.next();
      //me.getKey() + me.getValue()
      //println(me.getValue());
      word = me.getValue().toString();
      wordLength = word.length();
      wordDistance = wordLength * 5;
      //fontsize is inversely related (larger at center)
      textFont(font, 33);
      
      //randomizing values creates different shapes

      //Standard tag cloud
      //draw_word(word, wordDistance, random(-1,1), random(-1,1));  
      
      //Static X formation
      //draw_word(word, wordDistance, plusMinus[int(random(2))], plusMinus[int(random(2))]);
      
      //Tall X pattern
      //draw_word(word, wordDistance, plusMinus[int(random(2))], random(-3,3));
     
      //Simple hourglass
      draw_word(word, wordDistance, random(-3,3), plusMinus[int(random(2))]);
      
    } //end loop through the responses
  } 
  
}

/*
 * Draw a line and a word on the screen for various tag cloud examples
 */
void draw_word(String word, float wordDistance, float wordWidthDistance, float wordHeightDistance) {
   //draw line to the word's start
   stroke(255);
   line(width/2, height/2, (width/2)+(wordDistance*wordWidthDistance), (height/2)+(wordDistance*wordHeightDistance));
   //draw text
   text( word, (width/2)+(wordDistance*wordWidthDistance), (height/2)+(wordDistance*wordHeightDistance) );
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
