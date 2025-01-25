import 'importManager.dart';

class Connection {
  static late RawDatagramSocket udp;
  
  static bool foundDevice = false;
  static bool validPasscode = false;
  static bool trustedDevice = false;

  static String hostname = "";
  static String addr = "";
  static String mac = "";
  static List<String> message = [];   
  static String response = ""; 
  
  static int port = 5000;
  static final int BUFFER = 1024;

  static final String DISCOVER = 'DISCOVER_SERVER';
  static final String AVAILABLE = 'SERVER_AVAILABLE';
  static final String REQUEST = 'REQUEST_CONNECTION';
  static final String ACCEPT = 'CONNECTION_ACCEPTED';
  static final String DENY = 'CONNECTION_DENIED';

  static List<String> respondingIps = [];
  static List<String> hostnames = [];
  static List<String> systems = [];
  static List<String> scannedDevices = [];
  

  static Future<Response> discover() async {
    udp = await RawDatagramSocket.bind(InternetAddress.anyIPv4, port);
    udp.broadcastEnabled = true;

    udp.send(
      utf8.encode(DISCOVER),
      InternetAddress("255.255.255.255"),
      port,
    );

    await for (RawSocketEvent? event in udp){
      if (event == RawSocketEvent.read) {
        Datagram datagram = udp.receive()!;
        message = utf8.decode(datagram.data).split("|");

        if (message[0] == AVAILABLE) {
          addr = datagram.address.address;
          return Response(
            success: true,
            serverIp: addr,
            hostname: message[1],
            system: message[2],
            errorMessage: ""
          );
        }
      }
    }
    return Response(
      success: false,
      serverIp: "",
      hostname: "",
      system: "", 
      errorMessage: "No server found");
  }

  static Future<bool> connect(String passcode) async {
    udp = await RawDatagramSocket.bind(InternetAddress.anyIPv4, port);
    udp.broadcastEnabled = true;

    response = "$REQUEST|$passcode";
    
    udp.send(
      utf8.encode(response),
      InternetAddress("255.255.255.255"),
      port,
    );

    await for (RawSocketEvent? event in udp){
      if (event == RawSocketEvent.read) {
        Datagram datagram = udp.receive()!;
        message = utf8.decode(datagram.data).split("|");

        if (message[0] == ACCEPT) {
          validPasscode = bool.parse(message[1]);
          mac = message[2];
          port = int.tryParse(message[3])!;
          Home.screenWidth = double.parse(message[4]);
          Home.screenWidth = double.parse(message[5]);
          Home.cursorX = double.parse(message[6]);
          Home.cursorY = double.parse(message[7]);

          udp.close();

          udp = await RawDatagramSocket.bind(
            InternetAddress("255.255.255.255"),
            port,
          );
          return true;

        }else if (message[0] == DENY){
          validPasscode = bool.parse(message[1]);
        }
      }
    }
    return false;
  }

  static void sendCommands(double x, double y, String action){
    response = "$x|$y|$action";
    udp.send(
      utf8.encode(response),
      InternetAddress(addr),
      port,
    ); 
  }

  static void closeConnection(){
    udp.close();
  }
}

class Response {
  final bool success;
  final String serverIp;
  final String hostname;
  final String system;
  final String errorMessage;

  Response({required this.success, required this.serverIp, required this.hostname, required this.system, required this.errorMessage});
}
