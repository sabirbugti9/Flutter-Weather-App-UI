import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/weather_repository.dart';
import 'weather_event.dart';
import 'weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherRepository repository;

  WeatherBloc(this.repository) : super(WeatherInitial()) {
    // Handle FetchWeather event
    on<FetchWeather>((event, emit) async {
      emit(WeatherLoading());
      try {
        final weather = await repository.getWeather(event.lat, event.lon);
        emit(WeatherLoaded(weather));
      } catch (e) {
        emit(WeatherError("Failed to fetch weather data"));
      }
    });

    // Handle FetchWeatherByCity event
    on<FetchWeatherByCity>((event, emit) async {
      emit(WeatherLoading());
      try {
        final weather = await repository.getWeatherByCity(event.cityName);
        emit(WeatherLoaded(weather));
      } catch (e) {
        emit(WeatherError("Failed to fetch weather data"));
      }
    });
  }
}
