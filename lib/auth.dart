import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'user_provider.dart';
import 'Siamese.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

final picker = ImagePicker();

// 애셋 이미지를 디바이스의 임시 디렉토리에 저장하는 함수
Future<String> copyAssetToFile() async {
  // 애셋 경로
  String assetPath = 'assets/images/pet.png';

  // 애셋을 ByteData로 읽어오기
  ByteData data = await rootBundle.load(assetPath);

  // 임시 디렉토리 경로 얻기
  final tempDir = await getTemporaryDirectory();

  // 파일 경로 설정
  final filePath = '${tempDir.path}/pet.png';

  // 파일에 데이터를 씀
  final file = File(filePath);
  await file.writeAsBytes(data.buffer.asUint8List());

  // 파일 경로 반환
  return filePath;
}

Future<bool> auth(BuildContext context) async {
  // 1. 새로 사진 찍기
  final XFile? image = await picker.pickImage(
    source: ImageSource.camera,
  );

  if (image == null) {
    print("사진 찍기 취소");
    return false;
  }

  // 2. 애셋 이미지를 파일로 저장하고 경로 가져오기
  String savedImagePath = await copyAssetToFile();

  // 3. 찍은 이미지와 저장된 이미지 비교
  File newImage1 = File(image.path);
  File newImage2 = File(image.path);
  File savedImage = File(savedImagePath);

  bool isSameAnimal = await verifyAnimal(savedImage, newImage1);

  if (isSameAnimal) {
    print("진짜~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    return true;
  } else {
    print("가짜~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    return false;
  }
}
