import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'user_provider.dart';
import 'Siamese.dart';

final picker = ImagePicker();

Future<bool> auth(BuildContext context) async {
  // 1. 새로 사진 찍기
  final XFile? image = await picker.pickImage(source: ImageSource.camera);

  if (image == null) {
    print("사진 찍기 취소");
    return false;
  }

  // final userProvider = Provider.of<UserProvider>(context, listen: false);
  // String? savedImagePath = image.path;
  // //userProvider.imagePath;
  //
  // if (savedImagePath == null) {
  //   print("저장된 이미지가 없습니다.");
  //   return false;
  // }

  // 3. 저장된 이미지와 찍은 이미지를 비교
  File newImage1 = File(image.path);
  File newImage2 = File(image.path);
  // File savedImage = File(savedImagePath);

  bool isSameAnimal = await verifyAnimal(newImage1, newImage2);

  if (isSameAnimal) {
    return true;
  } else {
    return false;
  }
}