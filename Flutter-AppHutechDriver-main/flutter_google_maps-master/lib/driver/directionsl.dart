import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:async';
import 'package:flutter_google_maps/driver/directiontrip.dart';
class DirectionPage extends StatefulWidget {
  final int tripId;
  final int driverId;
  final String startLocation;
  final String locationIP;

  DirectionPage({required this.tripId,required this.driverId,required this.startLocation,required this.locationIP});
  @override
  _DirectionPageState createState() => _DirectionPageState();
}
class _DirectionPageState extends State<DirectionPage> {
  Set<Marker> _markers = Set<Marker>();
  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polygonLatLngs = <LatLng>[];
  Completer<GoogleMapController> _controller = Completer();
  String distance = "";
  String time = "";
  final String key = 'AIzaSyDQ2c_pOSOFYSjxGMwkFvCVWKjYOM9siow';
   void updatePolylines(List<LatLng> points) {
    setState(() {
      _polylines.clear();
      _polylines.add(Polyline(
        polylineId: PolylineId('route'),
        points: points,
        color: Colors.green,
        width: 5,
      ));
    });
  }
  @override
  void initState() {
    super.initState();
     _setMarker(LatLng(10.776889, 106.700897));
    if (_controller.isCompleted) {
    direction();
    } else {
    _controller.future.then((GoogleMapController controller) {
      direction();
    });
  }
  }
   void _setMarker(LatLng point) {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId('marker'),
          position: point,
        ),
      );
    });
  }
  LatLng convertStringToLatLng(String ip) {
  List<String> coordinates = ip.split(',');
  double latitude = double.parse(coordinates[0]);
  double longitude = double.parse(coordinates[1]);
  return LatLng(latitude, longitude);
}
  LatLngBounds boundsFromLatLngList(List<LatLng> list) {
    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLng = double.infinity;
    double maxLng = -double.infinity;

    for (final latLng in list) {
      if (latLng.latitude < minLat) {
        minLat = latLng.latitude;
      }
      if (latLng.latitude > maxLat) {
        maxLat = latLng.latitude;
      }
      if (latLng.longitude < minLng) {
        minLng = latLng.longitude;
      }
      if (latLng.longitude > maxLng) {
        maxLng = latLng.longitude;
      }
    }
      return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }
  void direction() async{
      LatLng startlocation = convertStringToLatLng(widget.locationIP);
      List<Location> destinationLocations = await locationFromAddress(widget.startLocation);
      if (destinationLocations.isNotEmpty) {
          // Lấy tọa độ từ danh sách kết quả
          final destinationLocation = destinationLocations.first;
          var polylinePoints = PolylinePoints();
          PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
            key, // Thay bằng API Key của bạn
            PointLatLng(startlocation.latitude,startlocation.longitude), // Tọa độ điểm đi
            PointLatLng(
                destinationLocation.latitude,
                destinationLocation
                .longitude), // Tọa độ điểm đến
                travelMode: TravelMode
                .driving, // Hoặc sử dụng travelMode tùy chọn
            );
            if (result.points.isNotEmpty) {
                List<LatLng> routeCoords = result.points.map((point) => 
                                        LatLng(point.latitude, point.longitude))
                                        .toList();
                updatePolylines(routeCoords);
                LatLngBounds bounds = boundsFromLatLngList(routeCoords);
                // Tạo một CameraUpdate để di chuyển và zoom bản đồ đến khu vực tuyến đường
                CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 100); 
                distance = result.distance.toString();         
                time = result.duration.toString();     
                final GoogleMapController controller = await _controller.future;
                controller.animateCamera(cameraUpdate);
                _markers.clear();
                _markers.add(Marker(
                markerId: MarkerId('destination'),
                position: LatLng(destinationLocation.latitude,destinationLocation.longitude),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ));
        }
      }
    }
    @override
    Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chỉ đường'),
      ),
      body: Column(
        children: [
          // Đặt GoogleMap ở đầu tiên để nó chiếm hết không gian còn lại
          Expanded(
            child: GoogleMap(
              onMapCreated: (controller) {
                _controller.complete(controller);
              },
              initialCameraPosition: CameraPosition(
                target: LatLng(10.776889, 106.700897),
                zoom: 12.0,
              ),
              markers: _markers,
              polylines: _polylines,
            ),
          ),
          // Giao diện hiển thị thông tin quãng đường và nút
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Hiển thị thông tin quãng đường và thời gian
                Text(                  
                  '$distance\n$time',
                  style: TextStyle(fontSize: 25.0),
                ),
                // Nút để thực hiện hành động gì đó (ví dụ: hiển thị thông tin chi tiết)
                ElevatedButton(
                  onPressed: () {
                       Navigator.push(context,
                      MaterialPageRoute(builder: (context) => DirectionNextPage(tripId: widget.tripId)));
                  },
                  child: Text('Xem đường đi tiếp theo'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}