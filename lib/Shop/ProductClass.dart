class ProductClass {
  final String name;
  final double price;
  final double rating;
  final String imageURL;
  final double reviews;
  final double matchScore;

  ProductClass({
    required this.name,
    required this.price,
    required this.rating,
    required this.imageURL,
    required this.reviews, // 생성자에서 필수로 초기화
    required this.matchScore,
  });

  factory ProductClass.fromJson(Map<String, dynamic> json) {
    return ProductClass(
      name: json['name'],
      price: json['price'].toDouble(), // double로 변환
      rating: json['rating'].toDouble(), // double로 변환
      imageURL: json['imageURL'],
      reviews: json['reviews'].toDouble(),
      matchScore: json['matchScore'].toDouble(),
    );
  }
}
