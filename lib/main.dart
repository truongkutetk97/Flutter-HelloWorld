// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        appBar: AppBar(
          title: const Center(
            child: Text(
              "MQTT Client Debug Console",
              textAlign: TextAlign.center,
            ),
          ),
        ),
        body: const MyCustomForm(),
      ),
    );
    // );
  }
}
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     const appTitle = 'MqttClient DebugConsole';
//     return MaterialApp(
//       title: appTitle,
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text(appTitle),
//         ),
//         body: const MyCustomForm(),
//       ),
//     );
//   }
// }

class MyCustomForm extends StatelessWidget {
  const MyCustomForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const <Widget>[
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Please input the Server Address',
              ),
            ))
      ],
    );
  }
}
// final client = MqttServerClient.withPort('34.126.97.74', '', 1883);

// var pongCount = 0; // Pong counter

// Future<int> main() async {
//   /// A websocket URL must start with ws:// or wss:// or Dart will throw an exception, consult your websocket MQTT broker
//   /// for details.
//   /// To use websockets add the following lines -:
//   /// client.useWebSocket = true;
//   /// client.port = 80;  ( or whatever your WS port is)
//   /// There is also an alternate websocket implementation for specialist use, see useAlternateWebSocketImplementation
//   /// Note do not set the secure flag if you are using wss, the secure flags is for TCP sockets only.
//   /// You can also supply your own websocket protocol list or disable this feature using the websocketProtocols
//   /// setter, read the API docs for further details here, the vast majority of brokers will support the client default
//   /// list so in most cases you can ignore this.
//   /// Set logging on if needed, defaults to off
//   client.logging(on: true);

//   /// Set the correct MQTT protocol for mosquito
//   client.setProtocolV311();

//   /// If you intend to use a keep alive you must set it here otherwise keep alive will be disabled.
//   client.keepAlivePeriod = 20;

//   /// The connection timeout period can be set if needed, the default is 5 seconds.
//   client.connectTimeoutPeriod = 2000; // milliseconds

//   /// Add the unsolicited disconnection callback
//   client.onDisconnected = onDisconnected;

//   /// Add the successful connection callback
//   client.onConnected = onConnected;

//   /// Add a subscribed callback, there is also an unsubscribed callback if you need it.
//   /// You can add these before connection or change them dynamically after connection if
//   /// you wish. There is also an onSubscribeFail callback for failed subscriptions, these
//   /// can fail either because you have tried to subscribe to an invalid topic or the broker
//   /// rejects the subscribe request.
//   client.onSubscribed = onSubscribed;

//   /// Set a ping received callback if needed, called whenever a ping response(pong) is received
//   /// from the broker.
//   client.pongCallback = pong;

//   /// Create a connection message to use or use the default one. The default one sets the
//   /// client identifier, any supplied username/password and clean session,
//   /// an example of a specific one below.
//   final connMess = MqttConnectMessage()
//       .withClientIdentifier('Mqtt_MyClientUniqueId')
//       .withWillTopic('willtopic') // If you set this you must set a will message
//       .withWillMessage('My Will message')
//       .startClean() // Non persistent session for testing
//       .withWillQos(MqttQos.atLeastOnce);
//   debugPrint('EXAMPLE::Mosquitto client connecting....');
//   client.connectionMessage = connMess;

//   /// Connect the client, any errors here are communicated by raising of the appropriate exception. Note
//   /// in some circumstances the broker will just disconnect us, see the spec about this, we however will
//   /// never send malformed messages.
//   try {
//     await client.connect();
//   } on NoConnectionException catch (e) {
//     // Raised by the client when connection fails.
//     debugPrint('EXAMPLE::client exception - $e');
//     client.disconnect();
//   } on SocketException catch (e) {
//     // Raised by the socket layer
//     debugPrint('EXAMPLE::socket exception - $e');
//     client.disconnect();
//   }

