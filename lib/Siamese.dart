import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

final picker = ImagePicker();

Future<bool> verifyAnimal(File image1, File image2) async {
  // TensorFlow Lite 모델 로드
  await Tflite.loadModel(model: "assets/siamese_model.tflite");

  // 첫 번째 이미지 예측
  var result1 = await Tflite.runModelOnImage(path: image1.path);
  var result2 = await Tflite.runModelOnImage(path: image2.path);

  // 두 이미지의 벡터 비교
  if (result1 != null && result2 != null) {
    // 예시: 두 이미지의 벡터를 비교 (보통 임베딩 벡터는 [0]에 저장됩니다)
    var vector1 = result1[0]['embedding']; // 첫 번째 이미지의 임베딩 벡터
    var vector2 = result2[0]['embedding']; // 두 번째 이미지의 임베딩 벡터

    // 벡터 유사도 계산 (예: 유클리드 거리 또는 코사인 유사도)
    double similarity = calculateSimilarity(vector1, vector2);

    // 유사도 계산 후 결과 출력
    if (similarity > 0.5) {
      return true;
    } else {
      return false;
    }
  } else {
    return false;
  }
}

double calculateSimilarity(List<double> vector1, List<double> vector2) {
  // 유클리드 거리 또는 코사인 유사도 계산
  double sum = 0.0;
  for (int i = 0; i < vector1.length; i++) {
    sum += (vector1[i] - vector2[i]) * (vector1[i] - vector2[i]);
  }
  return 1 / (1 + sum);  // 유클리드 거리 기반 유사도
}
