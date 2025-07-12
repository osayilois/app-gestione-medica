// articles_page.dart
import 'package:flutter/material.dart';
import 'package:medicare_app/theme/text_styles.dart';
import 'package:medicare_app/pages/articles/article_detail_page.dart';
import 'package:medicare_app/util/article_item.dart';

class ArticlesPage extends StatelessWidget {
  final List<ArticleItem> articleList;

  const ArticlesPage({super.key, required this.articleList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Health Articles',
          style: AppTextStyles.title1(color: Colors.deepPurple),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.deepPurple),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: articleList.length,
        itemBuilder: (context, index) {
          final article = articleList[index];
          return GestureDetector(
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ArticleDetailPage(article: article),
                  ),
                ),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: article.bgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Image.asset(
                    article.image,
                    height: 60,
                    width: 60,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article.title,
                          style: AppTextStyles.buttons(color: Colors.black),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          article.subtitle,
                          style: AppTextStyles.body(color: Colors.grey[800]!),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
