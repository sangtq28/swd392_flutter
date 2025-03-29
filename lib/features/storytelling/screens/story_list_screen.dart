// Màn hình danh sách truyện
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swd392/features/storytelling/screens/story_detail_screen.dart';

import '../../../screens/story_telling.dart';
import '../widgets/story_card.dart';

class StoryListScreen extends StatefulWidget {
  @override
  _StoryListScreenState createState() => _StoryListScreenState();
}

class _StoryListScreenState extends State<StoryListScreen> {
  List<Map<String, dynamic>> stories = [];

  @override
  void initState() {
    super.initState();
    loadStories();
  }

  Future<void> loadStories() async {
    // Trong thực tế, bạn sẽ tải từ assets hoặc database
    setState(() {
      stories = [
        {
          'id': 1,
          'title': 'Ba Chú Heo Con',
          'coverImage': 'https://truyencotich.vn/wp-content/uploads/2015/04/ba-chu-heo-con.jpeg',
          'ageGroup': '3-5',
          'isFavorite': true,
        },
        {
          'id': 2,
          'title': 'Cô Bé Quàng Khăn Đỏ',
          'coverImage': 'https://th.bing.com/th/id/OIP.ChN5nD6RZFilhGDz09JTkwHaEK?rs=1&pid=ImgDetMain',
          'ageGroup': '3-5',
          'isFavorite': true,
        },

      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Câu Chuyện Cho Bé'),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () {
              // Hiển thị truyện yêu thích
            },
          ),
        ],
      ),
      body: stories.isEmpty
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: stories.length,
        itemBuilder: (context, index) {
          final story = stories[index];
          return StoryCard(
            story: story,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StoryDetailScreen(storyId: story['id']),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.filter_list),
        onPressed: () {
          // Hiển thị bộ lọc theo độ tuổi
        },
      ),
    );
  }
}