import 'package:audioplayers/audioplayers.dart';

class BackgroundMusicPlayer {
  final AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;

  Future<void> playMusic(String assetPath) async {
    if (!isPlaying) {
      await audioPlayer.play(AssetSource(assetPath));
      audioPlayer.setReleaseMode(ReleaseMode.loop);
      isPlaying = true;
    }
  }

  Future<void> pauseMusic() async {
    if (isPlaying) {
      await audioPlayer.pause();
      isPlaying = false;
    }
  }

  Future<void> resumeMusic() async {
    if (!isPlaying) {
      await audioPlayer.resume();
      isPlaying = true;
    }
  }

  void dispose() {
    audioPlayer.dispose();
    isPlaying = false;
  }
}