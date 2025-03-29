import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double speechRate = 0.5;
  double pitch = 1.0;
  bool enableSoundEffects = true;
  bool enableBackgroundMusic = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cài đặt'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Âm thanh', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  SizedBox(height: 16),
                  Text('Tốc độ đọc'),
                  Slider(
                    value: speechRate,
                    min: 0.1,
                    max: 1.0,
                    divisions: 9,
                    label: '${(speechRate * 10).round() / 10}',
                    onChanged: (value) {
                      setState(() {
                        speechRate = value;
                      });
                    },
                  ),
                  Text('Âm giọng'),
                  Slider(
                    value: pitch,
                    min: 0.5,
                    max: 2.0,
                    divisions: 15,
                    label: '${(pitch * 10).round() / 10}',
                    onChanged: (value) {
                      setState(() {
                        pitch = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: Text('Hiệu ứng âm thanh'),
                    value: enableSoundEffects,
                    onChanged: (value) {
                      setState(() {
                        enableSoundEffects = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: Text('Nhạc nền'),
                    value: enableBackgroundMusic,
                    onChanged: (value) {
                      setState(() {
                        enableBackgroundMusic = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Lưu cài đặt
              Navigator.pop(context);
            },
            child: Text('Lưu cài đặt'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}