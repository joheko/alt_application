import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'db/database_helper.dart';
import 'models/asa_exposure.dart';

void main() {
  // Alustetaan tietokantatehdas ffi:lle.
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  runApp(ASAAltistumisetSovellus());
}

class ASAAltistumisetSovellus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ASA Altistumiset',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ASAAltistumiset(),
    );
  }
}

class ASAAltistumiset extends StatefulWidget {
  @override
  _ASAAltistumisetState createState() => _ASAAltistumisetState();
}

class _ASAAltistumisetState extends State<ASAAltistumiset> {
  DatabaseHelper databaseHelper = DatabaseHelper.instance;
  List<AsaExposure> exposureList = [];
  TextEditingController dateController = TextEditingController();
  TextEditingController hoursController = TextEditingController(); // Tuntien syöttökentän ohjain
  TextEditingController minutesController = TextEditingController(); // Minuuttien syöttökentän ohjain
  TextEditingController notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    updateListView(); // Päivitetään näkymä alustettaessa.
  }

  // Funktio, joka laskee yhteen altistumisajat yhdeltä vuodelta
  String calculateTotalExposure(List<AsaExposure> exposures) {
    Duration totalDuration = Duration();
    for (var exposure in exposures) {
      try {
        final parts = exposure.duration.split(':');
        if (parts.length == 2) {
          final hours = int.tryParse(parts[0]) ?? 0;
          final minutes = int.tryParse(parts[1]) ?? 0;
          totalDuration += Duration(hours: hours, minutes: minutes);
        }
      } catch (e) {
        print('Invalid duration format: ${exposure.duration}');
      }
    }
    int hours = totalDuration.inHours;
    int minutes = totalDuration.inMinutes.remainder(60);
    return '$hours t $minutes min';
  }

  // Funktio altistumisen muokkaamiseen
  void _editExposure(AsaExposure exposure) {
    dateController.text = exposure.date;
    final parts = exposure.duration.split(':');
    hoursController.text = parts[0];
    minutesController.text = parts[1];
    notesController.text = exposure.notes;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Muokkaa altistumista'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: dateController,
                  decoration: InputDecoration(labelText: 'Päivämäärä'),
                ),
                TextField(
                  controller: hoursController,
                  decoration: InputDecoration(labelText: 'Tunnit'),
                ),
                TextField(
                  controller: minutesController,
                  decoration: InputDecoration(labelText: 'Minuutit'),
                ),
                TextField(
                  controller: notesController,
                  decoration: InputDecoration(labelText: 'Muistiinpanot'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                dateController.clear();
                hoursController.clear();
                minutesController.clear();
                notesController.clear();
                Navigator.pop(context);
              },
              child: Text('Peruuta'),
            ),
            TextButton(
              onPressed: () {
                String hours = hoursController.text.isEmpty ? '0' : hoursController.text;
                String minutes = minutesController.text.isEmpty ? '0' : minutesController.text;

                AsaExposure updatedExposure = AsaExposure(
                  id: exposure.id,
                  date: dateController.text,
                  duration: '$hours:$minutes',
                  notes: notesController.text,
                );
                databaseHelper.updateExposure(updatedExposure);
                updateListView();
                dateController.clear();
                hoursController.clear();
                minutesController.clear();
                notesController.clear();
                Navigator.pop(context);
              },
              child: Text('Tallenna'),
            ),
          ],
        );
      },
    );
  }

  // Funktio altistumisen poistamiseen
  void _deleteExposure(AsaExposure exposure) async {
    if (exposure.id != null) {
      await databaseHelper.deleteExposure(exposure.id!);
      updateListView();
    }
  }

  // Päivitetään altistumisten lista tietokannasta
  void updateListView() async {
    final List<Map<String, dynamic>> exposureMapList = await databaseHelper.getExposureMapList();
    setState(() {
      exposureList = exposureMapList.map((exposureMap) => AsaExposure.fromMap(exposureMap)).toList();
    });
  }

  // Tallennetaan uusi altistuminen
  void _save() async {
    if (dateController.text.isNotEmpty) {
      String hours = hoursController.text.isEmpty ? '0' : hoursController.text;
      String minutes = minutesController.text.isEmpty ? '0' : minutesController.text;

      AsaExposure newExposure = AsaExposure(
        date: dateController.text,
        duration: '$hours:$minutes',
        notes: notesController.text,
      );
      await databaseHelper.insertExposure(newExposure);
      updateListView();
      dateController.clear();
      hoursController.clear();
      minutesController.clear();
      notesController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ASA Altistumiset'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: dateController,
              decoration: InputDecoration(labelText: 'Päivämäärä'),
            ),
            TextField(
              controller: hoursController, // Tuntien syöttökenttä
              decoration: InputDecoration(labelText: 'Tunnit'),
            ),
            TextField(
              controller: minutesController, // Minuuttien syöttökenttä
              decoration: InputDecoration(labelText: 'Minuutit'),
            ),
            TextField(
              controller: notesController,
              decoration: InputDecoration(labelText: 'Muistiinpanot'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _save,
              child: const Text('Tallenna'),
            ),
            SizedBox(height: 10),
            Text('Kokonaisaltistumisaika tänä vuonna: ${calculateTotalExposure(exposureList)}'),
            Expanded(
              child: ListView.builder(
                itemCount: exposureList.length,
                itemBuilder: (context, index) {
                  final exposure = exposureList[index];
                  return Card(
                    child: ListTile(
                      title: Text('${exposure.date} - ${exposure.duration}'),
                      subtitle: Text(exposure.notes),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              _editExposure(exposure);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              _deleteExposure(exposure);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
