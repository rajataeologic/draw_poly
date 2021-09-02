class Location {
double _latitude = 0;
double _longitude = 0;

double get longitude => _longitude;

set longitude(double value) {
  _longitude = value;
}

double get latitude => _latitude;

set latitude(double value) {
  _latitude = value;
}

@override
  String toString() {
    return 'Location{_latitude: $_latitude, _longitude: $_longitude}'
        '';
  }
}
