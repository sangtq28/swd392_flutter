// import 'package:flutter/material.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'dart:convert';
// import 'package:audioplayers/audioplayers.dart';
// class Storytelling extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Ứng dụng Kể chuyện',
//       theme: ThemeData(
//         primarySwatch: Colors.purple,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//         fontFamily: 'Comic Sans MS',
//       ),
//       home: StoryListScreen(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }
//
// // Màn hình danh sách truyện
// class StoryListScreen extends StatefulWidget {
//   @override
//   _StoryListScreenState createState() => _StoryListScreenState();
// }
//
// class _StoryListScreenState extends State<StoryListScreen> {
//   List<Map<String, dynamic>> stories = [];
//
//   @override
//   void initState() {
//     super.initState();
//     loadStories();
//   }
//
//   Future<void> loadStories() async {
//     // Trong thực tế, bạn sẽ tải từ assets hoặc database
//     setState(() {
//       stories = [
//         {
//           'id': 1,
//           'title': 'Ba Chú Heo Con',
//           'coverImage': 'assets/images/three_pigs.png',
//           'ageGroup': '3-5',
//           'isFavorite': false,
//         },
//         {
//           'id': 2,
//           'title': 'Cô Bé Quàng Khăn Đỏ',
//           'coverImage': 'assets/images/red_riding_hood.png',
//           'ageGroup': '4-6',
//           'isFavorite': true,
//         },
//         {
//           'id': 3,
//           'title': 'Cô Bé Lọ Lem',
//           'coverImage': 'assets/images/cinderella.png',
//           'ageGroup': '5-7',
//           'isFavorite': false,
//         },
//       ];
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Câu Chuyện Cho Bé'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.favorite),
//             onPressed: () {
//               // Hiển thị truyện yêu thích
//             },
//           ),
//         ],
//       ),
//       body: stories.isEmpty
//           ? Center(child: CircularProgressIndicator())
//           : GridView.builder(
//         padding: EdgeInsets.all(16),
//         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           childAspectRatio: 0.75,
//           crossAxisSpacing: 16,
//           mainAxisSpacing: 16,
//         ),
//         itemCount: stories.length,
//         itemBuilder: (context, index) {
//           final story = stories[index];
//           return StoryCard(
//             story: story,
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => StoryDetailScreen(storyId: story['id']),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         child: Icon(Icons.filter_list),
//         onPressed: () {
//           // Hiển thị bộ lọc theo độ tuổi
//         },
//       ),
//     );
//   }
// }
//
// class StoryCard extends StatelessWidget {
//   final Map<String, dynamic> story;
//   final VoidCallback onTap;
//
//   const StoryCard({Key? key, required this.story, required this.onTap}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Card(
//         elevation: 5,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Expanded(
//               child: ClipRRect(
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
//                 child: Image.asset(
//                   'assets/images/placeholder.png', // Thay thế bằng story['coverImage'] khi có hình
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//             Padding(
//               padding: EdgeInsets.all(8),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     story['title'],
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                     ),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   SizedBox(height: 4),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Container(
//                         padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                         decoration: BoxDecoration(
//                           color: Colors.purple[100],
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: Text(
//                           '${story['ageGroup']} tuổi',
//                           style: TextStyle(fontSize: 12),
//                         ),
//                       ),
//                       Icon(
//                         story['isFavorite'] ? Icons.favorite : Icons.favorite_border,
//                         color: story['isFavorite'] ? Colors.red : Colors.grey,
//                         size: 20,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // Màn hình chi tiết truyện
// class StoryDetailScreen extends StatefulWidget {
//   final int storyId;
//
//   const StoryDetailScreen({Key? key, required this.storyId}) : super(key: key);
//
//   @override
//   _StoryDetailScreenState createState() => _StoryDetailScreenState();
// }
//
// class _StoryDetailScreenState extends State<StoryDetailScreen> {
//   late Map<String, dynamic> storyDetails;
//   int currentPage = 0;
//   final FlutterTts flutterTts = FlutterTts();
//   final AudioPlayer audioPlayer = AudioPlayer();
//   bool isReading = false;
//
//   @override
//   void initState() {
//     super.initState();
//     loadStoryDetails();
//     setupTts();
//   }
//
//   Future<void> setupTts() async {
//     await flutterTts.setLanguage('vi-VN');
//     await flutterTts.setSpeechRate(0.5); // Tốc độ đọc chậm hơn cho trẻ em
//     await flutterTts.setVolume(1.0);
//     await flutterTts.setPitch(1.0);
//
//     flutterTts.setCompletionHandler(() {
//       if (currentPage < storyDetails['pages'].length - 1) {
//         setState(() {
//           currentPage++;
//           readCurrentPage();
//         });
//       } else {
//         setState(() {
//           isReading = false;
//         });
//       }
//     });
//   }
//
//   void loadStoryDetails() {
//     // Trong thực tế, bạn sẽ tải từ assets hoặc database
//     storyDetails = {
//       'id': widget.storyId,
//       'title': 'Ba Chú Heo Con',
//       'author': 'Truyện cổ tích',
//       'pages': [
//         {
//           'text': 'Ngày xưa, có ba chú heo con sống cùng mẹ. Khi lớn lên, mẹ bảo các con hãy đi xây nhà riêng để tránh chó sói.',
//           'image': 'assets/images/three_pigs_1.png',
//         },
//         {
//           'text': 'Chú heo thứ nhất lười biếng nên xây nhà bằng rơm cho nhanh.',
//           'image': 'assets/images/three_pigs_2.png',
//         },
//         {
//           'text': 'Chú heo thứ hai chăm chỉ hơn một chút nên xây nhà bằng cây.',
//           'image': 'assets/images/three_pigs_3.png',
//         },
//         {
//           'text': 'Chú heo thứ ba rất chăm chỉ và cẩn thận nên xây nhà bằng gạch.',
//           'image': 'assets/images/three_pigs_4.png',
//         },
//         {
//           'text': 'Một ngày nọ, chó sói xuất hiện. Nó thổi bay ngôi nhà rơm của chú heo thứ nhất.',
//           'image': 'assets/images/three_pigs_5.png',
//         },
//       ],
//       'backgroundMusic': 'assets/audio/gentle_music.mp3',
//       'soundEffects': {
//         'wolf': 'assets/audio/wolf_howl.mp3',
//         'house_fall': 'assets/audio/crash.mp3',
//       },
//     };
//   }
//
//   void toggleReading() {
//     setState(() {
//       if (isReading) {
//         flutterTts.stop();
//         isReading = false;
//       } else {
//         isReading = true;
//         readCurrentPage();
//       }
//     });
//   }
//
//   void readCurrentPage() {
//     if (currentPage < storyDetails['pages'].length) {
//       flutterTts.speak(storyDetails['pages'][currentPage]['text']);
//     }
//   }
//
//   void nextPage() {
//     if (currentPage < storyDetails['pages'].length - 1) {
//       setState(() {
//         currentPage++;
//         if (isReading) {
//           flutterTts.stop();
//           readCurrentPage();
//         }
//       });
//     }
//   }
//
//   void previousPage() {
//     if (currentPage > 0) {
//       setState(() {
//         currentPage--;
//         if (isReading) {
//           flutterTts.stop();
//           readCurrentPage();
//         }
//       });
//     }
//   }
//
//   @override
//   void dispose() {
//     flutterTts.stop();
//     audioPlayer.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(storyDetails['title']),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.favorite_border),
//             onPressed: () {
//               // Thêm vào yêu thích
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: PageView.builder(
//               itemCount: storyDetails['pages'].length,
//               controller: PageController(initialPage: currentPage),
//               onPageChanged: (index) {
//                 setState(() {
//                   currentPage = index;
//                   if (isReading) {
//                     flutterTts.stop();
//                     readCurrentPage();
//                   }
//                 });
//               },
//               itemBuilder: (context, index) {
//                 final page = storyDetails['pages'][index];
//                 return Column(
//                   children: [
//                     Expanded(
//                       flex: 3,
//                       child: Container(
//                         margin: EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(15),
//                           boxShadow: [BoxShadow(
//                               color: Colors.black26, blurRadius: 5)
//                           ],
//                         ),
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(15),
//                           child: Image.asset(
//                             'assets/images/placeholder.png',
//                             // Thay thế bằng page['image'] khi có hình
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       flex: 2,
//                       child: Container(
//                         margin: EdgeInsets.all(16),
//                         padding: EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           color: Colors.purple[50],
//                           borderRadius: BorderRadius.circular(15),
//                           border: Border.all(color: Colors.purple[200]!),
//                         ),
//                         child: Center(
//                           child: Text(
//                             page['text'],
//                             style: TextStyle(
//                               fontSize: 18,
//                               height: 1.5,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: EdgeInsets.symmetric(
//                           horizontal: 16, vertical: 8),
//                       child: Text(
//                         'Trang ${index + 1}/${storyDetails['pages'].length}',
//                         style: TextStyle(color: Colors.grey),
//                       ),
//                     ),
//                   ],
//                 );
//               },
//             ),
//           ),
//           Container(
//             padding: EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//               boxShadow: [
//                 BoxShadow(
//                     color: Colors.black12, blurRadius: 5, offset: Offset(0, -2))
//               ],
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 IconButton(
//                   icon: Icon(Icons.arrow_back),
//                   onPressed: currentPage > 0 ? previousPage : null,
//                   color: Colors.purple,
//                 ),
//                 FloatingActionButton(
//                   onPressed: toggleReading,
//                   child: Icon(isReading ? Icons.pause : Icons.play_arrow),
//                   backgroundColor: Colors.purple,
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.arrow_forward),
//                   onPressed: currentPage < storyDetails['pages'].length - 1
//                       ? nextPage
//                       : null,
//                   color: Colors.purple,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
