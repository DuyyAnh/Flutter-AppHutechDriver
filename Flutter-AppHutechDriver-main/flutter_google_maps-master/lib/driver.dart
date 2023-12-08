import 'package:flutter/material.dart';
import 'package:flutter_google_maps/detailTrip.dart';
import 'package:flutter_google_maps/token.dart';
import 'package:flutter_google_maps/trip.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class DriverPage extends StatefulWidget {
  @override
  _DriverPageState createState() => _DriverPageState();
}

class _DriverPageState extends State<DriverPage> {
  List<Trip> trips = [];
  String selectedStatus = 'Chưa nhận';
  int driverId = 0;

  // Map to group statuses together
  Map<String, List<String>> statusGroups = {
    'Chưa nhận': ['Chưa nhận'],
    'Đã nhận': [
      'Đã nhận đơn',
      'Đang chạy',
      'Hoàn thành'
    ], // Add other statuses you want to include
  };

  // Filtered trips based on selected status
  List<Trip> get filteredTrips {
    return selectedStatus == 'Chưa nhận'
        ? trips.where((trip) => trip.status == 'Chưa nhận').toList()
        : trips
            .where((trip) =>
                trip.status != 'Chưa nhận' && trip.driverId == driverId)
            .toList();
  }

  @override
  void initState() {
    super.initState();
    getAllTrip();
    decodetoken(TokenManager.getToken());
  }

  Future<void> getDetailTrip(int id) async {
    final response = await http.get(
      Uri.parse('https://10.0.2.2:7145/api/Trip/GetDetailTrip?id=$id'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => DetailTripPage(tripId: id)));
    }
  }

  Future<void> decodetoken(String Token) async {
    final response = await http.post(
      Uri.parse('https://10.0.2.2:7145/api/Auth/DecodeToken?token=$Token'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      setState(() {
        driverId = int.parse(responseData['userId']);
      });
    } else {
      debugPrint("Error: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");
    }
  }

  Future<void> getAllTrip() async {
    final response = await http.get(
      Uri.parse('https://10.0.2.2:7145/api/Trip/GetAllTrips'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> tripData = json.decode(response.body);
      setState(() {
        trips = tripData.map((data) => Trip.fromJson(data)).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
        title: Padding(
          padding: const EdgeInsets.all(50.0),
          child: Text('Danh sách đơn đặt xe'),
        ),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: statusGroups.keys.map((status) {
              return ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedStatus = status;
                  });
                },
                style: ElevatedButton.styleFrom(
                  primary: status == selectedStatus ? Colors.blue : null,
                ),
                child: Text(status),
              );
            }).toList(),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredTrips.length,
              itemBuilder: (context, index) {
                final trip = filteredTrips[index];
                final timeBookString = trip.timeBook;
                final timeBookDateTime = DateTime.parse(timeBookString);
                final formattedDateTime =
                    DateFormat('dd-MM-yyyy HH:mm').format(timeBookDateTime);
                final startLocation = trip.startLocation.substring(0, 16);
                final endLocation = trip.endLocation.substring(0, 16);

                return Card(
                  child: ListTile(
                    leading: Icon(Icons.person),
                    title: Text('Chuyến đi lúc $formattedDateTime',
                        style: TextStyle(fontSize: 20)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            '$startLocation - $endLocation, style: TextStyle(fontSize: 20)'),
                        Text('Giá: ${trip.price} đ',
                            style: TextStyle(fontSize: 20)),
                      ],
                    ),
                    trailing: Icon(Icons.arrow_forward),
                    onTap: () async {
                      await getDetailTrip(trip.tripId);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
