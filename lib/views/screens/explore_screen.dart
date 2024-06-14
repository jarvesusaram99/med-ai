import 'package:flutter/material.dart';

import '../../utils/colors.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.blueGrey.shade900,
          title: const Text("Explore Prompts"),
          actions: const [],
        ),
        backgroundColor: TextColors.backgroundColor,
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    decoration: InputDecoration(
                        fillColor: TextColors.appBarBackgroundColor,
                        isDense: true,
                        enabled: true,
                        filled: true,
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.white70),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 0,
                            style: BorderStyle.none,
                          ),
                        ),
                        hintText: "Search",
                        labelStyle: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Colors.white54)),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ));
  }
}