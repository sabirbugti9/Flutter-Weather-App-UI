import 'package:equatable/equatable.dart';

class Weather extends Equatable {
  final String cityName;
  final double temperature;
  final int humidity;
  final double windSpeed;
  final String condition;
  final String icon; // New field for the weather icon
  final List<Forecast> forecast;

  const Weather({
    required this.cityName,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.condition,
    required this.icon, // Added icon
    required this.forecast,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    Map<String, Forecast> dailyForecast = {};

    for (var e in json['list']) {
      String date = e['dt_txt'].split(" ")[0]; // Extract YYYY-MM-DD
      if (!dailyForecast.containsKey(date)) {
        dailyForecast[date] = Forecast(
          date: date,
          minTemp: e['main']['temp_min'].toDouble(),
          maxTemp: e['main']['temp_max'].toDouble(),
          condition: e['weather'][0]['main'],
          icon: e['weather'][0]['icon'],
        );
      }
    }

    return Weather(
      cityName: json['city']['name'],
      temperature: json['list'][0]['main']['temp'].toDouble(),
      humidity: json['list'][0]['main']['humidity'],
      windSpeed: json['list'][0]['wind']['speed'].toDouble(),
      condition: json['list'][0]['weather'][0]['main'],
      icon: json['list'][0]['weather'][0]['icon'],
      forecast: dailyForecast.values.take(5).toList(), // Take 5 unique days
    );
  }

  @override
  List<Object> get props =>
      [cityName, temperature, humidity, windSpeed, condition, icon, forecast];
}

class Forecast {
  final String date;
  final double minTemp;
  final double maxTemp;
  final String condition;
  final String icon; // Added icon field

  Forecast({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.condition,
    required this.icon, // Included icon
  });
}
