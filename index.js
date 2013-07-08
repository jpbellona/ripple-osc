/*
 * OSC plugin: translates question and responses from the Ripple system into OSC messages.
 *
 * OSC plugin is a middleware plugin for node.js Audience Response System. 
 * The plugin translates questions and user answers into OSC messages, and sends these off to a user defined OSC client.
 * The /url naming convention is static; however, the user may send these messages to multiple OSC clients.
 * This version contains a single OSC server.
 *
 * @author Jon Bellona
 * @link http://jpbellona.com
 * @version 1.0.0
 *
 * TODO:
 * **Plugin settings are saved to user array data, not global array data, so multiple instances of plugin may be used.
 */

/*
 * The OSC plugin essentials.
 */
//global vars
var osc = require('osc-min')
  , dgram = require("dgram")
  , udp = dgram.createSocket("udp4")
  , util = require('util');

var oscClients = new Array()
  , messageRootUrl = "/response"
  , messageUrl = "/user"
  , hits = 0
  , moduleName = 'osc';
var oscPort, serverIP, sendHeartbeat;
// var oscServerOn = false;

// On enable and menuSave, we update the configuration sent in to us and store it here
var configOSC = {};

// Alias to eventually hold the parent app's api
var api;

//hooks/handlers
var plugin = {
  enable:           onEnable,
  disable:          onDisable,
  configMenuInputs: configMenu,
  loadConfig:       loadConfig,
  saveConfig:       saveConfig,
  pageLoad:         pageLoad
};

var question = {
  distribute: questionDistribute
}
var answer = {
  distribute: answerDistribute
}
// module.exports = exports;
module.exports.plugin = plugin;
module.exports.question = question;
module.exports.answer = answer;

/**
 * plugin init
 */
var onEnable = function() { 
  //set up initial OSC server 
  initOSCserver();
  // oscServerOn = true;

  //devel
  if( process.env.NODE_ENV === 'development')
    console.log(moduleName + " plugin enabled");
}

/**
 * Disable plugin.
 * 
 * Kill OSC server when the plugin is disabled.
 */
var onDisable = function() {
  oscServer = null;
  oscClient = null;
  // oscServerOn = false;

  //devel
  if( process.env.NODE_ENV === 'development')
    console.log(moduleName + " plugin disabled");
}

/*
 * Store variables for the plugin (front-end) menu.
 */
function configMenu(menu){
  console.log("Configuration menu requested: ", util.inspect(menu));
  
  inputs = [
    {
      key         : "osc_room",
      label       : "Room ID",
      placeholder : "Add a Room ID: e.g. ernn2l",
      value       : ""
    },
    {
      key         : "osc_port",
      label       : "OSC Client Port (Used for all Client IPs)",
      placeholder : "Add an OSC Port: e.g. 8000",
      value       : ""
    },
    {
      key         : "osc_ip",
      label       : "OSC Client IPs (use your computer's IP address, and add any other computer's IP address to send messages to. You must use a comma separated list for multiple clients). Your computer may need be plugged in via Ethernet to work within a firewall.",
      placeholder : "Add an IP: e.g. 127.0.0.1",
      value       : ""
    }
  ];

  menu.inputs = inputs;
}


/**
 * Initialize plugin variables.
 * 
 * Configuration is sent from the main application,
 * which is currently called immediately after enable.
 */
 function loadConfig(documents) {
  for (var i = 0, len = documents.length; i < len; i++) {
    if (documents[i].name == "osc") {
      setOSCConfig(documents[i]);
    }
  }
  console.log(moduleName + " plugin got config: " + util.inspect(documents));
}

/**
 * Add local CSS and JS to plugin Configuration page.
 * @param  {Object} locals  main application sends menuConfig inputs and other info.
 * @return {Object}         locally added urls to js and css files.
 */
 function pageLoad(locals, req){

  if (locals.pluginName != moduleName) return;

  //console.log("RES Req",req.connection.remoteAddress);
  locals.plugins.js = new Array;
  locals.plugins.css = new Array;
  locals.plugins.variables = {};

  var pluginDirJS = '/plugins/' + locals.pluginName + '/js/';
  locals.plugins.js.push(pluginDirJS + 'osc.js');
  var pluginDirCSS = '/plugins/' + locals.pluginName + '/css/';
  locals.plugins.css.push(pluginDirCSS + 'osc.css');
  var ip = req.header('x-forwarded-for') || req.connection.remoteAddress;
  locals.plugins.variables['clientIP'] = ip;
}


