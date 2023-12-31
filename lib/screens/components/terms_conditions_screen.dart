import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  final List<String> imageNames = [
    'image1.png',
    'image2.png',
    'image3.png',
    'image4.png',
    'image5.png',
    'image6.png',
    'image7.png',
    // Add all image file names in the folder
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms and Conditions'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: imageNames.map((imageName) => Image.asset('assets/images/Terms and conditions/$imageName')).toList(),
        ),
      ),
    );
  }
}
