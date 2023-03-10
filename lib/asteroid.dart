import 'package:asteroid/dialog.dart';
import 'package:asteroid/models.dart';
import 'package:flutter/material.dart';

import 'service.dart';

const _padding = EdgeInsets.all(8.0);

class Asteroid extends StatefulWidget {
  const Asteroid({super.key});

  @override
  State<Asteroid> createState() => _AsteroidState();
}

class _AsteroidState extends State<Asteroid> {
  final service = AsteroidService();

  var dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 7)),
    end: DateTime.now(),
  );
  var isLoading = true;

  AsteroidModel? asteroidModel;

  @override
  void initState() {
    super.initState();
    fetchAsteroids();
  }

  TextTheme get textTheme => Theme.of(context).textTheme;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.rocket_launch_rounded),
            SizedBox(width: 7.5),
            Text('Asteroid'),
          ],
        ),
      ),
      body: SizedBox.expand(
        child: Padding(
          padding: _padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: _padding,
                child: Text(
                  'Select a Date Range',
                  style: textTheme.titleMedium?.copyWith(
                    decoration: TextDecoration.underline,
                    decorationThickness: 1.5,
                  ),
                ),
              ),
              Row(
                children: [
                  buildDateContainer(dateRange.start),
                  buildDateContainer(dateRange.end),
                ],
              ),
              const Divider(),
              BodyContent(
                isLoading: isLoading,
                asteroidModel: asteroidModel,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Visibility(
        visible: !isLoading,
        child: FloatingActionButton.extended(
          icon: const Icon(Icons.search_rounded, size: 20),
          label: const Text('Find Asteroids'),
          onPressed: fetchAsteroids,
        ),
      ),
    );
  }

  Widget buildDateContainer(DateTime date) {
    return Expanded(
      child: Card(
        child: GestureDetector(
          onTap: selectDateRange,
          child: Container(
            height: 62.5,
            alignment: Alignment.center,
            child: Text(
              yMMMdFormat.format(date),
              style: textTheme.titleMedium,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> selectDateRange() async {
    final selectedRange = await context.showDateRange(dateRange);
    if (selectedRange == null) return;

    setState(() => dateRange = selectedRange);
  }

  Future<void> fetchAsteroids() async {
    setState(() => isLoading = true);

    try {
      final model = await service.fetchAsteroids(
        startDate: dateRange.start,
        endDate: dateRange.end,
      );
      setState(() => asteroidModel = model);
    } catch (e) {
      context.showSnackBar(e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }
}

class BodyContent extends StatelessWidget {
  const BodyContent({
    super.key,
    required this.isLoading,
    required this.asteroidModel,
  });
  final bool isLoading;
  final AsteroidModel? asteroidModel;

  @override
  Widget build(BuildContext context) {
    Widget child = const Center(child: CircularProgressIndicator.adaptive());

    if (!isLoading && asteroidModel != null) {
      child = ListView.builder(
        itemBuilder: buildItem,
        itemCount: asteroidModel!.items.length,
        padding: const EdgeInsets.symmetric(vertical: 10),
      );
    }
    return Expanded(child: child);
  }

  Widget buildItem(BuildContext context, int index) {
    final textTheme = Theme.of(context).textTheme;
    final entry = asteroidModel!.items.entries.toList()[index];
    final formattedDate = yMMMdFormat.format(yMdFormat.parse(entry.key));

    return Card(
      child: Padding(
        padding: _padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(formattedDate, style: textTheme.titleLarge),
            const SizedBox(height: 7.5),
            Text(
              'Asteroids',
              style: textTheme.titleMedium?.copyWith(
                decoration: TextDecoration.underline,
              ),
            ),
            for (var asteroid in entry.value)
              ListTile(
                dense: true,
                title: Text(asteroid.name),
                subtitle: Text(
                  'Diameter ${asteroid.minDiameterInMeters.toStringAsFixed(2)} - '
                  '${asteroid.maxDiameterInMeters.toStringAsFixed(2)} meters',
                ),
                trailing: Visibility(
                  visible: asteroid.isHazardous,
                  child: const Tooltip(
                    message: 'Hazardous!',
                    child: Icon(
                      Icons.dangerous_rounded,
                      color: Colors.deepPurpleAccent,
                      size: 18,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
