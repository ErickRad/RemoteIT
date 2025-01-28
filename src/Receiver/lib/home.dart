import 'importManager.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  static String hostname = "";
  static String local_ip = "";
  static String system = "";
  static String passcode = "";
  static String status = ""; 
  static bool connected = false;
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  @override
  void initState() {
    getSystemInfo();
    Connection.generatePasscode();
    Connection.connectToReceiver();
    super.initState();
  }

  Future<void> updateStatus() async {
    while(true){
      setState(() {
        Home.status = Connection.status;
        Home.connected = Connection.connected; 
      });
    }
  }

  Future<void> getSystemInfo() async{
    for (var interface in await NetworkInterface.list()) {
      for (var ip in interface.addresses) {
        if (ip.type == InternetAddressType.IPv4 &&
            !ip.address.startsWith('127.')) {
          setState(() {
            Home.local_ip = ip.address;
            Home.hostname = Platform.localHostname;
            Home.system = Platform.operatingSystem.toLowerCase();
          });
          break;
        }
      }
    }
  }
  AppBar homeTopBar() {
    return AppBar(
      backgroundColor: Scheme.FRONT,
      title: const Text(
        'Remote It Receiver',
        style: TextStyle(
          fontSize: Sizes.PRIMARY_TEXT,
          color: Scheme.WIDGETS
        ),
      ),
      actions: [
        Row(
          children: [
            Text(
              Connection.connected ? 'Connected' : 'Not connected',
              style: const TextStyle(
                fontSize: Sizes.SECONDARY_TEXT,
                color: Scheme.WIDGETS
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.circle,
              color: Connection.connected ? Colors.green : Colors.red,
              size: 14,
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget homeBody() {
    return Expanded(
      child: Container(
        color: Scheme.BACK,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoCard('HOSTNAME: ${Home.hostname}'),
                      const SizedBox(height: 16),
                      _infoCard('IP: ${Home.local_ip}'),
                      const SizedBox(height: 16),
                      _infoCard('PASSCODE: ${Home.passcode}'),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    width: 1,
                    height: 180,
                    color: Scheme.WIDGETS,
                  ),
                  const Spacer(),
                  Container(
                    child: QrImageView(
                      data: Home.passcode,
                      version: QrVersions.auto,
                      size: 150.0,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget homeBottomBar() {
    return Column(
      children: [
        Container(
          alignment: Alignment.bottomCenter,
          width: double.infinity,
          height: Sizes.ICON,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Scheme.GRAY,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            border: Border.all(
              color: Scheme.GRAY,
              width: 0,
            ),
          ),
          child: Text(
            !Connection.connected ? "Waiting for connection ..." : "Connected",
            style: TextStyle(
              color: Scheme.WIDGETS,
              fontSize: Sizes.PRIMARY_TEXT,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoCard(String text) {
    return Container(
      width: 300,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Scheme.GRAY,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          decoration: TextDecoration.none,
          color: Colors.white,
          fontSize: Sizes.SECONDARY_TEXT,
        ),
      ),
    );
  }

  @override
  void dispose() {
    Connection.closeConnection();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container( 
      color: Scheme.BACK,
      child: Column(
        children: [
          homeTopBar(),
          homeBody(),
          homeBottomBar(),
        ],
      )
    );
  }
}
