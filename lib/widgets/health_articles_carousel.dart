// HealthArticlesCarousel - widget carosello nella home
import 'package:flutter/material.dart';
import 'package:medicare_app/theme/text_styles.dart';
import 'package:medicare_app/pages/articles/articles_page.dart';
import 'package:medicare_app/pages/articles/article_detail_page.dart';
import 'package:medicare_app/util/article_item.dart';

class HealthArticlesCarousel extends StatefulWidget {
  const HealthArticlesCarousel({super.key});

  @override
  State<HealthArticlesCarousel> createState() => _HealthArticlesCarouselState();
}

class _HealthArticlesCarouselState extends State<HealthArticlesCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.85);

  final List<ArticleItem> articles = [
    ArticleItem(
      title: " 🔅 Summer & Health",
      subtitle: "Useful tips to face the summer weather.",
      image: 'assets/illustrations/summer_health.png',
      bgColor: Colors.red.shade100,
      content: '''
High temperatures and strong sunlight can put stress on your body, especially during the summer months. Here are a few essential tips to stay safe and healthy:

Stay hydrated by drinking plenty of water throughout the day. Avoid sugary and alcoholic drinks, which can increase dehydration. When outdoors, try to stay in shaded areas and wear light, breathable clothing.

Use sunscreen with at least SPF 30 and reapply regularly, especially after sweating or swimming. Sunglasses and hats can also protect your eyes and skin.

Limit physical activity during the hottest hours of the day, typically between 11 a.m. and 4 p.m. If exercising, do it early in the morning or late in the evening.

If you experience symptoms like dizziness, fatigue, or excessive sweating, take a break immediately. Prioritize fresh meals, fruits, and vegetables that help replenish lost minerals.

Small habits can prevent big problems. Enjoy your summer responsibly!
''',
    ),
    ArticleItem(
      title: " 💙 Your Heart Counts",
      subtitle: "How to keep your heart strong and healthy.",
      image: 'assets/illustrations/heart_health.png',
      bgColor: Colors.blue.shade100,
      content: '''
Your heart is the engine of your body, and caring for it should be a top priority at every stage of life.

Start by building heart-friendly habits. Incorporate regular physical activity into your routine—aim for at least 30 minutes of walking, cycling, or swimming most days of the week. Avoid a sedentary lifestyle and take active breaks during work or study.

Diet also plays a huge role. Limit processed foods, reduce salt and sugar intake, and include more vegetables, whole grains, and healthy fats (like olive oil, nuts, and fish).

Manage stress through mindfulness, sleep, and time spent with loved ones. Chronic stress can affect your blood pressure and heart rhythm.

And of course, keep regular medical checkups, especially if you have risk factors like high blood pressure, diabetes, or family history of heart disease.

Healthy heart, healthy life!
''',
    ),
    ArticleItem(
      title: "💉 Take Care of Your Diabetes",
      subtitle: "Daily life tips for managing diabetes.",
      image: 'assets/illustrations/diabetes.png',
      bgColor: Colors.green.shade100,
      content: '''
Living with diabetes requires consistency, awareness, and balance—but with good habits, it becomes part of a healthy lifestyle.

Start by monitoring your blood sugar levels regularly. This helps you understand how food, activity, and insulin affect your body. Stick to a meal plan that suits your insulin needs, with balanced portions and a focus on low-glycemic index foods.

Physical activity is a key ally. Even a 30-minute walk a day can improve insulin sensitivity. Be aware of signs of hypo- or hyperglycemia and always keep emergency carbohydrates with you.

Take care of your feet, eyes, and dental health, as these can be affected by long-term glucose imbalance. Schedule routine medical visits and screenings.

Finally, don't forget mental well-being. Living with a chronic condition can be emotionally tiring. Share your concerns with family or support groups, and seek help when needed.

You’re not defined by diabetes—you’re in control of it.
''',
    ),
    ArticleItem(
      title: "🧠 Study and Work Stress",
      subtitle: "Tips on how to manage it.",
      image: 'assets/illustrations/stress.png',
      bgColor: Colors.purple.shade100,
      content:
          '''Feeling overwhelmed by deadlines, exams, or work responsibilities is common—especially in today's fast-paced world. Whether you're a student or a professional (or both!), learning to manage stress is essential for your health and productivity.

🔍 Recognize the Signs

Stress often builds up slowly. Some signs include:

Constant fatigue or trouble sleeping

Difficulty concentrating

Mood swings or irritability

Physical symptoms like headaches or stomachaches

The first step to managing stress is identifying it early.

📋 Organize, Don't Overload

Create a realistic schedule and break large tasks into smaller, manageable ones. Use planners or digital calendars to track assignments, meetings, or study sessions. Prioritize what's urgent and what can wait.

Avoid multitasking—focus on one thing at a time. You'll work more efficiently and reduce mental overload.

🧘‍♀️ Take Care of Your Mind and Body

Stress management starts with physical well-being:

Sleep: Aim for 7 or 8 hours per night.

Nutrition: Eat balanced meals and stay hydrated.

Exercise: Even 15 minutes of walking can reduce stress hormones.

Incorporate mindfulness techniques like deep breathing, meditation, or yoga into your daily routine. These can calm your nervous system and improve focus.

💬 Don't Go Through It Alone

Talk to someone—a friend, family member, or mentor. Expressing your worries can lighten the load and help you gain perspective.

If you're struggling to cope, don't hesitate to speak with a counselor or mental health professional.

🎯 Set Boundaries and Rest

Burnout happens when we push beyond our limits. Know when to say no and allow time for breaks, hobbies, or even doing nothing. Disconnect from screens and find time to recharge—guilt-free.

✨ Final Thought

Stress is part of life—but it shouldn't take over. With small changes in your habits, mindset, and self-care, you can regain control and thrive, both in your studies and at work.''',
    ),

    ArticleItem(
      title: " 🤱🏾 Maternity",
      subtitle: "Tips for a healthy and balanced pregnancy journey.",
      image: 'assets/illustrations/maternity.png',
      bgColor: Colors.pink.shade50,
      content: '''
Pregnancy is a transformative and delicate period in a woman's life. Taking care of both your body and mind is essential to support the health of both mother and baby.

Start by maintaining regular check-ups with your doctor to monitor progress and address any concerns early. Nutrition plays a crucial role—opt for a balanced diet rich in folic acid, iron, calcium, and proteins. Stay hydrated and avoid harmful substances like alcohol, tobacco, and excessive caffeine.

Physical activity can also help—gentle exercises like walking, prenatal yoga, or swimming can improve mood, reduce swelling, and support better sleep. Don’t underestimate the importance of rest; your body is doing important work every day.

Lastly, mental health matters. It's normal to experience emotional ups and downs. Connect with your support system, communicate your needs, and consider speaking to a professional if you feel overwhelmed.

Taking small steps every day makes a big difference. Pregnancy is a journey—make it a healthy one.
''',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Articles for You',
                style: AppTextStyles.buttons(color: Colors.deepPurple),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ArticlesPage(articleList: articles),
                    ),
                  );
                },
                child: Text(
                  'See all',
                  style: AppTextStyles.link(color: Colors.deepPurple),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 250,
          child: PageView.builder(
            controller: _pageController,
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: GestureDetector(
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ArticleDetailPage(article: article),
                        ),
                      ),
                  child: Container(
                    width: screenWidth * 0.85,
                    decoration: BoxDecoration(
                      color: article.bgColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Center(
                            child: Image.asset(
                              article.image,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
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
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
