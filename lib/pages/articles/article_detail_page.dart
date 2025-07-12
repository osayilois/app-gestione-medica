// article_detail_page.dart
import 'package:flutter/material.dart';
import 'package:medicare_app/theme/text_styles.dart';
import 'package:medicare_app/util/article_item.dart';

class ArticleDetailPage extends StatelessWidget {
  final ArticleItem article;

  const ArticleDetailPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.deepPurple),
        title: Text(
          article.title,
          style: AppTextStyles.title2(color: Colors.deepPurple),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: article.bgColor,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Image.asset(
                  article.image,
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              article.title,
              style: AppTextStyles.title1(color: Colors.black),
            ),
            const SizedBox(height: 8),
            Text(
              article.subtitle,
              style: AppTextStyles.subtitle(color: Colors.grey[800]!),
            ),
            const SizedBox(height: 20),
            Text(
              article.content,
              style: AppTextStyles.body(color: Colors.black),
              textAlign: TextAlign.left,
            ),
          ],
        ),
      ),
    );
  }
}
