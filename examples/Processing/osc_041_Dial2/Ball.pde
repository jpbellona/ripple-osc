class Ball {
  
  float x;
  float y;
  float xspeed;
  float yspeed;
  float diam;
  String id;
  
  Ball(float x_, float y_, float diam_, String id_) {
    x = x_;
    y = y_;
    diam = diam_;
    xspeed = 2;
    yspeed = 2;
    id = id_;
  }
  
  void move() {
    // Add the current speed to the location.
    x = x + xspeed;
    y = y + yspeed;
    // Remember, || means "or."
    if ((x > width) || (x < 0)) {
      // If the object reaches either edge, multiply speed by -1 to turn it around.
      xspeed = xspeed * -1;
    }
    
        // Remember, || means "or."
    if ((y > height) || (y < 0)) {
      // If the object reaches either edge, multiply speed by -1 to turn it around.
      yspeed = yspeed * -1;
    }
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
  
  private String get_id() {
    return id;
  }
  
  void update(int newNum) {
    diam = newNum;
    float maxspeed = sliderRange;
    if (xspeed > 0) {
      xspeed = map(newNum, 0, maxspeed, 4, 0);
    } else {
      xspeed = -1 * (map(newNum, 0, maxspeed, 4, 0));
    }
    if (yspeed > 0) {
      yspeed = map(newNum, 0, maxspeed, 4, 0);
    } else {
      yspeed = -1 * (map(newNum, 0, maxspeed, 4, 0));
    }
  }
  
  void display() {
    // Display circle at x location
    stroke(0);
    fill(175);
    ellipse(x,y,diam*2,diam*2);
    fill(0);
  }
} 
