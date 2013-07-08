/*
 * Incoming OSC message are forwarded to the oscEvent method and parsed here.
 */
void oscEvent(OscMessage theOscMessage) {
  
  String pattern = theOscMessage.addrPattern();
  String typetag = theOscMessage.typetag();
  
  print_response(theOscMessage, pattern, typetag);
  store_question(theOscMessage, pattern, typetag);
  store_response(theOscMessage, pattern, typetag);
  
  return;
}

/*
 * Print out any OSC message out to the compiler window.
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
void store_question(OscMessage theOscMessage, String pattern, String typetag ) {
  
  //based upon that we know the /question_url, which is always /question
  //typetag is always: ss
  if (pattern.equals("/question") == true) {
    current_question = theOscMessage.get(2).stringValue();
    current_questionObj[0] = theOscMessage.get(0).stringValue();
    current_questionObj[1] = theOscMessage.get(1).stringValue();
  }
  //set the maximum range if type /slider
  if (pattern.equals("/question/slider/scale")) {
    if (typetag.equals("s")) {
      sliderRange = float(theOscMessage.get(0).stringValue());
      println("new sliderRange set: " + theOscMessage.get(0).stringValue());
    }
  }
  //set the maximum range if type /numeric
  if (pattern.equals("/question/numeric/max")) {
    if (typetag.equals("s")) {
      sliderRange = float(theOscMessage.get(0).stringValue());
      println("new sliderRange set: " + theOscMessage.get(0).stringValue());
    }
  }
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
    if (typetag.charAt(1) == 'i') {
      if (!(responses.containsKey(theOscMessage.get(0).stringValue()))) {
        create_ball(theOscMessage.get(0).stringValue(), theOscMessage.get(1).intValue());
      }
      //(adds or updates automatically based upon the unique ID)
      responses.put(theOscMessage.get(0).stringValue(), theOscMessage.get(1).intValue());
      update_ball(theOscMessage.get(0).stringValue(), theOscMessage.get(1).intValue());
    } 
    else if (typetag.charAt(1) == 'f') {
      if (!(responses.containsKey(theOscMessage.get(0).stringValue()))) {
        create_ball(theOscMessage.get(0).stringValue(), int(theOscMessage.get(1).floatValue()));
      }
      //(adds or updates automatically based upon the unique ID)
      responses.put(theOscMessage.get(0).stringValue(), int(theOscMessage.get(1).floatValue()));
      update_ball(theOscMessage.get(0).stringValue(), int(theOscMessage.get(1).floatValue()));
    }
    else if (typetag.charAt(1) == 's') {
      //println("string");
      responses.put(theOscMessage.get(0).stringValue(), theOscMessage.get(1).stringValue());
    }
  } 
}
