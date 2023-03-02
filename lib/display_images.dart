import 'dart:io';
import 'package:flutter/material.dart';

class ImageListPage extends StatelessWidget {
  final String folderPath = "D:/Backgrounds";

  const ImageListPage({super.key}); // Replace with your folder path

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image List"),
      ),
      body: FutureBuilder(
        future: getImagesFromFolder(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<File> imageFiles = snapshot.data as List<File>;
            return ListView.builder(
              itemCount: imageFiles.length,
              itemBuilder: (context, index) {
                return Image.file(imageFiles[index], width: 100, height: 100,);
              },
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Future<List<File>> getImagesFromFolder() async {
    final folder = Directory(folderPath);
    List<File> imageFiles = [];
    await for (var file in folder.list()) {
      if (file is File && file.path.endsWith(".jpg")) { // Replace with your image extension
        imageFiles.add(file);
      }
    }
    return imageFiles;
  }
}
