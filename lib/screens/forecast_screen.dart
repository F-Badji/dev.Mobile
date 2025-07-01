import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/forecast_model.dart';
import '../utils/constants.dart';
import '../widgets/lottie_weather_icon.dart';

class ForecastScreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String cityName;

  const ForecastScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.cityName,
  });

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen>
    with TickerProviderStateMixin {
  ForecastModel? _forecast;
  bool _isLoading = true;
  String? _error;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadForecastData();
  }

  Future<void> _loadForecastData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Simuler le chargement des données de prévision
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Erreur lors du chargement des prévisions';
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppConstants.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              _buildTabBar(),
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          Expanded(
            child: Text(
              'Prévisions - ${widget.cityName}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: _loadForecastData,
            icon: const Icon(
              Icons.refresh_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(51),
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        ),
        labelColor: AppConstants.primaryColor,
        unselectedLabelColor: Colors.white,
        tabs: const [
          Tab(text: 'Aujourd\'hui'),
          Tab(text: '7 jours'),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.white,
              size: 48,
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              _error!,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.paddingLarge),
            ElevatedButton(
              onPressed: _loadForecastData,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_forecast == null) {
      return const Center(
        child: Text(
          'Aucune donnée disponible',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildHourlyForecast(),
        _buildDailyForecast(),
      ],
    );
  }

  Widget _buildHourlyForecast() {
    final hourlyData = _forecast!.hourly.take(24).toList();
    
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      child: Column(
        children: [
          // Graphique de température
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(51),
                borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
              ),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.round()}°',
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() % 6 == 0) {
                            final hour = hourlyData[value.toInt()].dateTime.hour;
                            return Text(
                              '$hour:00',
                              style: const TextStyle(color: Colors.white, fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: hourlyData.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value.temperature);
                      }).toList(),
                      isCurved: true,
                      color: Colors.white,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.white.withAlpha(26),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          // Liste horaire
          Expanded(
            flex: 1,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: hourlyData.length,
              itemBuilder: (context, index) {
                final hour = hourlyData[index];
                return Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: AppConstants.paddingSmall),
                  padding: const EdgeInsets.all(AppConstants.paddingSmall),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(26),
                    borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${hour.dateTime.hour}:00',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      LottieWeatherIcon(
                        weatherDescription: 'soleil',
                        size: 30,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${hour.temperature.round()}°',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyForecast() {
    final dailyData = _forecast!.daily.take(7).toList();
    
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      child: Column(
        children: [
          // Graphique des températures min/max
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(51),
                borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
              ),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: dailyData.fold(0.0, (max, day) => 
                    day.maxTemp > max ? day.maxTemp : max) + 5,
                  minY: dailyData.fold(0.0, (min, day) => 
                    day.minTemp < min ? day.minTemp : min) - 5,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.round()}°',
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final day = dailyData[value.toInt()];
                          final weekday = _getWeekday(day.dateTime.weekday);
                          return Text(
                            weekday,
                            style: const TextStyle(color: Colors.white, fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: dailyData.asMap().entries.map((entry) {
                    final index = entry.key;
                    final day = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: day.maxTemp,
                          color: Colors.orange,
                          width: 8,
                        ),
                        BarChartRodData(
                          toY: day.minTemp,
                          color: Colors.blue,
                          width: 8,
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          // Liste des jours
          Expanded(
            flex: 1,
            child: ListView.builder(
              itemCount: dailyData.length,
              itemBuilder: (context, index) {
                final day = dailyData[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(26),
                    borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _getWeekday(day.dateTime.weekday),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      LottieWeatherIcon(
                        weatherDescription: 'soleil',
                        size: 40,
                      ),
                      const SizedBox(width: AppConstants.paddingMedium),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${day.maxTemp.round()}°',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${day.minTemp.round()}°',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getWeekday(int weekday) {
    switch (weekday) {
      case 1: return 'Lun';
      case 2: return 'Mar';
      case 3: return 'Mer';
      case 4: return 'Jeu';
      case 5: return 'Ven';
      case 6: return 'Sam';
      case 7: return 'Dim';
      default: return '';
    }
  }
} 