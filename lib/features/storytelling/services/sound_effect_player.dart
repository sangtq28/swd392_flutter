import 'package:audioplayers/audioplayers.dart';

class SoundEffectPlayer {
  final AudioPlayer audioPlayer = AudioPlayer();

  Future<void> playEffect(String assetPath) async {
    await audioPlayer.play(AssetSource(assetPath));
  }

  void dispose() {
    audioPlayer.dispose();
  }
}