/*
 * Save plugin options
 *
 * Upon OSC plugin menu save by admin, change OSC options and ping the OSC server.
 * change OSC client port, change receiving room, create OSC clients
 */
 function saveConfig(record) {

  if (record) {
    setOSCConfig(record);
  }
  //reset the global hits value and ping OSC.
  hits = 0;
  pingOSC();
}

/*****************************************************/
/******************* OSC functions *******************/
/*****************************************************/

/*
 * Initialize the OSC server.
 */
function initOSCserver() {

  //use the network IP as the OSC server.
  getNetworkIPs(function (error, ip) {
    if (!error) { 
      //return first IP address only
      serverIP = (ip.constructor === Array)? ip[0] : ip;
    } else {
      if( process.env.NODE_ENV === 'development') {
        console.log('error:', error);
      }
      serverIP = '127.0.0.1';
    }

    //devel
    if( process.env.NODE_ENV === 'development') {
      console.log('#########################');
      console.log("OSC server IP is: " + serverIP);
    }
  });
}

/**
 * Stores config data - called from menuSave and configLoaded hooks to centralize the common
 * behavior of disconnect, set config, reconnect.
 */
function setOSCConfig(data) {
  //console.log("OSC plugin config: " + util.inspect(data));

  var clients = new Array();
  var ip_addrs = data.osc_ip;
  ip_addrs = ip_addrs.replace(/\s/g, "");
  ip_addrs = ip_addrs.split(',');
  for(var i=0; i<ip_addrs.length; i++) {
    clients[i] = ip_addrs[i];
  }

  configOSC = {
    oscRoom: data.osc_room,
    oscPort: data.osc_port,
    oscClients: clients,
  };

  // if (configOSC.oscClients) {
  //   for(var i=0; i<configOSC.oscClients.length; i++) {
  //     console.log("sending OSC messages to " + configOSC.oscClients[i] + " : " + configOSC.oscPort);
  //   }
  // }
}

/**
 * Ping all available OSC clients with a simple string and integer.
 */
function pingOSC() {
  var buf;
  var alphabet = "abcdefghijklmnopqrstuvwxyz";
  var pingString = '';
  for (var i = 0; i < 10; i++){
    pingString += alphabet.charAt(Math.floor(Math.random()*26));
  }
  buf = osc.toBuffer({
    address: "/ping",
    args: [
      pingString,
      new Buffer("ping"), {
        type: "integer",
        value: Math.random()*1000
      }
    ]
  });
  //send message out to available clients
  if (configOSC.oscClients) {
    for (var i=0; i<configOSC.oscClients.length; i++) { 
      udp.send(buf, 0, buf.length, configOSC.oscPort, configOSC.oscClients[i]);
    }
  }
}


/*
 * Take the question and distribute via OSC
 *
 * //question messages output as: /question ss
 * //
 * // [0] => String the data type;       ( 'dial', 'open-response', 'true-false', 'multiple-choice' )
 * // [1] => String question text;       ( the admin's question to the group )
 * //
 * //    IF multiple-choice data type, an additional message will be sent over OSC
 * // output as: /question/choices sssss
 * // [0] => String choice A;            (the professor generated choice)
 * // [1] => String choice B;
 * // [2] => String choice C;
 * // [3] => String choice D;
 * // [4] => String choice E;
 */ 
