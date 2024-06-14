import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AppLoading extends StatefulWidget {
  const AppLoading({super.key});

  @override
  State<AppLoading> createState() => _AppLoadingState();
}

class _AppLoadingState extends State<AppLoading> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
            height: 18.0,
            // width: 18.0,
            // alignment: Alignment.topCenter,
            margin: const EdgeInsets.only(top: 5, bottom: 5),
            child: LoadingAnimationWidget.waveDots(
                color: Colors.blue,
                // rightDotColor: Colors.white,
                size: 50)
            // CupertinoActivityIndicator(),
            ),
      ),
    );
  }
}