// lib/util/article_item.dart
import 'package:flutter/material.dart';

class ArticleItem {
  final String title;
  final String subtitle;
  final String image;
  final Color bgColor;
  final String content;

  ArticleItem({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.bgColor,
    required this.content,
  });
}
