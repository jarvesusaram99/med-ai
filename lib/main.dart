import 'package:medai/models.dart/hive/all_chats.dart';
import 'package:medai/models.dart/hive/single_chat.dart';
import 'package:medai/utils/colors.dart';
import 'package:medai/utils/material_swatch.dart';
import 'package:medai/views/screens/chat_screen.dart';
import 'package:medai/views/screens/explore_screen.dart';
import 'package:medai/views/screens/home_screen.dart';
import 'package:medai/views/screens/loading_screen.dart';
import 'package:medai/views/screens/main_screen.dart';

import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(ChatAdapter());
  Hive.registerAdapter(SingleChatAdapter());
  await Hive.openBox<Chat>('chatsbox');
  await Hive.openBox<SingleChatAdapter>('singleChatBox');
  await Hive.openBox('chat');
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      
      debugShowCheckedModeBanner: false,
      title: 'Med AI',
      routes: {
        '/': (context) => const MainScreen(),
        '/chatScreen': (context) => const ChatScreen(),
        '/homeScreen': (context) => const HomeScreen(),
        "/exploreScreen": (context) => const ExploreScreen(),
        '/loadingScreen': (context) => const LoadingScreen(),
      },
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: GoogleFonts.ubuntu().fontFamily,
        primarySwatch: createMaterialColor(TextColors.appPrimaryColor),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark().copyWith(
        textTheme: ThemeData.dark().textTheme.apply(
              fontFamily: GoogleFonts.ubuntu().fontFamily,
            ),
      ),
      initialRoute: "/",
      // home: const HomeScreen(),
    );
  }
}