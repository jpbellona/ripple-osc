class Ball {
  
  float x;
  float y;
  float xspeed;
  float yspeed;
  
  Ball(float x_, float y_, float xspeed_, float yspeed_) {
    x = x_;
    y = y_;
    xspeed = xspeed_;
    yspeed = yspeed_;
  }

  void move_onLeft() {
    // Add the current speed to the location.
    x = x + xspeed;
    y = y + yspeed;
    // Remember, || means "or."
    if ((x > width/2) || (x < 0)) {
      // If the object reaches either edge, multiply speed by -1 to turn it around.
      xspeed = xspeed * -1;
    }
    
        // Remember, || means "or."
    if ((y > height) || (y < 0)) {
      // If the object reaches either edge, multiply speed by -1 to turn it around.
      yspeed = yspeed * -1;
    }
  }
  
  void move_onRight() {
    // Add the current speed to the location.
    x = x + xspeed;
    y = y + yspeed;
    // Remember, || means "or."
    if ((x > width) || (x < width/2)) {
      // If the object reaches either edge, multiply speed by -1 to turn it around.
      xspeed = xspeed * -1;
    }
    
        // Remember, || means "or."
    if ((y > height) || (y < 0)) {
      // If the object reaches either edge, multiply speed by -1 to turn it around.
      yspeed = yspeed * -1;
    }
  }
  
  void display() {
    // Display circle at x location
    stroke(0);
    fill(175);
    ellipse(x,y,32,32);
    fill(0);
  }
} 
