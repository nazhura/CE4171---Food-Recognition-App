import 'dart:convert'; //for jsondecode
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter/services.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.orange,
      ),
      home: const MyHomePage(title: 'Your Health Buddy'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;


  @override
    State<MyHomePage> createState() => _MyHomePageState();
  }

  class _MyHomePageState extends State<MyHomePage> {
    File? selectedImage;
    String message = "";

    uploadImage() async{
      final request = http.MultipartRequest("POST", Uri.parse("http://34.124.170.58:5000/upload")); //url is gcp's server url
      final headers = {"Content-type": "multipart/form-data"};

      request.files.add(http.MultipartFile('image', //in flask app is: imagefile = request.files['image']
            selectedImage!.readAsBytes().asStream(),selectedImage!.lengthSync(),
            filename: selectedImage!.path.split("/").last));

      request.headers.addAll(headers);


      final response = await request.send();
      http.Response res = await http.Response.fromStream(response);

      final resJson = jsonDecode(res.body);
      message = resJson['message'];

      if (response.statusCode == 200){
        print("successfully uploaded to server");
        print(message);
        Fluttertoast.showToast(
            msg: "Successfully uploaded image to server!",
            //msg: "Successfully uploaded image to server!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2,
            backgroundColor: Colors.lightGreen,
            textColor: Colors.white,
            fontSize: 16.0
        );



      }
      else {
        print("error try again");
        Fluttertoast.showToast(
            msg: "Error uploading image to server!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2,
            backgroundColor: Colors.redAccent,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
      //String replyme = '';


      setState(() {

      });
  }

  Future getImage() async{
    final pickedImage = await ImagePicker().getImage(source: ImageSource.camera);
    selectedImage = File(pickedImage!.path);

    setState(() {});
  }

    void handleClick(String value) {
      switch (value) {
        case 'Reload':
          Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
          break;
        case 'Exit':
          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          break;
      }
    }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title,style: TextStyle(
            color: Colors.white
        )),

        actions: <Widget>[
          PopupMenuButton<String>(

            onSelected: handleClick,
            itemBuilder: (BuildContext context) {
              return {'Reload', 'Exit'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],

      ),

      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.



        child: Wrap(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          alignment: WrapAlignment.center,
          spacing: 10, // to apply margin in the main axis of the wrap
          runSpacing: 10,
          children: <Widget>[

            SizedBox(
              height: 60,
              width: 180,
              child: TextButton.icon(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.orangeAccent)
                  ),
                  onPressed: getImage,
                  icon: Icon(Icons.add_a_photo_rounded, color: Colors.white),
                  label: Text("Take picture", style: TextStyle(color: Colors.white))),



            ),
          Spacer(),


            SizedBox(
              height: 60,
              width: 180,
              child: TextButton.icon(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.orangeAccent)
                  ),
                  onPressed: uploadImage,
                  icon: Icon(Icons.upload, color: Colors.white),
                  label: Text("Upload", style: TextStyle(color: Colors.white))),



            ),


            selectedImage == null ? Text("Please take a picture to upload the image to the cloud ", style: TextStyle(
                height: 10), textAlign: TextAlign.center,softWrap: false): Image.file(selectedImage!),
            Center(
                child: Text('The food is: \n' + message,
                    style: TextStyle(fontSize: 20), textAlign: TextAlign.center,softWrap: false)
            ),










          ],
        ),



      ),

      //floatingActionButton: FloatingActionButton(onPressed:getImage, child: Icon(Icons.add_a_photo)),
     // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
