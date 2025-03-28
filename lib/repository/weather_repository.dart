import '../core/api_service.dart';
import '../models/weather_model.dart';

class WeatherRepository {
  final ApiService apiService;

  WeatherRepository(this.apiService);

  // Fetch weather data based on latitude and longitude
  Future<Weather> getWeather(double lat, double lon) async {
    final response = await apiService.getWeather(lat, lon);
    return Weather.fromJson(response);
  }

  // Fetch weather data based on city name
  Future<Weather> getWeatherByCity(String cityName) async {
    final response = await apiService.getWeatherByCity(cityName);
    return Weather.fromJson(response);
  }
}