function questionDistribute(responseRoom, question) {

  console.log(question);

  //send the answer out the client OSC port and is turned on.
  //if (!oscServerOn) return; //do not need as the plugin may be on when the server starts.
  if (!udp) return;
  if (!configOSC.oscClients) return;
  //only count and send the message if the answer is in the appropriate room.
  if (responseRoom != configOSC.oscRoom) return;

  // create osc question message with all information related to the answer.
  var buf;
  buf = osc.toBuffer({
    address: "/question",
    args: [  
      // question.qID, //only one admin per room, so do not need question author ID
      question.type, 
      question.qTxt, 
    ]
  });
  //send the message to all clients
  for (var i=0; i<configOSC.oscClients.length; i++) { 
    udp.send(buf, 0, buf.length, configOSC.oscPort, configOSC.oscClients[i]);
  }

  //if question specific options (question.qOptions), 
  //loop through the options and send them via OSC for receiver to utilize.
  var addBuf;
  if (question.qOptions.length !== 0) {
    for (var o = 0; o < question.qOptions.length; o++) {
      addBuf = osc.toBuffer({
        address: "/question/" + question.type + "/" + question.qOptions[o].name,
        args: [ 
          question.qOptions[o].value
        ]
      });
      //send the message to all available clients
      for (var i=0; i<configOSC.oscClients.length; i++) { 
        udp.send(addBuf, 0, addBuf.length, configOSC.oscPort, configOSC.oscClients[i]);
      }
    }
  }

  ///////////////////////////////////////////////////////////////////////////////////////////
  /////////////  OLD, case-switch way of handling options //////////////////////////////////
  ///////  not a dynamic way, but provides a sense of handling question types options ///////
  ///////////////////////////////////////////////////////////////////////////////////////////

  // //question specific options
  // var addBuf, addBuf2, addBuf3;
  // switch(question.type){
  //   case 'multiple-choice':
  //     addBuf = osc.toBuffer({
  //       address: "/question/choices",
  //       args: [ 
  //         question.qOptions[0].value,
  //         question.qOptions[1].value,
  //         question.qOptions[2].value,
  //         question.qOptions[3].value,
  //         question.qOptions[4].value
  //       ]
  //     });
  //     //send the message to all available clients
  //     for (var i=0; i<configOSC.oscClients.length; i++) { 
  //       udp.send(addBuf, 0, addBuf.length, configOSC.oscPort, configOSC.oscClients[i]);
  //     }
  //     break;

  //   case 'slider':
  //     addBuf = osc.toBuffer({
  //       address: "/question/slider/scale",
  //       args: [ 
  //         question.qOptions[0].value,
  //       ]
  //     });
  //     addBuf2 = osc.toBuffer({
  //       address: "/question/slider/type",
  //       args: [ 
  //         question.qOptions[1].value,
  //       ]
  //     });
  //     //send the message to all available clients
  //     for (var i=0; i<configOSC.oscClients.length; i++) { 
  //       udp.send(addBuf, 0, addBuf.length, configOSC.oscPort, configOSC.oscClients[i]);
  //       udp.send(addBuf2, 0, addBuf2.length, configOSC.oscPort, configOSC.oscClients[i]);
  //     }
  //     break;

  //   case 'numeric':
  //     addBuf = osc.toBuffer({
  //       address: "/question/numeric/minimum",
  //       args: [ 
  //         question.qOptions[0].value,
  //       ]
  //     });
  //     addBuf2 = osc.toBuffer({
  //       address: "/question/numeric/maximum",
  //       args: [ 
  //         question.qOptions[1].value,
  //       ]
  //     });
  //     addBuf3 = osc.toBuffer({
  //       address: "/question/numeric/interval",
  //       args: [ 
  //         question.qOptions[2].value,
  //       ]
  //     });
  //     //send the message to all available clients
  //     for (var i=0; i<configOSC.oscClients.length; i++) { 
  //       udp.send(addBuf, 0, addBuf.length, configOSC.oscPort, configOSC.oscClients[i]);
  //       udp.send(addBuf2, 0, addBuf2.length, configOSC.oscPort, configOSC.oscClients[i]);
  //       udp.send(addBuf3, 0, addBuf3.length, configOSC.oscPort, configOSC.oscClients[i]);
  //     }
  //     break;
  // }

}


