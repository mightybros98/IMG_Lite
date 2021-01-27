import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
class cropped_image extends StatefulWidget {
  File imagepath;
  cropped_image(this.imagepath);
  @override
  _cropped_imageState createState() => _cropped_imageState(imagepath);
}

class _cropped_imageState extends State<cropped_image> {
  File imagepath;
  _cropped_imageState(this.imagepath);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cropped Image"),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          Container(
            margin: EdgeInsets.only(left: 20),
            child: Text("Image successfully cropped",style: TextStyle(fontSize: 25),),
          ),

          SizedBox(
            height: 20,
          ),
          
          Container(
            height: 350,
            width: MediaQuery.of(context).size.width,
            child: Image.file(imagepath)
          )
        ],
      ),
    );
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      }
    }
    return false;
  }


}
