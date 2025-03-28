import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/weather_bloc.dart';
import 'repository/weather_repository.dart';
import 'core/api_service.dart';
import 'view/splash_screen.dart';

void main() {
  final WeatherRepository repository = WeatherRepository(ApiService());

  runApp(MyApp(repository: repository));
}

class MyApp extends StatelessWidget {
  final WeatherRepository repository;

  const MyApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WeatherBloc(repository),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      ),
    );
  }
}
