import 'importManager.dart';

bool connected = false;
bool foundDevices = false;

List<String> respondingIps = [];
List<String> hostnames = [];
List<String> systems = [];
List<String> passcodes = [];


const int broadcastPort = 5001;
const String discoverMessage = "DISCOVER_SERVER";
const String responseMessage = "SERVER_AVAILABLE";
const String requestConnectionMessage = "REQUEST_CONNECTION";
const String acceptConnectionMessage = "ACCEPT_CONNECTION";
const Duration timeout = Duration(seconds: 5);

class Scheme{
  static const Color BACK = Color.fromARGB(255, 27, 27, 36);
  static const Color FRONT = Color.fromARGB(255, 23, 23, 30);
  static const Color NULL = Color.fromARGB(0, 0, 0, 0);
  static const Color WIDGETS = Color.fromARGB(255, 221, 221, 221);
  static const Color GRAY = Color.fromARGB(255, 49, 49, 64);
}

class Sizes{
  static const double ICON = 45;
  static const double PRIMARY_TEXT = 22;
  static const double SECONDARY_TEXT = 16; 
} 

