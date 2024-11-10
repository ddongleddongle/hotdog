class ProductClass {
  final String name;
  final int price;
  final double rating;
  final String imageURL;
  final double reviews;
  final double matchScore;
  final String description;

  ProductClass({
    required this.name,
    required this.price,
    required this.rating,
    required this.imageURL,
    required this.reviews, // 생성자에서 필수로 초기화
    required this.matchScore,
    required this.description,
  });

  factory ProductClass.fromJson(Map<String, dynamic> json) {
    return ProductClass(
      name: json['name'],
      price: json['price'],
      rating: json['rating'].toDouble(), // double로 변환
      imageURL: json['imageURL'],
      reviews: json['reviews'].toDouble(),
      matchScore: json['matchScore'].toDouble(),
      description: json['description'],
    );
  }
}
