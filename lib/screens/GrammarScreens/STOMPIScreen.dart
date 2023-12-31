import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class STOMPIScreen extends StatefulWidget {
  @override
  _STOMPIScreenState createState() => _STOMPIScreenState();
}

class _STOMPIScreenState extends State<STOMPIScreen> {
  List<String>? words;
  String? originalSentence;
  String? englishTranslation;
  final TextEditingController _controller = TextEditingController();
  String userAnswer = '';
  bool? isCorrect;
  int currentSentenceIndex = 0;
  List<DocumentSnapshot> validSentences = [];

  @override
  void initState() {
    super.initState();
    fetchSentence();
  }

  Future<void> fetchSentence() async {
    try {
      final sentences = await FirebaseFirestore.instance.collection('sentences').get();

      validSentences = sentences.docs.where((QueryDocumentSnapshot doc) {
        final Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        if (data == null) return false;

        final words = (data['afrikaans'] as String?)?.split(' ');
        if (words == null) return false;

        return words.any((String word) => word.length >= 4);
      }).toList();

      validSentences.shuffle();
      loadCurrentSentence();
    } catch (e) {
      print('Error fetching sentence: $e');
    }
  }

  void loadCurrentSentence() {
    if (validSentences.isNotEmpty && currentSentenceIndex < validSentences.length) {
      final currentDocData = validSentences[currentSentenceIndex].data() as Map<String, dynamic>;
      originalSentence = currentDocData['afrikaans'];
      englishTranslation = currentDocData['english'];

      final splitWords = originalSentence!.split(' ');
      setState(() {
        words = splitWords..shuffle();
        isCorrect = null;
        _controller.clear(); // Clear previous answer
      });
    }
  }

  void checkAnswer() {
    setState(() {
      userAnswer = _controller.text;
      isCorrect = userAnswer.trim() == originalSentence?.trim();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('STOMPIScreen'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF9ba0fc),
              Color(0xcc9ba0fc),
              Color(0x999ba0fc),
              Color(0x669ba0fc),
            ],
          ),
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Using the following words, write them out in STOMPI format:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            words == null
                ? Expanded(child: Center(child: CircularProgressIndicator()))
                : Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: words!.map((word) => InputChip(
                label: Text(word),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                onPressed: () {
                  print('Word clicked: $word');
                },
              )).toList(),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Type your answer here',
                  suffixIcon: IconButton(
                    onPressed: _controller.clear,
                    icon: Icon(Icons.clear),
                  ),
                ),
                onSubmitted: (value) => checkAnswer(),
              ),
            ),
            if (englishTranslation != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: ElevatedButton(
                  onPressed: () => _showHelpDialog(englishTranslation!),
                  child: Text('Show Translation'),
                ),
              ),
            if (isCorrect != null)
              Text(isCorrect! ? 'Correct!' : 'Wrong!', style: TextStyle(color: isCorrect! ? Colors.green : Colors.red, fontSize: 18)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: checkAnswer,
        child: Icon(Icons.check),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: currentSentenceIndex == 0 ? null : () => moveToPreviousSentence(),
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward),
              onPressed: currentSentenceIndex == validSentences.length - 1 ? null : () => moveToNextSentence(),
            ),
          ],
        ),
      ),
    );
  }

  void moveToPreviousSentence() {
    if (currentSentenceIndex > 0) {
      setState(() {
        currentSentenceIndex--;
        loadCurrentSentence();
      });
    }
  }

  void moveToNextSentence() {
    if (currentSentenceIndex < validSentences.length - 1) {
      setState(() {
        currentSentenceIndex++;
        loadCurrentSentence();
      });
    }
  }

  void _showHelpDialog(String englishTranslation) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Translation Help'),
          content: Text(englishTranslation),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
