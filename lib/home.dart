import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test_dslr_camera/camera_view.dart';
import 'package:test_dslr_camera/display_images.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home page")),
      body: Center(
        child: Column(
          children: [
            MaterialButton(
              onPressed: () {
                startTakingPics();
              },
              child: const Text("Take pic"),
            ),
            MaterialButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ImageListPage()));
              },
              child: const Text("Display images"),
            ),
            MaterialButton(
              onPressed: () async {
                var ipv4String = await getIPV4();
                Navigator.push(context, MaterialPageRoute(builder: (context) => CameraView(ipv4: ipv4String)));
              },
              child: const Text("Camera view"),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> startTakingPics() async {
  var ipv4String = await getIPV4();
  print("the ipv4 address is --> $ipv4String");

  // Replace "localhost" with the IP address of the computer running digiCamControl
  // var url = Uri.parse('http://$ipv4String:5513/api/camera/capture');
  //
  // // Replace "admin" and "password" with the credentials you set up in digiCamControl
  // var response = await http.post(url, headers: {
  //   'Authorization': 'Basic ' + base64Encode(utf8.encode('admin:'))
  // });

  // print('Response status: ${response.statusCode}');
  // print('Response body: ${response.body}');

  for(int i = 0; i < 5; i++)
    {
      await Future.delayed(const Duration(seconds: 3));
      String imgName = DateTime.now().toString().replaceAll(' ', '');
      takePicture(imgName, ipv4String);
    }

}

Future<void> takePicture(String filename, String ipv4String) async {
  final url = Uri.parse('http://$ipv4String:5513/api/computer/capture?filename=$filename');
  final response = await http.get(url);
  if (response.statusCode == 200) {
    print('Picture taken and saved as $filename');
  } else {
    print('Failed to take picture: ${response.statusCode}');
  }
}

Future<String> getIPV4() async {
  String ipv4String = "";
  InternetAddress? ipv4;

  Random rnd;
  int min = 8000;
  int max = 8010;
  rnd = Random();
  var randomPortNumber = min + rnd.nextInt(max - min);
  var server = await HttpServer.bind(InternetAddress.anyIPv4, randomPortNumber);

  var serverAddress = server.address;
  // Get a list of all the network interfaces
  List<NetworkInterface> interfaces = await NetworkInterface.list();

  // Iterate through the network interfaces
  for (NetworkInterface interface in interfaces) {
    // Check if the interface is not a loopback and supports IPv4
    if (!serverAddress.isLoopback &&
        interface.addresses
            .any((addr) => addr.type == InternetAddressType.IPv4)) {
      // Get the IPv4 address from the interface
      ipv4 = interface.addresses.firstWhere(
        (addr) => addr.type == InternetAddressType.IPv4,
        orElse: () => InternetAddress('0.0.0.0'),
      );

      // Print the IPv4 address
      ipv4String = ipv4.address;
      // print('IPv4 -> address: ${ipv4.address}');
    }
  }

  return ipv4String;
}
