import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:lottie/lottie.dart';

import '../services/background_music_player.dart';
import '../services/sound_effect_player.dart';

class StoryDetailScreen extends StatefulWidget {
  final int storyId;

  const StoryDetailScreen({Key? key, required this.storyId}) : super(key: key);

  @override
  _StoryDetailScreenState createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> with SingleTickerProviderStateMixin {
  late Map<String, dynamic> storyDetails;
  int currentPage = 0;
  final FlutterTts flutterTts = FlutterTts();
  final AudioPlayer audioPlayer = AudioPlayer();
  bool isReading = false;
  bool isDarkMode = false;
  late SoundEffectPlayer soundEffectPlayer;
  late BackgroundMusicPlayer backgroundMusicPlayer;
  late AnimationController _animationController;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    loadStoryDetails();
    setupTts();
    soundEffectPlayer = SoundEffectPlayer();
    backgroundMusicPlayer = BackgroundMusicPlayer();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Play background music when opening the screen
    if (storyDetails.containsKey('backgroundMusic')) {
      backgroundMusicPlayer.playMusic(storyDetails['backgroundMusic']);
    }
  }

  void playSoundEffect(String effectName) {
    if (storyDetails.containsKey('soundEffects') &&
        storyDetails['soundEffects'].containsKey(effectName)) {
      soundEffectPlayer.playEffect(storyDetails['soundEffects'][effectName]);
    }
  }

  Future<void> setupTts() async {
    await flutterTts.setLanguage('vi-VN');
    await flutterTts.setSpeechRate(0.5); // Slower reading pace for children
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);

    flutterTts.setCompletionHandler(() {
      if (currentPage < storyDetails['pages'].length - 1) {
        setState(() {
          currentPage++;
          _pageController.animateToPage(
            currentPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
          readCurrentPage();
        });
      } else {
        setState(() {
          isReading = false;
        });
      }
    });
  }

  void loadStoryDetails() {
    // In reality, you'll load from assets or database
    storyDetails = {
      'id': widget.storyId,
      'title': 'Ba Chú Heo Con',
      'author': 'Truyện cổ tích',
      'pages': [
        {
          'text': 'Các con giờ cũng đã lớn cả rồi, không còn bé bỏng như ngày xưa nữa. Giờ cũng là lúc ta cho các con ra đi và các con phải tự xây cho mỗi đứa một căn nhà',
          // 'image': 'assets/images/three_pigs_1.png',
          'effect': 'scene_change',
        },
      ],
      'backgroundMusic': 'assets/audio/gentle_music.mp3',
      'soundEffects': {
        'wolf': 'assets/audio/wolf_howl.mp3',
        'house_fall': 'assets/audio/crash.mp3',
        'scene_change': 'assets/audio/whoosh.mp3',
        'building': 'assets/audio/building.mp3',
      },
    };
  }

  void toggleReading() {
    setState(() {
      if (isReading) {
        flutterTts.stop();
        _animationController.reverse();
        isReading = false;
      } else {
        isReading = true;
        _animationController.forward();
        readCurrentPage();
      }
    });
  }

  void readCurrentPage() {
    if (currentPage < storyDetails['pages'].length) {
      flutterTts.speak(storyDetails['pages'][currentPage]['text']);

      // Play page-specific sound effect if available
      if (storyDetails['pages'][currentPage].containsKey('effect')) {
        playSoundEffect(storyDetails['pages'][currentPage]['effect']);
      }
    }
  }

