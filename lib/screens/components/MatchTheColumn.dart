import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:e_learning_app/model/current_user.dart';

class MatchTheColumnPage extends StatefulWidget {
  final String categoryName;
  const MatchTheColumnPage({Key? key, required this.categoryName}) : super(key: key);

  @override
  _MatchTheColumnPageState createState() => _MatchTheColumnPageState();
}

class _MatchTheColumnPageState extends State<MatchTheColumnPage> {
  List<String> questions = [];
  List<String> answers = [];
  Map<int, int> matchingPairs = {};
  Map<String, String> originalPairs = {};
  int correctMatches = 0;

  // List to store colors of question buttons
  List<Color> questionButtonColors = [];
  // List to store colors of answer buttons
  List<Color> answerButtonColors = [];
  int? selectedQuestionIndex;
  int? selectedAnswerIndex;
  int currentStartIndex = 0;
  bool showNextButton =false;

  // Store the questions map from the database
  Map<String, dynamic>? questionsMap;
  @override
  void initState() {
    super.initState();
    String userId = CurrentUser().userId!;
    fetchCompletedQuestionsCount(userId, widget.categoryName).then((completedCount) {
      fetchRandomQuestionsAndAnswers(completedCount);
    });
  }

  Future<int> fetchCompletedQuestionsCount(String userId, String categoryName) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .get();

