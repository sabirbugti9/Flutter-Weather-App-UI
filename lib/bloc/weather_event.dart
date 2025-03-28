import 'package:equatable/equatable.dart';

abstract class WeatherEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchWeather extends WeatherEvent {
  final double lat;
  final double lon;

  FetchWeather(this.lat, this.lon);

  @override
  List<Object> get props => [lat, lon];
}

class FetchWeatherByCity extends WeatherEvent {
  final String cityName;

  FetchWeatherByCity(this.cityName);

  @override
  List<Object> get props => [cityName];
}
