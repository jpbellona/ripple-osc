//Circle displays randomly on screen.
//size based upon input String length.

class Circle {
  float x;
  float y;
  float w;
  String s;
  PVector pos;
  
  Circle(float tempX, float tempY, String tempS) {
    x = tempX;
    y = tempY;
    s = tempS;
    w = s.length();
    pos = new PVector(x,y);
  }
  
  void display() {
    // Display the circle
    fill(175);
    stroke(0);
    //ellipse(x,y,w,w);
    textSize(s.length()*4);
    text(s,x,y);
  }
  
  PVector getPos() {
    return pos; 
  }
}  
