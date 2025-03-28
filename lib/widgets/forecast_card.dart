import 'package:flutter/material.dart';
import '../models/weather_model.dart';

class ForecastCard extends StatelessWidget {
  final List<Forecast> forecast;
  final String currentDate;

  const ForecastCard({required this.forecast, required this.currentDate});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Grouping forecast by unique days, selecting the closest to 12:00 PM
    Map<String, Forecast> dailyForecast = {};

    for (var f in forecast) {
      String date = f.date.split(" ")[0]; // Extract YYYY-MM-DD

      // Skip the forecast for the current day
      if (date != currentDate && !dailyForecast.containsKey(date)) {
        dailyForecast[date] = f; // Store forecast for the next days
      }
    }

    // Using the full list of forecasts (no filtering by 5 days)
    var forecastList = forecast; // No need for filtering

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black45 : Colors.black12,
            blurRadius: 6,
            spreadRadius: 2,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: forecastList.isNotEmpty
            ? forecastList.map((f) {
                return ListTile(
                  leading: Image.network(
                    "https://openweathermap.org/img/wn/${f.icon}.png",
                    width: 40,
                    height: 40,
                  ),
                  title: Text(
                    _formatDate(f.date),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    "Min: ${f.minTemp.round()}°C  Max: ${f.maxTemp.round()}°C",
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  trailing: Text(
                    f.condition,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                  ),
                );
              }).toList()
            : [const Center(child: Text("No forecast data available."))],
      ),
    );
  }

  // Helper function to format date
  String _formatDate(String dateTime) {
    DateTime date = DateTime.parse(dateTime.split(" ")[0]); // Extract date part
    return "${_getWeekday(date.weekday)}, ${date.day}";
  }

  String _getWeekday(int weekday) {
    const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return days[weekday - 1];
  }
}
