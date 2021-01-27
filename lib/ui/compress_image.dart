import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class compress_image extends StatefulWidget {
  FilePickerResult result;

  compress_image(this.result);

  @override
  _compress_imageState createState() => _compress_imageState(result);
}

class _compress_imageState extends State<compress_image> {
  FilePickerResult result;
  List<File> files;

  _compress_imageState(this.result);

  String mode = "Quality";
  double qualityIndex = 50;
  double sizeIndex = 500;
  double finalCompressQuality = 25;

  int processedFile = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      files = result.paths.map((path) => File(path)).toList();
    });
    print("/////////");
    print(files);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Compression Options'),
        ),
        body: Container(
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 50,
                child: Row(
                  children: [
                    Expanded(
                        flex: 4,
                        child: SizedBox(
                            width: 160,
                            child: Text("       Compression Mode"))),
                    Expanded(
                        flex: 2,
                        child: TextButton(
                          child: Text("Quality"),
                          autofocus: false,
                          onPressed: () {
                            setState(() {
                              mode = "Quality";
                            });
                          },
                        )),
                    Expanded(
                        flex: 2,
                        child: TextButton(
                          autofocus: true,
                          child: Text("Size"),
                          onPressed: () {
                            setState(() {
                              mode = "Size";
                            });
                          },
                        ))
                  ],
                ),
              ),
              Container(
                child: (mode == "Quality")
                    ? Text("Select Quality")
                    : Text("Select Size"),
              ),
              Container(
                child: Row(
                  children: [
                    (mode == "Quality")
                        ? Expanded(
                            flex: 2,
                            child: Container(
                                margin: EdgeInsets.only(left: 20),
                                child: Text(
                                  "${qualityIndex.toInt()} %",
                                  style: TextStyle(),
                                )))
                        : Expanded(
                            flex: 2,
                            child: Container(
                                margin: EdgeInsets.only(left: 20),
                                child: Text(
                                  "${sizeIndex.toInt()} KB",
                                  style: TextStyle(),
                                ))),
                    (mode == "Quality")
                        ? Expanded(flex: 8, child: getQualityIndex(context))
                        : Expanded(flex: 8, child: getSizeIndex(context))
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 30),
                child: Text("${files.length} Image Selected"),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                child: MaterialButton(
                  color: Colors.cyan,
                  padding:
                      EdgeInsets.only(left: 50, right: 50, top: 10, bottom: 10),
                  child: Text("Start Compression"),
                  onPressed: () async {
                    Directory dir =await getExternalStorageDirectory();

                    print(dir.path);
                    String newpath="";
                    List<String> folders=dir.path.split("/");
                    for(int x=1;x<folders.length;x++){
                      String folder=folders[x];
                      if(folder!="Android"){
                        newpath+="/"+folder;
                      }else{
                        break;
                      }
                    }

                    newpath=newpath+"/IMG Lite/Compressed_Images";
                    dir=Directory(newpath);
                    print(dir.path);

                    if(await _requestPermission(Permission.storage)) {
                      if (!await dir.exists()) {
                        await dir.create(recursive: true);
                      }

                      if(await dir.exists() ){

                        for (int photoNumber = 0;
                        photoNumber < files.length;
                        photoNumber++) {
                          setState(() {
                            processedFile = photoNumber + 1;
                          });
                          String photoName = files[photoNumber].toString().split("/").last;
                          String extensionName =
                              photoName.split(".").last.split("'").first;
                          CompressFormat customFormat =
                          getCompressFormat(extensionName);
                          print(photoName);
                          print(extensionName);
                          var result = await FlutterImageCompress.compressAndGetFile(
                              files[photoNumber].path,
                              "${dir.path}/${photoName.split(".").first}${"." + extensionName}",
                              format: customFormat,
                              quality: finalCompressQuality.toInt(),);
                        }


                      }

                    }






                  },
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 40),
                child: (processedFile == 0)
                    ? Text("")
                    : (processedFile == files.length)
                        ? Text("All files successfully compressed")
                        : Text("${processedFile} compressed file"),
              )
            ],
          ),
        ));
  }

  Widget getQualityIndex(BuildContext context) {
    return Slider(
      value: qualityIndex,
      onChangeEnd: (endQualityIndex) {
        setState(() {
          finalCompressQuality = endQualityIndex;
          print("final percentage ${finalCompressQuality}");
        });
      },
      onChanged: (newQualityIndex) {
        setState(() {
          qualityIndex = newQualityIndex;
        });
      },
      min: 1,
      max: 100,
      divisions: 99,
      label: "${qualityIndex.toInt()}",
    );
  }

  Widget getSizeIndex(BuildContext context) {
    return Slider(
      value: sizeIndex,
      onChangeEnd: (endSizeIndex) {
        endSizeIndex = endSizeIndex * 1024;
        double lastIndex = (endSizeIndex * 100) / files[0].lengthSync();
        setState(() {
          finalCompressQuality = lastIndex;
          print("final percentage ${finalCompressQuality}");
        });
      },
      onChanged: (newSizeIndex) {
        setState(() {
          sizeIndex = newSizeIndex;
        });
      },
      min: 1,
      max: 1024,
      divisions: 1023,
      label: "${sizeIndex.toInt()}",
    );
  }

  CompressFormat getCompressFormat(String extension) {
    if (extension == "png") {
      return CompressFormat.png;
    } else if (extension == 'webp') {
      return CompressFormat.webp;
    } else if (extension == 'heic') {
      return CompressFormat.heic;
    } else {
      return CompressFormat.jpeg;
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
