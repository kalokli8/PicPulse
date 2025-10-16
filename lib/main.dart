import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'blocs/photo_bloc.dart';
import 'services/photo_service.dart';
import 'services/photo_cache_service.dart';
import 'screens/photo_list_screen.dart';
import 'screens/photo_detail_screen.dart';
import 'models/photo.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize PhotoCacheService
  await PhotoCacheService.init();

  runApp(const PicPulseApp());
}

class PicPulseApp extends StatelessWidget {
  const PicPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PhotoBloc(photoService: PhotoService()),
      child: MaterialApp(
        title: AppConstants.appName,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF00CCFF), // Adobe blue
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFF1F5F9), // Light blue-gray background
            foregroundColor: Color(0xFF0F172A), // Dark slate text
            elevation: 0,
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: const PhotoListScreen(),
        routes: {
          '/detail': (context) {
            final photo = ModalRoute.of(context)!.settings.arguments as Photo;
            return PhotoDetailScreen(photo: photo);
          },
        },
      ),
    );
  }
}
