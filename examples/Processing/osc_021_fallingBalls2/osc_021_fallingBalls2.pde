/**
 * Example sketch for working with ARS system.
 *
 * Takes words generated by users and diplays them randomly on the screen as a word inside a falling ball.
 * Also display the question on the screen
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
Ball[] balls = new Ball[0]; // We start with an array with just one element.
float gravity = 0.1;
PFont font;
String current_question = "";

/*
 * setup our sketch
 */
void setup() {
  size(800,400);
  //input port
  oscP5 = new OscP5(this, 1234);
  //output port
  myRemoteLocation = new NetAddress("128.223.87.194",11500);
  
  font = loadFont("Didot-33.vlw");
  textFont(font);
  textAlign(CENTER);
  smooth();
  
  //balls[0] = new Ball(50,0,16,"Start!");
}


void draw() {
  background(0); 
  // Display the question
  text(current_question, 10, 75, width-20, 200);
  
  // Update and display all balls
  for (int i = 0; i < balls.length; i ++ ) { // Whatever the length of that array, update and display all of the objects.
    balls[i].gravity();
    balls[i].move();
    balls[i].display();
  }
}


/*
 * Takes user response and generates a new falling Ball.
 */
void create_fallingBall(String response) {
  // A new ball object
  Ball b = new Ball(random(width),height/2,16,response); // Make a new object at the mouse location.
  balls = (Ball[]) append(balls,b);
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