    if (userDoc.exists && userDoc.data()!.containsKey('MatchTheColumn') &&
        userDoc.data()!['MatchTheColumn'].containsKey(categoryName)) {
      return userDoc.data()!['MatchTheColumn'][categoryName];
    } else {
      return 0; // default to 0 if data is not found
    }
  }

  Future<void> fetchNextSetOfQuestionsAndAnswers(int delta) async {

    if (currentStartIndex + delta < 0) {
      print("No more previous questions");
      return;
    }
    currentStartIndex += delta;
    String userId = CurrentUser().userId!;
    fetchRandomQuestionsAndAnswers(currentStartIndex);

    int completedCount = await fetchCompletedQuestionsCount(userId, widget.categoryName);

    setState(() {
      correctMatches = 0;
      resultMessage = "";
      showNextButton = false;

      questionButtonColors = List.generate(questions.length, (index) {
        switch (index) {
          case 0:
            return Colors.red;
          case 1:
            return Colors.blue;
          case 2:
            return Colors.yellow;
          case 3:
            return Colors.green;
          default:
            return Colors.white;
        }
      });

      // Reset colors for answer buttons
      answerButtonColors = List.generate(answers.length, (index) {
        return Colors.white; // Initially, all answer buttons are white
      });

      // Reset matching pairs and selections
      matchingPairs.clear();
      selectedQuestionIndex = null;
      selectedAnswerIndex = null;
    });
  }



  Future<void> updateMatchTheColumnCount(String userId, String categoryName, int incrementValue) async {
    try {
      final userRef = FirebaseFirestore.instance.collection('Users').doc(userId);
      final batch = FirebaseFirestore.instance.batch();

      batch.set(
        userRef,
        {
          'MatchTheColumn': {
            categoryName: FieldValue.increment(incrementValue),
          },
        },
        SetOptions(merge: true),
      );

      batch.update(
        userRef,
        {
          'Questions Completed.Match The Column': FieldValue.increment(incrementValue),
        },
      );

      // Commit both updates in a single batch
      await batch.commit();
    } catch (e) {
      print("Error updating MatchTheColumn count: $e");
    }
  }



  Future<void> fetchRandomQuestionsAndAnswers(int startIndex) async {
    currentStartIndex = startIndex;
    try {
      final categoryDoc = await FirebaseFirestore.instance
          .collection('Match The Column')
          .doc(widget.categoryName)
          .get();

      if (categoryDoc.exists) {
        final data = categoryDoc.data() as Map<String, dynamic>;
        final questionAnswerArray = data['Questions'] as List;

        // take 4 questions starting from the startIndex
        final selectedQuestionAnswerList = questionAnswerArray.skip(startIndex).take(4).toList();

        // Clear existing questions and answers
        questions.clear();
        answers.clear();

        for (final entry in selectedQuestionAnswerList) {
          questions.add(entry['Question']);
          answers.add(entry['Answer']);
          originalPairs[entry['Question']] = entry['Answer'];
        }
        answers.shuffle(Random());


        // Initialize questionButtonColors and answerButtonColors with different colors
        questionButtonColors = List.generate(questions.length, (index) {
          switch (index) {
            case 0:
              return Colors.red;
            case 1:
              return Colors.blue;
            case 2:
              return Colors.yellow;
            case 3:
              return Colors.green;
            default:
              return Colors.white;
          }
        });

        // Initially, all answer buttons are white
        answerButtonColors = List.generate(answers.length, (index) {
          return Colors.white;
        });

        setState(() {});
      } else {
        print('Category not found');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> updateStartIndexInFirestore(String userId, String categoryName, int newIndex) async {
    try {
      final userRef = FirebaseFirestore.instance.collection('Users').doc(userId);
      await userRef.set({
        'MatchTheColumnStartIndices': {
          categoryName: newIndex,
        },
      }, SetOptions(merge: true));
    } catch (e) {
      print("Error updating start index: $e");
    }
  }



  Column buildQuestionColumn() {
    return Column(
      children: [
        const Text(
          "Questions",
          style: TextStyle(
            fontSize: 24,
            color: Colors.blue,
          ),
        ),
        for (int i = 0; i < questions.length; i++) buildQuestion(i),
      ],
    );
  }

  Column buildAnswerColumn() {
    return Column(
      children: [
        const Text(
          "Answers",
          style: TextStyle(
            fontSize: 24,
            color: Colors.green,
          ),
        ),
        for (int i = 0; i < answers.length; i++) buildAnswer(i),
      ],
    );
  }

  String resultMessage = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
      ),
      body: GestureDetector(
        onTap: () {
          //currently nothing
          },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                width: double.infinity,
                child: Row(
                  children: [
                    // Left Column - Questions
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                            width: 2.0,
                          ),
                        ),
                        child: buildQuestionColumn(),
                      ),
                    ),
                    // Right column -> answers
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                            width: 2.0,
                          ),
                        ),
                        child: buildAnswerColumn(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Matchings:",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Column(
              children: [
                Wrap(
                  children: List.generate(questions.length, (index) {
                    final question = questions[index];
                    final matchingIndex = matchingPairs[index];
                    final answer =
                    matchingIndex != null ? answers[matchingIndex] : null;

                    return Container(
                      width: MediaQuery.of(context).size.width / 2,
                      child: ListTile(
                        title: Text("$index. $question"),
                        subtitle: Text(
                            answer != null ? "${String.fromCharCode(matchingIndex! + 65)}. $answer" : ""),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    checkMatchingPairs();
                    setState(() {
                      resultMessage = "You have $correctMatches correct matches";
                    });
                  },
                  child: const Text(
                    "Confirm",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.blue,
                    ),
                  ),
                ),
                Text(
                  resultMessage,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.green,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0), // adjust as needed
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(8.0), // if you want rounded corners
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround, // To space the buttons evenly in the row
                    children: [
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) {
                              if (states.contains(MaterialState.disabled)) return Colors.grey;
                              return Colors.blue;
                            },
                          ),
                        ),
                        onPressed: currentStartIndex > 0
                            ? () {
                          fetchNextSetOfQuestionsAndAnswers(-4);
                        }
                            : null, // Disable the button
                        child: const Text(
                          "Previous",
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) {
                              if (states.contains(MaterialState.disabled)) return Colors.grey;
                              return Colors.blue; // Otherwise, return the primary color
                            },
                          ),
                        ),
                        onPressed: showNextButton
                            ? () {
                          fetchNextSetOfQuestionsAndAnswers(4);
                        }
                            : null, // Disable the button
                        child: const Text(
                          "Next",
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  )
                  ,
                )

              ],
            ),
          ],
        ),
      ),
    );
  }


  void checkMatchingPairs() {
    int correctMatchesCount = 0;

    for (int i = 0; i < questions.length; i++) {
      final matchingIndex = matchingPairs[i];
      if (matchingIndex != null && matchingIndex >= 0 && matchingIndex < answers.length) {
        final originalQuestion = questions[i];
        final originalAnswer = originalPairs[originalQuestion];
        final matchingAnswer = answers[matchingIndex];

        if (originalAnswer == matchingAnswer) {
          correctMatchesCount++;
        }
      }
    }

    setState(() {
      correctMatches = correctMatchesCount;
    });

    if (correctMatchesCount == questions.length) {
      String userId = CurrentUser().userId!;
      fetchCompletedQuestionsCount(userId, widget.categoryName).then((matchTheColumnCountFromDb) {
        if (matchTheColumnCountFromDb == currentStartIndex) {
          updateStartIndexInFirestore(userId, widget.categoryName, currentStartIndex + 4);
          updateMatchTheColumnCount(userId, widget.categoryName, correctMatchesCount);
        }
        setState(() {
          showNextButton = true;
        });
      });
    }


    print("Correct Matches: $correctMatchesCount");
  }




  void pairSelected() {
    if (selectedQuestionIndex != null && selectedAnswerIndex != null) {
      matchingPairs[selectedQuestionIndex!] = selectedAnswerIndex!;
      answerButtonColors[selectedAnswerIndex!] = questionButtonColors[selectedQuestionIndex!];

      selectedAnswerIndex = null;
    }
  }


  Widget buildQuestion(int index) {
    final isMatched = matchingPairs.containsKey(index);

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedQuestionIndex = index;
          pairSelected();
        });
        print("Selected Question X: ${index * 40.0}");
      },
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
              width: 1.0,
            ),
            color: isMatched
                ? questionButtonColors[index]
                : (selectedQuestionIndex == index
                ? questionButtonColors[index]
                : Colors.white),
          ),
          child: Center(
            child: Text(
              questions[index],
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildAnswer(int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedAnswerIndex = index;
          pairSelected();
        });
        print("Selected Answer X: ${(index + 2) * 40.0}");
      },
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
              width: 1.0,
            ),
            color: selectedAnswerIndex == index
                ? questionButtonColors[selectedQuestionIndex ?? 0]
                : answerButtonColors[index],
          ),
          child: Center(
            child: Text(
              answers[index],
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }



}

void main() {
  runApp(const MaterialApp(
    home: MatchTheColumnPage(categoryName: ''),
  ));
}