/*
 * Take the answer and distribute via OSC
 *
 * // OSC messages are always sent using two urls:  /response/user 
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
 * // 'dial' =>            ssi  
 * // 'open-response' =>   sss
 * // 'true-false' =>      sss
 * // 'multiple-choice' => sss
 * //
 * // [0] => String unique clientID;     (20 character unique ID)
 * // [1] => String user generated name; (e.g. frank, johnny, susie)
 * // [2] => String or Int;              (the user response -- dial number or string)
 */
function answerDistribute(responseRoom, clientID, clientName, questionObj, answer) {
  
  console.log("[answerDistribute] args", arguments );
  console.log(configOSC);

  //send the answer out the client OSC port if server exists and is turned on.
  //if (!oscServerOn) return; //do not need as the plugin may be on when the server starts.
  if (!udp) return;
  if (!configOSC.oscClients) return;

  //only count and send the message if the answer is in the appropriate room.
  if (responseRoom != configOSC.oscRoom) return;

  //the number of 'hits' or responses all clients send during an open session.
  //will only return to 0 if the session restarts.
  hits++;

  var buf, userbuf;
  buf = osc.toBuffer({
    address: messageRootUrl,
    args: [
      questionObj.type, 
      questionObj.qTxt, 
      hits 
    ]
  });
  //clientID is the encoded, unique ID (e.g. ePS8jwEqFueXqTg6Daz0)
  userbuf = osc.toBuffer({
    address: messageRootUrl + messageUrl,
    args: [  
      clientID, 
      answer
    ]
  });

  //send the message across udp.
  for (var i=0; i<configOSC.oscClients.length; i++) { 
    udp.send(buf, 0, buf.length, configOSC.oscPort, configOSC.oscClients[i]);
    udp.send(userbuf, 0, userbuf.length, configOSC.oscPort, configOSC.oscClients[i]);
  }
}


/**
 * Check the node network and return the server's IP
 *
 * Node Server IP will be used as the OSC server IP. End user won't need to know this IP address.
 * 
 * @link http://stackoverflow.com/questions/3653065/get-local-ip-address-in-node-js
 * @see initOSC()
 */
var getNetworkIPs = (function () {
  var ignoreRE = /^(127\.0\.0\.1|::1|fe80(:1)?::1(%.*)?)$/i;

  var exec = require('child_process').exec;
  var cached;
  var command;
  var filterRE;

  switch (process.platform) {
  case 'win32':
  //case 'win64': // TODO: test
      command = 'ipconfig';
      filterRE = /\bIP(v[46])?-?[^:\r\n]+:\s*([^\s]+)/g;
      // TODO: find IPv6 RegEx
      break;
  case 'darwin':
      command = 'ifconfig';
      filterRE = /\binet\s+([^\s]+)/g;
      // filterRE = /\binet6\s+([^\s]+)/g; // IPv6
      break;
  default:
      command = 'ifconfig';
      filterRE = /\binet\b[^:]+:\s*([^\s]+)/g;
      // filterRE = /\binet6[^:]+:\s*([^\s]+)/g; // IPv6
      break;
  }

  return function (callback, bypassCache) {
      if (cached && !bypassCache) {
          callback(null, cached);
          return;
      }
      // system call
      exec(command, function (error, stdout, sterr) {
          cached = [];
          var ip;
          var matches = stdout.match(filterRE) || [];

          //if (!error) {
          for (var i = 0; i < matches.length; i++) {
              ip = matches[i].replace(filterRE, '$1')
              if (!ignoreRE.test(ip)) {
                  cached.push(ip);
              }
          }
          //}
          callback(error, cached);
      });
  };
})();


//DEVELOPMENT TEST
//### Send a bunch of args every two seconds;
// sendHeartbeat = function() {
//   var buf;
//   buf = osc.toBuffer({
//     address: "/heartbeat",
//     args: [
//       new Buffer("beat"), {
//         type: "integer",
//         value: Math.random()*100
//       }
//     ]
//   });

//   if (configOSC.oscClients) {
//     for (var i=0; i<configOSC.oscClients.length; i++) { 
//       udp.send(buf, 0, buf.length, configOSC.oscPort, configOSC.oscClients[i]);
//     }
//   }
// };
// setInterval(sendHeartbeat, 2000);