  void nextPage() {
    if (currentPage < storyDetails['pages'].length - 1) {
      setState(() {
        currentPage++;
        _pageController.animateToPage(
          currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        if (isReading) {
          flutterTts.stop();
          readCurrentPage();
        }
      });
    }
  }

  void previousPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
        _pageController.animateToPage(
          currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        if (isReading) {
          flutterTts.stop();
          readCurrentPage();
        }
      });
    }
  }

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  void dispose() {
    flutterTts.stop();
    soundEffectPlayer.dispose();
    backgroundMusicPlayer.dispose();
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8F0E5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          color: isDarkMode ? Colors.white70 : Colors.black87,
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
            color: isDarkMode ? Colors.white70 : Colors.black87,
            onPressed: toggleTheme,
          ),
          IconButton(
            icon: const Icon(Icons.favorite_rounded),
            color: isDarkMode ? Colors.white70 : Colors.black87,
            onPressed: () {
              // Add to favorites with haptic feedback
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Animated background patterns
          Positioned.fill(
            child: Image.asset(
              isDarkMode ? 'assets/images/dark_pattern.png' : 'assets/images/light_pattern.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback background if image fails to load
                return Container(
                  color: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8F0E5),
                );
              },
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Story title with animation
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Text(
                    storyDetails['title'],
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                      height: 1.2,
                    ),
                  ).animate()
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: 0.2, end: 0, duration: 600.ms, curve: Curves.easeOutQuad),
                ),

                // Story content
                Expanded(
                  child: PageView.builder(
                    itemCount: storyDetails['pages'].length,
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() {
                        currentPage = index;
                        if (isReading) {
                          flutterTts.stop();
                          readCurrentPage();
                        }
                      });
                    },
                    itemBuilder: (context, index) {
                      final page = storyDetails['pages'][index];
                      return Column(
                        children: [
                          // Story image with 3D parallax effect
                          Expanded(
                            flex: 3,
                            child: Container(
                              margin: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: isDarkMode ? Colors.black38 : Colors.black12,
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  )
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Hero(
                                  tag: 'story_image_$index',
                                  child: Image.network(
                                    'https://truyencotich.vn/wp-content/uploads/2015/04/ba-chu-heo-con.jpeg', // Replace with page['image'] when available
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              ),
                            ),


                          // Story text with glassmorphism effect
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: GlassmorphicContainer(
                                width: double.infinity,
                                height: double.infinity,
                                borderRadius: 24,
                                blur: 20,
                                alignment: Alignment.center,
                                border: 1,
                                linearGradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: isDarkMode
                                      ? [
                                    Colors.white.withOpacity(0.1),
                                    Colors.white.withOpacity(0.05),
                                  ]
                                      : [
                                    Colors.white.withOpacity(0.7),
                                    Colors.white.withOpacity(0.4),
                                  ],
                                ),
                                borderGradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: isDarkMode
                                      ? [
                                    Colors.white.withOpacity(0.15),
                                    Colors.white.withOpacity(0.05),
                                  ]
                                      : [
                                    Colors.white.withOpacity(0.6),
                                    Colors.white.withOpacity(0.2),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Center(
                                    child: Text(
                                      page['text'],
                                      style: TextStyle(
                                        fontSize: 20,
                                        height: 1.6,
                                        color: isDarkMode ? Colors.white : Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Page indicator
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                storyDetails['pages'].length,
                                    (i) => Container(
                                  width: i == currentPage ? 24 : 8,
                                  height: 8,
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    color: i == currentPage
                                        ? (isDarkMode ? Colors.purple[300] : Colors.purple)
                                        : (isDarkMode ? Colors.grey[700] : Colors.grey[300]),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // Controls with interaction design
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.grey[850]!.withOpacity(0.7)
                        : Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode ? Colors.black26 : Colors.black12,
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Previous button
                      ElevatedButton(
                        onPressed: currentPage > 0 ? previousPage : null,
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(16),
                          backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                          elevation: 0,
                        ),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          color: currentPage > 0
                              ? (isDarkMode ? Colors.white70 : Colors.black54)
                              : Colors.grey,
                          size: 28,
                        ),
                      ),

                      // Play/pause button with animation
                      const SizedBox(width: 16),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isReading
                                ? [Colors.orange, Colors.deepPurple]
                                : [Colors.purple, Colors.deepPurple],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isReading ? Colors.deepPurple.withOpacity(0.4) : Colors.purple.withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            )
                          ],
                        ),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: toggleReading,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: AnimatedIcon(
                              icon: AnimatedIcons.play_pause,
                              progress: _animationController,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                      ),

                      // Next button
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: currentPage < storyDetails['pages'].length - 1 ? nextPage : null,
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(16),
                          backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                          elevation: 0,
                        ),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color: currentPage < storyDetails['pages'].length - 1
                              ? (isDarkMode ? Colors.white70 : Colors.black54)
                              : Colors.grey,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Interactive elements for immersive experience
          if (currentPage == 4) // Wolf page
            Positioned(
              bottom: 80,
              right: 30,
              child: GestureDetector(
                onTap: () => playSoundEffect('wolf'),
                // child: Lottie.asset(
                //   'assets/lottie/wolf.json',
                //   width: 120,
                //   height: 120,
                // ),
              ),
            ),
        ],
      ),
    );
  }
}