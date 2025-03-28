import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/weather_bloc.dart';
import '../bloc/weather_event.dart';
import '../bloc/weather_state.dart';
import '../widgets/weather_card.dart';
import '../widgets/forecast_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
    Future.microtask(() => _getUserLocation());
  }

  Future<void> _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> _getUserLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double? storedLat = prefs.getDouble('latitude');
    double? storedLon = prefs.getDouble('longitude');

    if (storedLat != null && storedLon != null) {
      // Use stored location
      BlocProvider.of<WeatherBloc>(context)
          .add(FetchWeather(storedLat, storedLon));
    } else {
      bool isPermissionGranted = await _requestLocationPermission();
      if (isPermissionGranted) {
        Position position = await Geolocator.getCurrentPosition();
        prefs.setDouble('latitude', position.latitude);
        prefs.setDouble('longitude', position.longitude);
        BlocProvider.of<WeatherBloc>(context)
            .add(FetchWeather(position.latitude, position.longitude));
      } else {
        // Use default location (Example: New York)
        _showSnackbar("Using default location.");
        BlocProvider.of<WeatherBloc>(context)
            .add(FetchWeather(40.7128, -74.0060));
      }
    }
  }

  Future<bool> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackbar("Location permission denied. Using default location.");
        return false;
      } else if (permission == LocationPermission.deniedForever) {
        _showSnackbar(
            "Location permission permanently denied. Please enable it from settings.");
        return false;
      }
    }
    return true;
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _searchCity(String cityName) {
    if (cityName.isNotEmpty) {
      BlocProvider.of<WeatherBloc>(context).add(FetchWeatherByCity(cityName));
    }
  }

  void _toggleDarkMode() async {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', _isDarkMode);
  }

  Future<void> _refreshWeather() async {
    _getUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData.light(),
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark(),
      home: Scaffold(
        appBar: _appbar(),

        body: BlocBuilder<WeatherBloc, WeatherState>(
          builder: (context, state) {
            if (state is WeatherLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is WeatherLoaded) {
              if (state.weather.forecast.isEmpty) {
                return const Center(child: Text("No forecast data available."));
              }
              return RefreshIndicator(
                onRefresh: _refreshWeather, // Pull-to-refresh trigger
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children:  [
                    WeatherCard(weather: state.weather),
                    const SizedBox(height: 20,),
                    _forecastCard(state),
      
                  ],
                ),
              );
            } else if (state is WeatherError) {
              return RefreshIndicator(
                  onRefresh: _refreshWeather,
                  child: const Center(child: Text("Failed to load weather")));
            }
            return Container();
          },
        ),
      ),
    );
  }

  ForecastCard _forecastCard(WeatherLoaded state) {
    return ForecastCard(
      forecast: state.weather.forecast,
      currentDate: state.weather.forecast[0].date.split(" ")[0],
    );
  }

  AppBar _appbar() {
    return AppBar(
      title: _isSearching
          ? TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: "Enter city name",
                border: InputBorder.none,
              ),
              onSubmitted: (value) {
                _searchCity(value);
              },
            )
          : const Text('Weather App'),
      actions: [
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search),
          onPressed: () {
            setState(() {
              if (_isSearching) {
                _isSearching = false;
                _searchController.clear();
              } else {
                _isSearching = true;
              }
            });
          },
        ),
        if (_isSearching)
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _searchCity(_searchController.text);
            },
          ),
        IconButton(
          onPressed: _toggleDarkMode,
          icon: Icon(
            _isDarkMode ? Icons.wb_sunny_outlined : Icons.dark_mode_outlined,
          ),
        ),
      ],
    );
  }
}
