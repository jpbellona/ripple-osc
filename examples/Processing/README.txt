README.txt

 /*
 * These included Processing examples are meant to be used with the Audience-Response System (ARS),
 * a tool for communicating with multiple users in real-time via the internet.
 * These sketches were made to work with the OSC plugin inside the ARS, enabling the creative application
 * of dynamic input from multiple users inside a given space utilizing their smart phones and web devices.
 * 
 * The included examples demonstrate basic ideas for translating dynamic input into a visual output.
 *           Enjoy. 
 *                     	Jon Bellona (2012-09)
 *			http://jpbellona.com
 */


 /*
 * //Question messages output as: /question ss
 * //
 * // [0] => String the data type;       ( 'numeric', 'cloud', 'slider', 'open-response', 'true-false', 'multiple-choice' )
 * // [1] => String question text;       ( the admin's question to the group )
 * //
 * //    IF multiple-choice data type, an additional message will be sent over OSC
 * // output as: /question/choices sssss
 * // [0] => String choice A;            (the professor generated choice)
 * // [1] => String choice B;
 * // [2] => String choice C;
 * // [3] => String choice D;
 * // [4] => String choice E;
 *
 * //    IF slider data type, additional messages will be sent over OSC
 * // output as: /question/slider/scale i
 * // [0] => int    the range of the slider;
 * // output as: /question/slider/type s
 * // [0] => String the type of slider used;
 *
 * //    IF numeric data type, additional messages will be sent over OSC
 * // output as: /question/numeric/minimum i
 * // [0] => int    the lowest value of the responses;
 * // output as: /question/numeric/maximum i
 * // [0] => int    the highest value of the responses;
 * // output as: /question/numeric/interval i
 * // [0] => int    the step value of the responses;
 */
 

 /*
 * // Response messages are always sent using two urls:  /response/user 
 * // messages will always follow the same format regardless of the url name
 * //
 * // shared content response messages output as: /response sssi
 * //
 * // [0] => String admin user name;     ( uoregon name of admin associated with session )
 * // [1] => String the data type;       ( 'dial', 'open-response', 'true-false', 'multiple-choice' )
 * // [2] => String question text;       ( the admin's question to the group )
 * // [3] => Int total response count;   ( every response generated during the session is counted )
 * //
 * // user specific response messages follow a format according to data type: /response/user
 * // 'numeric'         =>   ssi  
 * // 'slider'          =>   ssi  
 * // 'open-response'   =>   sss
 * // 'true-false'      =>   sss
 * // 'multiple-choice' =>   sss
 * // 'cloud'           =>   sss
 * //
 * // [0] => String unique clientID;     (20 character unique ID)
 * // [1] => String user generated name; (e.g. frank, johnny, susie)
 * // [2] => String or Int;              (the user response -- number or string)
 */