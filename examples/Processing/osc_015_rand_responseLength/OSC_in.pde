/*
 * Incoming OSC message are forwarded to the oscEvent method and parsed here.
 */
void oscEvent(OscMessage theOscMessage) {
  
  String pattern = theOscMessage.addrPattern();
  String typetag = theOscMessage.typetag();
  
  print_response(theOscMessage, pattern, typetag);
  store_response(theOscMessage, pattern, typetag);
  
  return;
}

/*
 * Print out any incoming OSC message out to the compiler window.
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
void store_response(OscMessage theOscMessage, String pattern, String typetag ) {
  
  // based on that we know the /url associated with the user specific message.
  // we also have a pre-established hashMap (setup as a global)
  //1. user ID
  //2. user response
  if (pattern.equals("/response/user") == true) {
    println(typetag);
    //We require that the user response typetag fits our mold 
    if (typetag.equals("ss")) {
      responses.put(theOscMessage.get(0).stringValue(), theOscMessage.get(1).stringValue());
      createResponse(theOscMessage.get(1).stringValue());
      println("response created.");
    }
  } 
}
