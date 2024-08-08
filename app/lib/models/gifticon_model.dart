import 'package:flutter/material.dart';

class Gifticon {
  final String imageUrl;
  final String storeName;
  final String productName;
  final String price;

  Gifticon({
    required this.imageUrl,
    required this.storeName,
    required this.productName,
    required this.price,
  });

  factory Gifticon.fromJson(Map<String, dynamic> json) {
    return Gifticon(
      imageUrl: json['imageUrl'],
      storeName: json['storeName'],
      productName: json['productName'],
      price: json['price'],
    );
  }
}
