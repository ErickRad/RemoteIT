import 'importManager.dart';

class Connection {
  static late RawDatagramSocket udp;
  static late Datagram datagram;
  static late Point<int>? startMousePosition;

  static bool trustedDevice = false;
  static bool connected = false;

  static String addr = "";
  static List<String> message = [];   
  static String response = "";
  static String status = "Waiting for connection..."; 

  static int port = 5000;
  static final int BUFFER = 1024;

  static final String DISCOVER = 'DISCOVER_SERVER';
  static final String AVAILABLE = 'SERVER_AVAILABLE';
  static final String REQUEST = 'REQUEST_CONNECTION';
  static final String ACCEPT = 'CONNECTION_ACCEPTED';
  static final String DENY = 'CONNECTION_DENIED';

  static void generatePasscode() {
    const numbers = '0123456789';
    final random = Random();

    String randomChar(String chars) => chars[random.nextInt(chars.length)];

    String newPasscode = 
        '${randomChar(numbers)}${randomChar(numbers)}${randomChar(numbers)}${randomChar(numbers)}';

    Home.passcode = newPasscode;
  }

  static Future<void> connectToReceiver() async {
    udp = await RawDatagramSocket.bind(InternetAddress.anyIPv4, port);
    udp.broadcastEnabled = true;

    await for (RawSocketEvent event in udp) {
      if (event == RawSocketEvent.read) {
        datagram = udp.receive()!;
        message = utf8.decode(datagram.data).split("|");

        if (message[0] == DISCOVER) {
          response = "$AVAILABLE|${Home.hostname}|${Home.system}";

          udp.send(
            utf8.encode(response),
            InternetAddress("255.255.255.255"),
            port,
          );

        } else if (message[0] == REQUEST) {
          if (message[1] == Home.passcode) {
            addr = datagram.address.address;
            port = 5001 + Random().nextInt(2999);
            startMousePosition = await FlutterAutoGUI.position();

            response = "$ACCEPT|$port|${startMousePosition?.x}|${startMousePosition?.y}";

            udp.send(
              utf8.encode(response),
              InternetAddress(addr),
              5000,
            );

            udp.close();
            Connection.connected = true;
            await commandStream();
          }
        }
      }
    }
  }

  static Future<void> commandStream() async {
    udp = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      port,
    );

    while (Connection.connected) {
      await for (RawSocketEvent event in udp) {
        if (event == RawSocketEvent.read) {
          datagram = udp.receive()!;
          message = utf8.decode(datagram.data).split("|");

          switch (message[2]) {
            case 'move':
              FlutterAutoGUI.moveTo(
                point: Point(
                  int.parse(message[0]),
                  int.parse(message[1]),
                ),
              );
              break;

            case 'click':
              FlutterAutoGUI.click(
                button: MouseButton.left,
                clicks: 1,
              );
              break;

            case 'double':
              FlutterAutoGUI.click(
                button: MouseButton.left,
                clicks: 2,
              );
              break;

            case 'right':
              FlutterAutoGUI.click(
                button: MouseButton.right,
                clicks: 1,
              );
              break;
          }
          await Future.delayed(Duration(milliseconds: 10));
        }
      }
    }
  }

  static void closeConnection() {
    udp.close();
    Connection.connected = false;
  }
}
