import 'package:e_learning_app/model/product_model.dart';
import 'package:e_learning_app/screens/GrammarScreens/GrammarRulesScreen.dart';
import 'package:e_learning_app/screens/comprehension_choice_screen.dart';
import 'package:flutter/material.dart';
import 'package:e_learning_app/screens//practise_vocab_screen.dart';
import '../../model/current_user.dart';
import '../Games/game_selection_screen.dart';
import '../TeacherScreens/teacher_choice_screen.dart';
import '../anki_category_screen.dart';

class CategoryList extends StatelessWidget {
  const CategoryList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        shrinkWrap: true,
        physics: ScrollPhysics(),
        itemCount: products.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, childAspectRatio: 0.85),
        itemBuilder: (context, index) => CategoryCard(
              product: products[index],
            ));
  }
}

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    Key? key,
    required this.product,
  }) : super(key: key);
  final Product product;

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: GestureDetector(
        onTap: () {
          if (product.title == "Games") {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      const GameSelectionScreen()),
            );
          } else if (product.title == "Pronounciation") {
            // Pronounciation card to anki card
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AnkiCategoryScreen()),
            );
          } else if (product.title == "Practise Vocabulary") {
            if (CurrentUser().userType == "Teacher") {
              // If userType is "Teacher", navigate to TeacherChoiceScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        TeacherChoiceScreen(screen: 'Vocabulary')),
              );
            } else {
              // If userType is not "Teacher" (student), navigate to PracticeVocabularyScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PracticeVocabularyScreen(
                          updateMode: '',
                        )),
              );
            }
          } else if (product.title == "Grammar Rules") {
            if (CurrentUser().userType == "Teacher") {
              // If userType is "Teacher", navigate to TeacherChoiceScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        TeacherChoiceScreen(screen: 'Grammar')),
              );
            } else {
              // otherwise, navigate to PracticeVocabularyScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => GrammarRulesScreen(
                          updateMode: '',
                        )),
              );
            }
          } else if (product.title == "Comprehension Texts") {
            if (CurrentUser().userType == "Teacher") {
              // If userType is "Teacher", navigate to TeacherChoiceScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        TeacherChoiceScreen(screen: 'Comprehension')),
              );
            } else {
              // otherwise, navigate to PracticeVocabularyScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ComprehensionChoiceScreen()),
              );
            }
          }
        },
        child: Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
              color: product.color, borderRadius: BorderRadius.circular(30.0)),
          child: Column(
            children: [
              Image.asset(
                product.image,
                height: 100,
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                product.title,
                style:  const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "${product.courses} courses",
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
