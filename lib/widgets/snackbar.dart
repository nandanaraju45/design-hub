import 'package:flutter/material.dart';

ScaffoldFeatureController mySnackBar(BuildContext context, String message) {
  return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message),
  ));
}
