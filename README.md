OSC: plugin for [Ripple][0]
====================

OSC is a middleware plugin for Ripple, an audience response system built off of node.js.
The plugin translates questions and user responses into OSC (Open Sound Control) messages, sending these off to a user defined OSC client.
The "/url" messaging convention is static for OSC; however, the user may send all messages to multiple OSC clients.
This version contains a single OSC server.

**@plugin author [Jon Bellona][1]**

Requires
---------------------

- [Ripple][0], audience response system (open-source software)
- OSC enabled software ([Processing][2], Max/MSP) to parse and use OSC messages.



Installation and Use
---------------------

- Install [Ripple][0].
- Download [OSC plugin][5].
- Create a 'osc' directory within the /plugins directory of your [Ripple][0] install. 
- Copy the OSC plugin files into the /osc directory.
- Run <code>$ npm install</code>  from within the /osc directory to install all necessary node modules. You will need to use a line command tool (e.g. Terminal).
- Start the [Ripple][0] server.
- Run [Ripple][0] app with node. (e.g. Terminal. cmd <code>$ node app.js</code>  or cmd <code>$ ripple start</code>)
- On [Ripple][0], login as admin and navigate to Plugins. Configure the [OSC plugin][5] page.



Plugin Configuration Page (within [Ripple][0])
---------------------

Once OSC has been added to the plugins directory of Ripple, an admin can configure OSC.
The [OSC plugin][5] will automatically populate within Ripple's plugin page. 

![Ripple Plugins][img1]

Click "Configure" to open up the OSC configuration page.

![OSC Configuration][img2]

__Room ID__ relates to a Question/Answer session between an admin (you) and anyone who navigates to your session url. The Room ID is auto-generated when a session is created.

 > *Note: Because multiple rooms may be open at once inside Ripple, only a single room may be used to transmit OSC messages. (i.e. Only a single room is supported at this time).**

__OSC Client Port__ is a single port that all OSC messages will be sent to.

__OSC Client IPs__ are computer IP addresses that will receive OSC messages. If you run Ripple from a localhost, then you may use 127.0.0.1 to send OSC messages locally on your computer. You can separate IP addresses with a comma in order to send messages to multiple destinations.

> *NOTE: The OSC server IP will always be set based upon Ripple's server, while the client IPs are any user-define recipient of OSC messages.**

**IMPORTANT: Saving the OSC Configuration page pings the OSC server, which can serve as a simple test to ensure proper connection.**



OSC Messaging
---------------------


This section breaks down the type of OSC messages.

### Questions
Questions sent by the admin are output as

__*/question*__

> There are two typetags (ss) sent with this message:
 * [0] => String the data type;       ( 'numeric', 'cloud', 'slider', 'open-response', 'true-false', 'multiple-choice' )
 * [1] => String question text;       ( the admin's question to the group )
**

The 'multiple-choice' data type includes the additional message

> __*/question/choices*__
 There are five typetags (sssss) sent with this message:
 * [0] => String choice A;            (admin generate these choices within Ripple)
 * [1] => String choice B;
 * [2] => String choice C;
 * [3] => String choice D;
 * [4] => String choice E;
**

The 'slider' data type includes two additional messages

> __*/question/slider/scale*__
 A single typetag (i) is sent with this message  <br/>
 Integer: the range of the slider
**

> __*/question/slider/type*__
 A single typetag (s) is sent with this message  <br/>
 String: the type of slider used
**

The 'numeric' data type includes three additional messages

> __*/question/numeric/minimum*__
 A single typetag (i) is sent with this message <br/>
 Integer: the lowest value of the responses
**

> __*/question/numeric/maximum*__
 A single typetag (i) is sent with this message <br/>
 Integer: the highest value of the responses
**

> __*/question/numeric/interval*__
 A single typetag (i) is sent with this message <br/>
 Integer: the step value of the responses
**

### Responses
Users in the Ripple system generate responses that are translated into OSC as

__*/response*__ and __*/response/user*__

The shared content response messages (__*/response*__) includes basic information about the response.

> The four typetags (sssi) sent with this message:
 * [0] => String admin user name;     ( username of admin associated with session )
 * [1] => String the data type;       ( 'dial', 'open-response', 'true-false', 'multiple-choice' )
 * [2] => String question text;       ( the admin's question to the group )
 * [3] => Int total response count;   ( every response generated during the session is counted )
**

**IMPORTANT: Saving the OSC configuration page resets the total response count.**

A user specific response message (__*/response/user*__) follows a typetag format according to its data type.
* 'numeric'         =>   sf 
* 'slider'          =>   sf
* 'open-response'   =>   ss
* 'true-false'      =>   ss
* 'multiple-choice' =>   ss
* 'cloud'           =>   ss

> The typetags are broken down as such:
 * [0] => String unique clientID;     (20 character unique ID)
 * [1] => String or float;            (the user response -- number or string)
**

[Processing][2] Examples
---------------------

Included with the [OSC plugin][5] are several [Processing][2] sketches scripted to work directly with the plugin. These examples all require the [oscP5][3] library.

**utilPrint**	
A simple print sketch that takes any question or response and prints these to Processing's console.

**wordCloud**  
Takes any string response generated by users and displays them in a continually moving tag cloud.

**randomResponseLength**	
Displays user responses randomly upon the screen, and draws a line between all responses that are within a set distance from each other.

**fallingBalls**	
User responses display as a bouncing ball object on the screen.

**trueFalse**	
Created to work specifically with true/false data types, true respones generate a moving ball on the left side of the screen, while a false response will generate a moving ball on the right side of the screen.

**dial**	
Any number response from a user will add a scalable vertical bar to the screen. The more users present, the more bars appear.

**dial2**	
Users control the size and speed of their moving ball in space using a 'slider' or 'numeric' data type.

**@plugin author [Jon Bellona][1]**

[0]: https://github.com/uoregon-libraries/ripple  "Ripple on github"
[1]: http://jpbellona.com/  "Jon Bellona"
[2]: http://processing.org/  "http://processing.org/"
[3]: http://www.sojamo.de/libraries/oscP5/  "oscP5 library"
[4]: https://npmjs.org/package/npm "A package manage for node"
[5]: http://github.org "OSC plugin on github"

[img1]: https://raw.github.com/jpbellona/ripple-osc/master/images/ripple-plugins.png "Ripple Plugins page"
[img2]: https://raw.github.com/jpbellona/ripple-osc/master/images/osc-config.png "OSC Config page"