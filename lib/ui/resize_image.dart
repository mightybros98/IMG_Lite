import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:path_provider/path_provider.dart';

class resize_image extends StatefulWidget {
  FilePickerResult result;

  resize_image(this.result);

  @override
  _resize_imageState createState() => _resize_imageState(result);
}

class _resize_imageState extends State<resize_image> {
  List<File> files;
  FilePickerResult result;

  _resize_imageState(this.result);

  TextEditingController widthController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  String mode = "Percentage";
  int processedFile = -1;
  double percentage = 50;
  double Width = 800.0;
  double Height = 800.0;
  String ButtonName = "Start Resizing( 50 )";
  String lastUpdate = "width";

  void initState() {
    setState(() {
      widthController.text = "800";
      heightController.text = "800";
      files = result.paths.map((path) => File(path)).toList();
      print(files.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Resize Images"),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text("Resize Mode"),
                    ),
                    Expanded(
                      flex: 3,
                      child: TextButton(
                        child: Text("Pixel"),
                        onPressed: () {
                          setState(() {
                            mode = "Pixel";
                          });
                        },
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: TextButton(
                        child: Text("Percentage"),
                        onPressed: () {
                          setState(() {
                            mode = "Percentage";
                          });
                        },
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),

              Container(
                child: (mode == "Pixel") ? getPixel() : getPercentage(),
              ),

              SizedBox(
                height: 10,
              ),

              Container(
                child: Text("${files.length} Image selected"),
              ),


              Container(
                padding: EdgeInsets.only(top: 20),
                child: MaterialButton(
                  color: Colors.cyan,
                  child: Text(ButtonName),
                  onPressed: () async {
                    setState(() {
                      processedFile=0;
                    });
                    getResized();

                  },
                ),
              ),

              Container(
                padding: EdgeInsets.only(top: 40),
                child: (processedFile == -1)
                    ? Text("")
                    : (processedFile==files.length)
                    ? Text("All files successfully compressed")
                    : Text("Processing......."),
              ),

            ],
          ),
        ));
  }

  Widget getPixel() {
    ButtonName = "Start Resizing(${Width.toInt()} X ${Height.toInt()})";
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Row(
        children: [
          Expanded(
              flex: 2,
              child: Text(
                "Width : ",
                style: TextStyle(fontSize: 20),
              )),
          Expanded(
            flex: 2,
            child: TextField(
              controller: widthController,
              keyboardType: TextInputType.number,
              onChanged: (width) {
                setState(() {
                  print(width.toString());
                  Width = double.parse(width.toString());
                  ButtonName =
                      "Start Resizing(${Width.toInt()} X ${Height.toInt()})";
                  lastUpdate = "width";
                });
              },
            ),
          ),
          Expanded(
            child: SizedBox(
              width: 10,
            ),
          ),
          Expanded(
              flex: 2,
              child: Text("Height : ", style: TextStyle(fontSize: 20))),
          Expanded(
            flex: 2,
            child: TextField(
              controller: heightController,
              keyboardType: TextInputType.number,
              // onTap: ()=>FocusScope.of(context).requestFocus(new FocusNode()),
              onChanged: (height) {
                print(height);
                setState(() {
                  Height = double.parse(height.toString());
                  ButtonName =
                      "Start Resizing(${Width.toInt()} X ${Height.toInt()})";
                  lastUpdate = "height";
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget getPercentage() {
    ButtonName = "Start Resizing( ${percentage.toInt()}% )";
    return Row(
      children: [
        Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Text("${percentage.toInt()} %"),
            )),
        Expanded(
          flex: 7,
          child: Container(
            child: Slider(
              value: percentage,
              onChanged: (instantpercentage) {
                setState(() {
                  percentage = instantpercentage;
                  ButtonName =
                      "Start Resizing( ${instantpercentage.toInt()}% )";
                  lastUpdate = "percentage";
                });
              },
              min: 1,
              max: 100,
              divisions: 99,
              label: "${percentage.toInt()}%",
            ),
          ),
        )
      ],
    );
  }

  getResized() async {

    Directory dir = await getExternalStorageDirectory();

    print(dir.path);
    String newpath = "";
    List<String> folders = dir.path.split("/");
    for (int x = 1; x < folders.length; x++) {
      String folder = folders[x];
      if (folder != "Android") {
        newpath += "/" + folder;
      } else {
        break;
      }
    }

    newpath = newpath + "/IMG Lite/Resized_Images";
    dir = Directory(newpath);
    print(dir.path);

    if (await _requestPermission(Permission.storage)) {
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      if (await dir.exists()) {
        if (mode == "Percentage") {
          for (int i = 0; i < files.length; i++) {
            print("Percentage mode $i");
            var size = ImageSizeGetter.getSize(FileInput(files[i]));
            String filename = files[i].path.split("/").last;
            String extension = filename.split(".").last;
            // print(filename);
            // print(extension);
            double tempHight = (percentage * size.height) / 100;
            double tempWidth = (percentage * size.width) / 100;
            print(tempWidth);
            print(tempHight);
            var image = decodeImage(files[i].readAsBytesSync());
            var thumbnail = copyResize(image,
                width: tempWidth.toInt(), height: tempHight.toInt());
            File("${dir.path}/$filename").writeAsBytes((extension == "png")
                ? encodePng(thumbnail)
                : encodeJpg(thumbnail));
          }
          setState(() {
            processedFile=files.length;
          });
        } else {
          for (int i = 0; i < files.length; i++) {
            print("Pixel Mode $i");
            String filename = files[i].path.split("/").last;
            String extension = filename.split(".").last;
            // print(filename);
            // print(extension);

            var image = decodeImage(files[i].readAsBytesSync());
            var thumbnail =
            copyResize(image, width: Width.toInt(), height: Height.toInt());
            File("${dir.path}/$filename").writeAsBytes((extension == "png")
                ? encodePng(thumbnail)
                : encodeJpg(thumbnail));
          }
          setState(() {
            processedFile=files.length;
          });
        }
      }
    }



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
