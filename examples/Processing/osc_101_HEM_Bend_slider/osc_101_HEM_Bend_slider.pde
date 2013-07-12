/** 
 * WBlut HEMesh library with OSCp5 library with ARS plugin
 * v.HE_Mesh 1.81
 * http://hemesh.wblut.com/
 *
 * Counts the characters of responses generated and bends the 3D Mesh accordingly.
 * Admin can hit 'r' to reset the mesh and acquire new responses.
 *
 * Continuous type slider responses work really well. 
 * for 0-10 users (range 0-50 works well)
 */
import wblut.math.*;
import wblut.processing.*;
import wblut.core.*;
import wblut.hemesh.*;
import wblut.geom.*;

HE_Mesh mesh;
WB_Render render;
WB_Plane P;
WB_Line L;
HEM_Bend modifier;

import java.util.Iterator;
import java.util.Map;
import oscP5.*;
import netP5.*;
OscP5 oscP5;
NetAddress myRemoteLocation;
HashMap responses = new HashMap();
String current_question = "";
int currentResponse = 0;
int responseAdditions = 0;
PFont font;

void setup() {
  size(800, 800, P3D);
  
  //font
  font = loadFont("Didot-33.vlw");
  textFont(font);
  textAlign(CENTER);
//  smooth();
  
  //osc
  oscP5 = new OscP5(this, 1234);
  
  //HEM
  createMesh();
  modifier=new HEM_Bend();
  P=new WB_Plane(0,0,-200,0,0,1); 
  modifier.setGroundPlane(P);// Ground plane of bend modifier 
  //you can also pass directly as origin and normal:  modifier.setGroundPlane(0,0,-200,0,0,1)
 
  L=new WB_Line(0,0,-200,-1,0,-200);
  modifier.setBendAxis(L);// Bending axis
  //you can also pass the line as two points:  modifier.setBendAxis(0,0,-200,1,0,-200)
  
  modifier.setAngleFactor(30.0/400);// Angle per unit distance (in degrees) to the ground plane
  // points which are a distance d from the ground plane are rotated around the
  // bend axis by an angle d*angleFactor;
 
  modifier.setPosOnly(false);// apply modifier only on positive side of the ground plane?
  mesh.modify(modifier);
  render=new WB_Render(this);
}

void draw() {

  countResponses();
  
  background(120);
  directionalLight(255, 255, 255, 1, 1, -1);
  directionalLight(127, 127, 127, -1, -1, 1);
  
  pushMatrix();
    translate(400, 350, 0);
    rotateY(0.125*TWO_PI);
    rotateX(HALF_PI);
    fill(255);
    noStroke();
    
    render.drawFaces(mesh);
    stroke(0);
    render.drawEdges(mesh);
    render.draw(P,500);
    render.draw(L,800);
    //recreate mesh and modifier
    createMesh();
    //L=new WB_Line(0,0,0.4*mouseY-200,-1,0,0.4*mouseY-200);
   // modifier.setAngleFactor(0.00030*mouseX);
    L=new WB_Line(0,0,0.4*(height/2)-200,-1,0,0.4*(height/2)-200);
    modifier.setAngleFactor(0.00030*(responseAdditions*10));
    modifier.setBendAxis(L);
    mesh.modify(modifier);
    showResponse(responseAdditions);
  popMatrix();
}

void countResponses() {
  Iterator i = responses.entrySet().iterator();  // Get an iterator
  //reset our counter
  responseAdditions = 0;
  
  while (i.hasNext()) {
    Map.Entry me = (Map.Entry)i.next();
   //print(me.getKey() + " is ");
   //println(me.getValue());
//   String tmpResponse = me.getValue().toString();
//   responseAdditions += tmpResponse.length();
    responseAdditions += (Integer) me.getValue();
  } 
}

/**
 * prints a message on the screen
 */
void showResponse(int message) {
 // println(mouseX);
  
  translate(-400, -350, 100);
  rotateY(0.125*TWO_PI * -1);
  rotateX(HALF_PI* -1);
  fill(255, 255, 255);
  text(str(message),214, 180, 200);
 //text(message,400, 750, 0);
 // text(message,400, 750, 200);
}

void createMesh(){
  HEC_Cylinder creator=new HEC_Cylinder();
  creator.setFacets(32).setSteps(16).setRadius(50).setHeight(400);
  mesh=new HE_Mesh(creator);
}

void keyPressed() {
 if (key == 'r') {
   println("reset the count");
   println(responseAdditions);
   responses = new HashMap();
   currentResponse = 0;
 } 
}

