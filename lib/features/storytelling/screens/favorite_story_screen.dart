import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swd392/features/storytelling/screens/story_detail_screen.dart';

class FavoriteStoriesScreen extends StatefulWidget {
  @override
  _FavoriteStoriesScreenState createState() => _FavoriteStoriesScreenState();
}

class _FavoriteStoriesScreenState extends State<FavoriteStoriesScreen> {
  List<Map<String, dynamic>> favoriteStories = [];

  @override
  void initState() {
    super.initState();
    loadFavoriteStories();
  }

  void loadFavoriteStories() {
    // Trong thực tế, bạn sẽ lấy từ local storage hoặc database
    setState(() {
      favoriteStories = [
        {
          'id': 2,
          'title': 'Cô Bé Quàng Khăn Đỏ',
          'coverImage': 'assets/images/red_riding_hood.png',
          'ageGroup': '4-6',
          'isFavorite': true,
        },
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Truyện Yêu Thích'),
      ),
      body: favoriteStories.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Chưa có truyện yêu thích',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: favoriteStories.length,
        itemBuilder: (context, index) {
          final story = favoriteStories[index];
          return Card(
            margin: EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 4,
            child: ListTile(
              contentPadding: EdgeInsets.all(8),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/placeholder.png',
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(story['title'], style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${story['ageGroup']} tuổi'),
              trailing: IconButton(
                icon: Icon(Icons.favorite, color: Colors.red),
                onPressed: () {
                  // Xóa khỏi danh sách yêu thích
                  setState(() {
                    favoriteStories.removeAt(index);
                  });
                },
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StoryDetailScreen(storyId: story['id']),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}