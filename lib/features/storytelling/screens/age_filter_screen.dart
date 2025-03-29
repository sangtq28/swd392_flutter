// Màn hình lọc truyện theo độ tuổi
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AgeFilterScreen extends StatefulWidget {
  @override
  _AgeFilterScreenState createState() => _AgeFilterScreenState();
}

class _AgeFilterScreenState extends State<AgeFilterScreen> {
  RangeValues currentRangeValues = RangeValues(3, 7);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lọc Theo Độ Tuổi'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chọn độ tuổi phù hợp',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            RangeSlider(
              values: currentRangeValues,
              min: 0,
              max: 12,
              divisions: 12,
              labels: RangeLabels(
                currentRangeValues.start.round().toString(),
                currentRangeValues.end.round().toString(),
              ),
              onChanged: (RangeValues values) {
                setState(() {
                  currentRangeValues = values;
                });
              },
            ),
            SizedBox(height: 16),
            Text(
              'Độ tuổi đã chọn: ${currentRangeValues.start.round()} - ${currentRangeValues.end.round()} tuổi',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Áp dụng bộ lọc và quay lại màn hình danh sách
                Navigator.pop(context, {
                  'minAge': currentRangeValues.start.round(),
                  'maxAge': currentRangeValues.end.round(),
                });
              },
              child: Text('Áp dụng'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}