/**
 * Example sketch for working with ARS system.
 *
 * Takes dial information sent by users and controls the attributes of his/her moving ball on the screen.
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

//sketch specific globals
HashMap responses = new HashMap();
PFont font;
String current_question = "";
String[] current_questionObj = new String[2];
Ball[] balls = new Ball[0];
String[] users = new String[0];

float sliderRange = 10;

/*
 * setup our sketch
 */
void setup() {
  size(600,600);
  //input port
  oscP5 = new OscP5(this, 1234);
  //output port
  myRemoteLocation = new NetAddress("128.223.87.194",11500);
  
  font = loadFont("Didot-33.vlw");
  textFont(font);
  smooth();
  textAlign(CENTER);
}


void draw() {
  background(0); 
  // Display the question
  text(current_question, 10, 75, width-20, 200);
  
  // Update and display all balls ranked True
  if (balls.length > 0) {
    for (int i = 0; i < balls.length; i ++ ) { // Whatever the length of that array, update and display all of the objects.
      balls[i].move();
      balls[i].display();
    }
  }
}

/*
 * Generates a new Ball.
 *
 * Calling upon user response (first time dial is spun).
 */
void create_ball(String id, int initSize) {
  // A new ball object
  Ball b = new Ball(int(random(width)), int(random(height)), initSize, id);
  balls = (Ball[]) append(balls,b);
}

/*
 * Updates the ball size.
 *
 * Calling upon any user response (when the dial is spun).
 */
void update_ball(String id, int newNum) {
 if (balls.length > 0) {
    for (int i = 0; i < balls.length; i ++ ) { // Whatever the length of that array, update and display all of the objects.
      if(balls[i].get_id().equals(id) == true ) {
        balls[i].update(newNum);
      }
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
