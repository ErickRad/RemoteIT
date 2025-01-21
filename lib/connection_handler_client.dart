import 'importManager.dart';


class ConnectionHandler {
  static Socket? _socket;

  static Future discoverServer() async {
    RawDatagramSocket? udpSocket;

    try {
      udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      udpSocket.broadcastEnabled = true;

      udpSocket.send(
        utf8.encode(discoverMessage),
        InternetAddress("255.255.255.255"),
        broadcastPort,
      );

      await for (var event in udpSocket.timeout(timeout)) {
        if (event == RawSocketEvent.read) {
          final datagram = udpSocket.receive();

          if (datagram != null) {
            final response = utf8.decode(datagram.data).split("|");

            if (response[0].startsWith(responseMessage)) {
              return _ServerResponse(
                success: true, 
                serverIp: datagram.address.address, 
                hostname:  response[1],
                system: response[2],
                pass: response[3]
              );
            }
          }
        }
      }
      return _ServerResponse(success: false, errorMessage: "No response received.");
      
    } catch (e) {
      return _ServerResponse(success: false, errorMessage: "No response received.");
    } finally {
      udpSocket?.close();
    }
  }

  static Future<bool> connectToServer(String serverIp) async {
    const int serverPort = 5000;

    try {
      _socket = await Socket.connect(serverIp, serverPort);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> sendRequestConnection(String serverIp) async {
    RawDatagramSocket? udpSocket;

    try {
      udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      udpSocket.broadcastEnabled = true;

      udpSocket.send(
        utf8.encode(requestConnectionMessage),
        InternetAddress(serverIp),
        broadcastPort,
      );

      await for (var event in udpSocket.timeout(timeout)) {
        if (event == RawSocketEvent.read) {
          final datagram = udpSocket.receive();

          if (datagram != null) {
            final response = utf8.decode(datagram.data);
            if (response == acceptConnectionMessage) {
              connected = true;
            }
          }
        }
      }
    } catch (e) {
      connected = false;
    } finally {
      udpSocket?.close();
    }
  }
}

class _ServerResponse {
  final bool success;
  final String? serverIp;
  final String? hostname;
  final String? system;
  final String? pass;
  final String? errorMessage;

  _ServerResponse({required this.success, this.serverIp, this.hostname, this.system, this.pass, this.errorMessage});
}
