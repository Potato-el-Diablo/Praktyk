import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

import 'dart:math'; // Import the dart:math library

class Product {
  final String image, title;
  final int id, courses;
  final Color color;
  final double progress; // Add a progress property
  Product({
    required this.image,
    required this.title,
    required this.courses,
    required this.color,
    required this.id,
    required this.progress, // Include progress in the constructor
  });
}

List<Product> products = [
  Product(
    id: 1,
    title: "Practise Vocab",
    image: "assets/images/practisevocab.png",
    color: Color(0xFF71b8ff),
    courses: 16,
    progress: 32, // Generate a random progress value
  ),
  Product(
    id: 2,
    title: "Grammar Rules",
    image: "assets/images/grammarules.png",
    color: Color(0xFFff6374),
    courses: 22,
    progress: 1, // Generate a random progress value
  ),
  Product(
    id: 3,
    title: "Pronounciation",
    image: "assets/images/pronounciation.png",
    color: Color(0xFFffaa5b),
    courses: 15,
    progress: 87, // Generate a random progress value
  ),
  Product(
    id: 4,
    title: "Games",
    image: "assets/images/games.png",
    color: Color(0xFF9ba0fc),
    courses: 18,
    progress: 98, // Generate a random progress value
  ),
];
