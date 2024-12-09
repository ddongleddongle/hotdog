import 'dart:io';
import 'dart:math';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';

final picker = ImagePicker();

// verifyAnimal 함수는 두 이미지의 유사도를 계산
Future<bool> verifyAnimal(File image1, File image2) async {
  // TensorFlow Lite 모델 로드
  Interpreter? interpreter;
  try {
    interpreter = await Interpreter.fromAsset('assets/siamese_model.tflite');
    print('모델 로딩 완료!');
  } catch (e) {
    print('모델 로딩 실패: $e');
    return false; // 모델 로딩 실패 시 false 반환
  }

  double _similarity = 0.0;

  // 이미지를 TensorFlow Lite 모델에 맞는 포맷으로 변환
  Future<List<double>> _preprocessImage(File image) async {
    img.Image? imageFile = img.decodeImage(image.readAsBytesSync());
    imageFile = img.copyResize(imageFile!, width: 128, height: 128);  // 모델에 맞는 크기로 리사이즈

    // RGBA에서 RGB로 변환
    List<int> rgbBytes = [];
    for (int i = 0; i < imageFile.length; i++) {
      int pixel = imageFile.getPixel(i % 128, i ~/ 128);
      rgbBytes.add(img.getRed(pixel));   // R
      rgbBytes.add(img.getGreen(pixel)); // G
      rgbBytes.add(img.getBlue(pixel));  // B
    }

    // Uint8List를 List<double>로 변환하고 정규화
    List<double> floatList = rgbBytes.map((byte) => byte.toDouble() / 255.0).toList(); // 정규화
    return floatList;
  }

  // 유사성 예측
  Future<void> _predictSimilarity(File image1, File image2) async {
    var img1Bytes = await _preprocessImage(image1);
    var img2Bytes = await _preprocessImage(image2);

    // 두 이미지를 하나의 입력으로 결합
    var combinedInput = Float32List.fromList([...img1Bytes, ...img2Bytes]).reshape([1, 128, 128, 6]); // (1, height, width, channels*2)

    // 모델에 예측 요청
    var output = List.filled(1, List.filled(1, 0.0)); // 출력 초기화

    interpreter?.run(combinedInput, output); // 두 이미지 결합된 입력으로 예측

    // 유사도 계산
    _similarity = output[0][0] ;
    print("두 이미지의 유사도: ${_similarity}"); // 소수점 3자리까지 출력
    //${_similarity.toStringAsFixed(3)}
  }

  await _predictSimilarity(image1, image2);

  // 유사도 계산 후 결과 출력
  if (_similarity > 0.5) {
    print('두 이미지가 동일한 동물입니다.');
    return true;
  } else if (_similarity == 0) {
    print('이미지 분석 실패.');
    return false;
  } else {
    print('두 이미지가 다른 동물입니다.');
    return false;
  }
}
