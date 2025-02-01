import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapPickerDialog extends StatelessWidget {
  final LatLng? currentPosition;

  MapPickerDialog({this.currentPosition});

  @override
  Widget build(BuildContext context) {
    LatLng? selectedPosition = currentPosition;

    return Dialog(
      child: Container(
        height: 400,
        child: FlutterMap(
          options: MapOptions(
            center: currentPosition ?? LatLng(37.7749, -122.4194), // Default San Francisco
            zoom: 14.0,
            onTap: (_, LatLng position) {
              selectedPosition = position; // Aggiorna la posizione selezionata
              Navigator.of(context).pop(selectedPosition); // Restituisci la posizione selezionata
            },
          ),
          layers: [
            TileLayerOptions(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: ['a', 'b', 'c'],
            ),
            MarkerLayerOptions(
              markers: [
                if (selectedPosition != null)
                  Marker(
                    point: selectedPosition!,
                    builder: (context) => Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