//   /// Check we are connected
//   if (client.connectionStatus!.state == MqttConnectionState.connected) {
//     debugPrint('EXAMPLE::Mosquitto client connected');
//   } else {
//     /// Use status here rather than state if you also want the broker return code.
//     debugPrint(
//         'EXAMPLE::ERROR Mosquitto client connection failed - disconnecting, status is ${client.connectionStatus}');
//     client.disconnect();
//     exit(-1);
//   }

//   /// Ok, lets try a subscription
//   debugPrint('EXAMPLE::Subscribing to the test/lol topic');
//   const topic = '/b/#'; // Not a wildcard topic
//   client.subscribe(topic, MqttQos.atMostOnce);

//   /// The client has a change notifier object(see the Observable class) which we then listen to to get
//   /// notifications of published updates to each subscribed topic.
//   client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
//     final recMess = c![0].payload as MqttPublishMessage;
//     final pt =
//         MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

//     /// The above may seem a little convoluted for users only interested in the
//     /// payload, some users however may be interested in the received publish message,
//     /// lets not constrain ourselves yet until the package has been in the wild
//     /// for a while.
//     /// The payload is a byte buffer, this will be specific to the topic
//     debugPrint(
//         'EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
//     debugPrint('');
//   });

//   /// If needed you can listen for published messages that have completed the publishing
//   /// handshake which is Qos dependant. Any message received on this stream has completed its
//   /// publishing handshake with the broker.
//   client.published!.listen((MqttPublishMessage message) {
//     debugPrint(
//         'EXAMPLE::Published notification:: topic is ${message.variableHeader!.topicName}, with Qos ${message.header!.qos}');
//   });

//   /// Lets publish to our topic
//   /// Use the payload builder rather than a raw buffer
//   /// Our known topic to publish to
//   const pubTopic = 'Dart/Mqtt_client/testtopic';
//   final builder = MqttClientPayloadBuilder();
//   builder.addString('Hello from mqtt_client');

//   /// Subscribe to it
//   debugPrint('EXAMPLE::Subscribing to the Dart/Mqtt_client/testtopic topic');
//   client.subscribe(pubTopic, MqttQos.exactlyOnce);

//   /// Publish it
//   debugPrint('EXAMPLE::Publishing our topic');
//   client.publishMessage(pubTopic, MqttQos.exactlyOnce, builder.payload!);

//   /// Ok, we will now sleep a while, in this gap you will see ping request/response
//   /// messages being exchanged by the keep alive mechanism.
//   debugPrint('EXAMPLE::Sleeping....');
//   await MqttUtilities.asyncSleep(60);

//   /// Finally, unsubscribe and exit gracefully
//   debugPrint('EXAMPLE::Unsubscribing');
//   client.unsubscribe(topic);

//   /// Wait for the unsubscribe message from the broker if you wish.
//   await MqttUtilities.asyncSleep(2);
//   debugPrint('EXAMPLE::Disconnecting');
//   client.disconnect();
//   debugPrint('EXAMPLE::Exiting normally');
//   return 0;
// }

// /// The subscribed callback
// void onSubscribed(String topic) {
//   debugPrint('EXAMPLE::Subscription confirmed for topic $topic');
// }

// /// The unsolicited disconnect callback
// void onDisconnected() {
//   debugPrint('EXAMPLE::OnDisconnected client callback - Client disconnection');
//   if (client.connectionStatus!.disconnectionOrigin ==
//       MqttDisconnectionOrigin.solicited) {
//     debugPrint(
//         'EXAMPLE::OnDisconnected callback is solicited, this is correct');
//   } else {
//     debugPrint(
//         'EXAMPLE::OnDisconnected callback is unsolicited or none, this is incorrect - exiting');
//     exit(-1);
//   }
//   if (pongCount == 3) {
//     debugPrint('EXAMPLE:: Pong count is correct');
//   } else {
//     debugPrint(
//         'EXAMPLE:: Pong count is incorrect, expected 3. actual $pongCount');
//   }
// }

// /// The successful connect callback
// void onConnected() {
//   debugPrint(
//       'EXAMPLE::OnConnected client callback - Client connection was successful');
// }

// /// Pong callback
// void pong() {
//   debugPrint('EXAMPLE::Ping response client callback invoked');
//   pongCount++;
// }
