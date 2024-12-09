import os
import urllib.request
import tarfile
import glob
import tensorflow as tf
import numpy as np
import random
from tensorflow.keras.preprocessing import image
from tensorflow.keras.preprocessing.image import img_to_array
from tensorflow.keras import layers, models

# Oxford Pets 데이터셋 다운로드 함수
def download_oxford_pets_dataset(download_dir='./oxford_pets'):
    if not os.path.exists(download_dir):
        os.makedirs(download_dir)

    dataset_url = "http://www.robots.ox.ac.uk/~vgg/data/pets/data/images.tar.gz"
    tar_path = os.path.join(download_dir, "images.tar.gz")

    # 데이터셋 다운로드
    if not os.path.exists(tar_path):
        print("Downloading Oxford Pets dataset...")
        urllib.request.urlretrieve(dataset_url, tar_path)
        print("Download complete.")

    # 압축 해제
    if not os.path.exists(os.path.join(download_dir, 'images')):
        print("Extracting dataset...")
        with tarfile.open(tar_path, 'r:gz') as tar_ref:
            tar_ref.extractall(download_dir)
        print("Extraction complete.")

# 데이터셋 다운로드
download_oxford_pets_dataset()

# 이미지 전처리 함수 (배치 차원 추가)
def preprocess_image(img_path, target_size=(128, 128)):
    img = image.load_img(img_path, target_size=target_size)
    img = img_to_array(img)
    img = img / 255.0  # Normalize
    img = np.expand_dims(img, axis=0)  # 배치 차원 추가
    return img

# 데이터 로드 및 클래스별로 이미지 분류 함수
def load_data(image_folder, image_size=(128, 128)):
    image_paths = glob.glob(os.path.join(image_folder, "*.jpg"))
    class_images_dict = {}  # 클래스별 이미지를 저장할 딕셔너리

    # 각 이미지 파일과 레이블을 처리
    for img_path in image_paths:
        # 이미지 로드
        img = preprocess_image(img_path, target_size=image_size)

        # 파일명에서 동물 종류 추출 (예: 'cat_01.jpg' -> 'cat')
        class_name = img_path.split(os.sep)[-1].split('_')[0]

        # 해당 클래스를 딕셔너리에 추가
        if class_name not in class_images_dict:
            class_images_dict[class_name] = []

        class_images_dict[class_name].append(img)  # 해당 클래스에 이미지 추가

    # 클래스별로 이미지를 numpy 배열로 변환
    for class_name in class_images_dict:
        class_images_dict[class_name] = np.array(class_images_dict[class_name])

    return class_images_dict

# 데이터 로드
image_folder = './oxford_pets/images'  # 이미지가 있는 폴더 경로
class_images_dict = load_data(image_folder)

# 긍정적(같은 동물) 이미지 쌍 생성 함수
def create_positive_pair():
    # 클래스에서 랜덤하게 하나를 선택
    class_name = random.choice(list(class_images_dict.keys()))  # 클래스 중 하나 선택

    # 해당 클래스에서 랜덤하게 두 이미지를 선택
    class_images = class_images_dict[class_name]
    img1, img2 = random.sample(class_images.tolist(), 2)  # 랜덤으로 두 이미지 선택

    return img1, img2, 1  # 라벨 1은 같은 동물

# 부정적(다른 동물) 이미지 쌍 생성 함수
def create_negative_pair():
    # 두 개의 서로 다른 클래스를 랜덤하게 선택
    class1, class2 = random.sample(list(class_images_dict.keys()), 2)

    # 각 클래스에서 랜덤하게 이미지를 하나씩 선택
    img1 = random.choice(class_images_dict[class1])
    img2 = random.choice(class_images_dict[class2])

    return img1, img2, 0  # 라벨 0은 다른 동물

# Siamese 네트워크용 이미지 쌍 생성 함수
def generate_pairs(batch_size = 32):
    while True:
        pair_images = []
        pair_labels = []
        for _ in range(batch_size):
            if random.random() > 0.5:  # 긍정적 쌍과 부정적 쌍을 반반으로 생성
                img1, img2, label = create_positive_pair()
            else:
                img1, img2, label = create_negative_pair()

            pair_images.append([img1, img2])
            pair_labels.append(label)

        pair_images = np.array(pair_images)  # (batch_size, 2, 128, 128, 3)
        pair_labels = np.array(pair_labels)

        # tf.Tensor로 변환하여 반환
        pair_images = tf.convert_to_tensor(pair_images, dtype=tf.float32)
        pair_labels = tf.convert_to_tensor(pair_labels, dtype=tf.int32)

        # (batch_size, 2, 128, 128, 3) 형태로 배치 반환
        yield ((tf.squeeze(pair_images[:, 0], axis=1), tf.squeeze(pair_images[:, 1], axis=1)), pair_labels)

# Siamese 네트워크 모델 정의
def create_siamese_model(input_shape):
    input1 = layers.Input(shape=input_shape)  # 첫 번째 이미지 입력
    input2 = layers.Input(shape=input_shape)  # 두 번째 이미지 입력

    # 기본 CNN 네트워크 (feature extractor)
    def create_feature_extractor(input_tensor):
        x = layers.Conv2D(32, (3, 3), activation='relu')(input_tensor)
        x = layers.MaxPooling2D((2, 2))(x)
        x = layers.Conv2D(64, (3, 3), activation='relu')(x)
        x = layers.MaxPooling2D((2, 2))(x)
        x = layers.Flatten()(x)
        x = layers.Dense(128, activation='relu')(x)
        return x

    # 동일한 feature extractor를 두 입력에 각각 적용
    x1 = create_feature_extractor(input1)
    x2 = create_feature_extractor(input2)

    # 두 출력 간의 차이를 계산 (L1 거리)
    distance = layers.Lambda(lambda tensors: tf.abs(tensors[0] - tensors[1]))([x1, x2])

    # 차이를 기반으로 유사도를 출력 (0 또는 1)
    output = layers.Dense(1, activation='sigmoid')(distance)

    model = models.Model(inputs=(input1, input2), outputs=output)
    model.compile(loss='binary_crossentropy', optimizer='adam', metrics=['accuracy'])

    return model

train_data = tf.data.Dataset.from_generator(
    generate_pairs,  # 배치 데이터를 생성하는 함수
    args=[32],  # 배치 크기 및 추가 인자
    output_signature=(
        (tf.TensorSpec(shape=(32, 128, 128, 3), dtype=tf.float32), tf.TensorSpec(shape=(32, 128, 128, 3), dtype=tf.float32)),
        tf.TensorSpec(shape=(32,), dtype=tf.int32)
    )
)

# 모델 훈련
input_shape = ((128, 128, 3))
siamese_model = create_siamese_model(input_shape)
siamese_model.fit(train_data, steps_per_epoch=10, epochs=5)

converter = tf.lite.TFLiteConverter.from_keras_model(siamese_model)
tflite_model = converter.convert()

# 변환된 TFLite 모델을 파일로 저장
with open('siamese_model.tflite', 'wb') as f:
    f.write(tflite_model)
