import 'package:flutter/material.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'hangman_painter.dart';

class HangmanGameScreen extends StatefulWidget {
  @override
  _HangmanGameScreenState createState() => _HangmanGameScreenState();
}

class _HangmanGameScreenState extends State<HangmanGameScreen> {
  // List of words to choose from. You can expand this list or fetch it from an external source.
  final List<String> words = ['FLUTTER', 'DART', 'WIDGET', 'STATE'];

  // Current word to guess
  late String currentWord;


  // Stores the letters of the current word as a list.
  late List<String> currentWordLetters;

  // Stores the letters guessed by the user
  Set<String> guessedLetters = {};

  // Number of attempts remaining - starts at 5 for simplicity
  int attemptsRemaining = 5;

  // Hangman body parts
  bool _showHead = false;
  bool _showBody = false;
  bool _showLeftArm = false;
  bool _showRightArm = false;
  bool _showLeftLeg = false;
  bool _showRightLeg = false;

  late String _categoryHint;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  Future<Map<String, String>>  getRandomWordFromFirestore() async {
    final firestore = FirebaseFirestore.instance;
    final categories = await firestore.collection('Match The Column').get();

    //if (categories.docs.isEmpty) {
    //  return 'Error'; // or some other error word or handling
    //}

    // Fetch a random category
    final randomCategory = categories.docs[Random().nextInt(categories.docs.length)];

    // Fetch questions from the random category
    final questions = List.from(randomCategory['Questions'] as List);

    //if (questions.isEmpty) {
    //  return 'Error'; // or some other error word or handling
    //}

    // Fetch a random question from the list
    final randomQuestion = questions[Random().nextInt(questions.length)];
    print(randomQuestion['Question'].toUpperCase());

    // Return both the word and its category
    return {'word': randomQuestion['Question'].toUpperCase(), 'category': randomCategory.id};
  }

  void _startNewGame() async {
    Map<String, String> data = await getRandomWordFromFirestore();
    setState(() {
      currentWord = data['word']!;
      _categoryHint = data['category']!;
      currentWordLetters = List<String>.from(currentWord.split(''));
      guessedLetters.clear();
      attemptsRemaining = 5;

      // Reset the visibility of hangman parts
      _showHead = false;
      _showBody = false;
      _showLeftArm = false;
      _showRightArm = false;
      _showLeftLeg = false;
      _showRightLeg = false;
    });
  }

  void _showHint() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Hint'),
            content: Text('The word belongs to the category: $_categoryHint'),
            actions: [
              TextButton(
                child: Text('Okay'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }



  void _guessLetter(String letter) {
    setState(() { // Enclose the changes in a setState call
      // Add the letter to guessedLetters regardless of whether it's correct
      guessedLetters.add(letter);

      if (currentWordLetters.contains(letter)) {
        if (currentWordLetters.every((element) => guessedLetters.contains(element))) {
          // Win condition
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Congratulations!'),
                  content: Text('You guessed the word correctly!'),
                  actions: [
                    TextButton(
                      child: Text('New Game'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _startNewGame();
                      },
                    ),
                  ],
                );
              });
        }
      } else {
        // Decrement remaining attempts and show the next body part
        --attemptsRemaining;
        _showNextBodyPart();
        if (attemptsRemaining == 0) {
          // Lose condition
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Game Over'),
                  content: Text('The correct word was "$currentWord".'),
                  actions: [
                    TextButton(
                      child: Text('New Game'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _startNewGame();
                      },
                    ),
                  ],
                );
              });
        }
        // Check if hint button should be shown
        if (attemptsRemaining == 3 && !_showHead && !_showBody) {
          _showHint();
        }
      }
    }); // End of setState call
  }



  // Function to determine which body part to show next
  void _showNextBodyPart() {
    if (!_showHead && !_showBody) {
      _showHead = true;
      _showBody = true;
    } else if (!_showLeftArm) {
      _showLeftArm = true;
    } else if (!_showRightArm) {
      _showRightArm = true;
    } else if (!_showLeftLeg) {
      _showLeftLeg = true;
    } else if (!_showRightLeg) {
      _showRightLeg = true;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hangman Game'),
      ),
      body: Column(
        children: [
          Text(
            'Attempts remaining: $attemptsRemaining',
            style: TextStyle(fontSize: 20, color: Colors.red),
          ),
          // Add a hint button that becomes visible after 2 incorrect attempts
          if (attemptsRemaining <= 3)
            ElevatedButton(
              onPressed: _showHint,
              child: Text('Hint'),
            ),
          SizedBox(height: 20),
          // This creates a display of underscores for letters not guessed yet, and letters for those guessed.
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: currentWordLetters
                .map((letter) => guessedLetters.contains(letter)
                ? Text(letter)
                : Text('_'))
                .toList(),
          ),
          SizedBox(height: 20),
          Expanded(
            child:Transform.translate(
              offset: const Offset(0, -100), // moves 10 pixels up,
            child: Transform.scale(
              scale: 0.7, // you can change the scale factor here
              child: CustomPaint(
                painter: HangmanPainter(
                  head: _showHead,
                  body: _showBody,
                  leftArm: _showLeftArm,
                  rightArm: _showRightArm,
                  leftLeg: _showLeftLeg,
                  rightLeg: _showRightLeg,
                ),
                child: Container(), // Container takes any available space that's left
              ),
            ),
          ),
          ),
          Wrap(
            spacing: 4.0,
            runSpacing: 4.0,
            children: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
                .split('')
                .map((letter) => ElevatedButton(
              onPressed: guessedLetters.contains(letter)
                  ? null // Disables the button if the letter has already been guessed
                  : () => _guessLetter(letter),
              child: Text(letter),
            ))
                .toList(),
          ),
        ],
      ),
    );
  }

}
