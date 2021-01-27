import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:img_lite/ui/compress_image.dart';
import 'package:img_lite/ui/cropped_image.dart';
import 'package:img_lite/ui/resize_image.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IMG Lite',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: MyHomePage(title: 'IMG Lite'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double rating = 8.0;
  File _image;
  final picker = ImagePicker();

  Future<File> testCompressAndGetFile(File file, String targetPath) async {
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 88,
      rotate: 180,
    );

    // print(file.lengthSync());
    // print(result.lengthSync());

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
                flex: 2,
                child: Container(
                  color: Colors.greenAccent,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Icon(
                          Icons.compress,
                          size: 70,
                        ),
                      ),
                      Expanded(
                          flex: 6,
                          child: TextButton(
                            child: Text(
                              "Compress Image",
                              style: TextStyle(fontSize: 30,color: Colors.black),
                            ),
                            onPressed: () async {
                              // Directory dir=await getExternalStorageDirectory();
                              FilePickerResult result = await FilePicker.platform
                                  .pickFiles(
                                      type: FileType.image, allowMultiple: true);
                              // print(result);

                              if (result != null) {
                                // print(dir.path);
                                // List<File> files = result.paths.map((path) => File(path)).toList();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            compress_image(result)));
                              } else {
                                // User canceled the picker
                                print("No file selected");
                              }
                            },
                          )),
                    ],
                  ),
                )),
            Expanded(
                flex: 2,
                child: Container(
                    color: Colors.white,
                    child: Container(
                      color: Colors.lightBlueAccent,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Icon(
                              Icons.crop,
                              size: 70,
                            ),
                          ),
                          Expanded(
                            flex: 6,
                            child: TextButton(
                              child: Text(
                                "Crop Image",
                                style: TextStyle(
                                    fontSize: 30, color: Colors.black),
                              ),
                              onPressed: () {
                                getImage();
                              },
                            ),
                          )
                        ],
                      ),
                    ))),
            Expanded(
                flex: 2,
                child: Container(
                  color: Colors.greenAccent,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Icon(Icons.photo_size_select_large,size: 70,),
                      ),

                      Expanded(
                        flex: 6,
                        child: TextButton(
                          child: Text("Resize Image",style: TextStyle(fontSize:30,color: Colors.black),),
                          onPressed: ()async{
                            FilePickerResult result = await FilePicker.platform
                                .pickFiles(
                                type: FileType.image, allowMultiple: true);
                            // print(result);

                            if (result != null) {
                              // print(dir.path);
                              // List<File> files = result.paths.map((path) => File(path)).toList();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          resize_image(result)));
                            } else {
                              // User canceled the picker
                              print("No file selected");
                            }


                          },
                        ),
                      )

                    ],
                  )
                ))
          ],
        ),
      ),
    );
  }

  Future getImage() async {
    final pickedFile = await picker.getImage(
      source: ImageSource.gallery,
    );

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        getCropprdFile(File(pickedFile.path));
      } else {
        print('No image selected.');
      }
    });
  }

  Future getCropprdFile(File pickedfile) async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: pickedfile.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        ));

    if(croppedFile!=null){
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => cropped_image(croppedFile)));
    }

    // Directory dir=await getExternalStorageDirectory();
    // final myfinalPath=await '${dir.path}/MyImages';
    // final myImgDir = await new Directory(myfinalPath).create();
    // print(dir.path);
    // croppedFile.copy("${myfinalPath}/img.jpg");

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

    newpath = newpath + "/IMG Lite/Cropped_Images";
    dir = Directory(newpath);
    if (await _requestPermission(Permission.storage)) {
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      print("/////");
      print(croppedFile.path);

      if (await dir.exists()) {
        croppedFile.copy("${dir.path}/${pickedfile.path.split("/").last}");
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
