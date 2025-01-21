import 'connection_handler_client.dart';
import 'importManager.dart';


class Connect extends StatefulWidget {
  const Connect({super.key});
  
  @override
  State<Connect> createState() => _ConnectState();
}

class _ConnectState extends State<Connect> {

  @override 
  void initState() {
    super.initState();
  }
  void _searchForReceiver() async{
    final result = await ConnectionHandler.discoverServer();
    try {
      setState(() {
        if (result.success) {
          foundDevices = true;
          if(!respondingIps.contains(result.serverIp)){
            respondingIps.add(result.serverIp ?? "Unknown"); 
            hostnames.add(result.hostname ?? "Unknown");
            systems.add(result.system ?? "generic");
            passcodes.add(result.pass);
          }
        }
      });
    } catch (e) {
      stdout.write(e);
    }
  }

  Widget connectTopBar() {
    return Column(
      children: [
        Container(
          height: Sizes.PRIMARY_TEXT * 2,
          color: Scheme.FRONT,
        ),
        Container(
          height: Sizes.PRIMARY_TEXT * 3,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          color: Scheme.FRONT,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Connect",
                style: TextStyle(
                  color: Scheme.WIDGETS,
                  fontSize: Sizes.PRIMARY_TEXT,
                  decoration: TextDecoration.none,
                ),
              ),
              const Spacer(),
              OutlinedButton(
                style: ButtonStyle(
                  minimumSize: WidgetStatePropertyAll(const Size(150, 40)),
                ),
                child: Text(
                  "Scan",
                  style: TextStyle(
                    fontSize: Sizes.PRIMARY_TEXT,
                    color: Scheme.WIDGETS,
                  ),
                ),
                onPressed: () async {
                  _searchForReceiver();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget connectBody() {
    return Expanded(
      child: Container(
        color: Scheme.BACK,
        alignment: Alignment.center,
        child: !foundDevices
        ? Container(
          child: Icon(
            Icons.devices,
            size: Sizes.ICON + 200,
            color: const Color.fromARGB(255, 50, 50, 50),
          ),
        )
        : Container(
          color: Scheme.BACK,
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for(int i = 0; i < respondingIps.length; i++) ... [
                Container(
                  child: TextButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        systems[i] == "windows" 
                        ? Icon(
                          Icons.window_sharp,
                          size: Sizes.ICON,
                          color: Scheme.WIDGETS,
                        )
                        : Image.asset(
                          "assets/images/linuxLogo.png",
                          scale: 45,
                        ),
                        Spacer(),
                        Text(
                          hostnames[i],
                          style: TextStyle(
                            color: Scheme.WIDGETS,
                            fontSize: Sizes.SECONDARY_TEXT
                          ),
                        ),
                        Spacer(),
                        Text(
                          respondingIps[i],
                          style: TextStyle(
                            color: Scheme.WIDGETS,
                            fontSize: Sizes.PRIMARY_TEXT
                          ),
                        )
                      ],
                    ),
                    onPressed: () async {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          String inputPasscode = '';
                          return AlertDialog(
                            backgroundColor: Scheme.BACK,
                            title: const Text(
                              'Enter Passcode',
                              style: TextStyle(
                                color: Scheme.WIDGETS,
                                fontSize: Sizes.PRIMARY_TEXT
                              ),
                            ),
                            content: TextField(
                              cursorColor: Scheme.WIDGETS,

                              onChanged: (value) {
                                inputPasscode = value;
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(15))
                                ),
                                hintText: 'Enter the passcode from PC',
                                hintStyle: TextStyle(
                                  color: Scheme.WIDGETS,
                                  fontSize: Sizes.SECONDARY_TEXT - 2
                                ),
                              ),
                              style: TextStyle(
                                color: Scheme.WIDGETS,
                                fontSize: Sizes.SECONDARY_TEXT 
                              ),
                            ),
                            actions: [
                              TextButton(
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: Scheme.WIDGETS,
                                    fontSize: Sizes.SECONDARY_TEXT
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: const Text(
                                  'Submit',
                                  style: TextStyle(
                                    color: Scheme.WIDGETS,
                                    fontSize: Sizes.SECONDARY_TEXT
                                  ),
                                ),
                                onPressed: () {
                                  if (inputPasscode == passcodes[i]) {
                                    Navigator.of(context).pop();
                                    ConnectionHandler.sendRequestConnection(respondingIps[i]);
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          backgroundColor: Scheme.BACK,
                                          title: const Text(
                                            'Success',
                                            style: TextStyle(color: Scheme.WIDGETS),
                                          ),
                                          content: const Text(
                                            'Connected successfully!',
                                            style: TextStyle(color: Scheme.WIDGETS),
                                          ),
                                          actions: [
                                            TextButton(
                                              child: const Text(
                                                'OK',
                                                style: TextStyle(color: Scheme.WIDGETS),
                                              ),
                                              onPressed: () {
                                                Navigator.of(context).push(MaterialPageRoute(builder:(context) => Home()));
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                    setState(() {
                                      connected = true; 
                                    });
                                  } else {
                                    Navigator.of(context).pop();

                                    // Exibe a mensagem de erro
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          backgroundColor: Scheme.BACK,
                                          title: const Text(
                                            'Error',
                                            style: TextStyle(color: Scheme.WIDGETS),
                                          ),
                                          content: const Text(
                                            'Incorrect passcode!',
                                            style: TextStyle(color: Scheme.WIDGETS),
                                          ),
                                          actions: [
                                            TextButton(
                                              child: const Text(
                                                'OK',
                                                style: TextStyle(color: Scheme.WIDGETS),
                                              ),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  decoration: BoxDecoration(
                    color: Scheme.FRONT,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Scheme.WIDGETS,
                      width: 2
                    )
                  )
                )
              ]
            ],
          ) 
        )
      )
    );
  }

  Widget connectBottomBar() {
    return Column(
      children: [
        Container(
          color: Scheme.GRAY,
          alignment: Alignment.topCenter,
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 10),
          child: TextButton(
            child: Icon(
              Icons.swipe_up,
              color: Scheme.WIDGETS,  
              size: Sizes.ICON,
            ),
            onPressed: () {
             
            },
          ),
        ),
        Container(
          color: Scheme.GRAY,
          width: double.infinity,
          alignment: Alignment.topCenter,
          child: TextButton(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(
                  flex: 10,
                ),
                Icon(
                  Icons.qr_code,
                  color: Scheme.WIDGETS,
                  size: Sizes.ICON,
                ),
                Spacer(
                  flex: 1,
                ),
                Text("Scan QR Code",
                  style: TextStyle(
                    color: Scheme.WIDGETS,
                    fontSize: Sizes.PRIMARY_TEXT,
                    decoration: TextDecoration.none,
                  ),
                ),
                Spacer(
                  flex: 10,
                )
              ]
            ),
            onPressed: () {
              
            },
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _searchForReceiver();
    return Column(
      children: [
        connectTopBar(),
        connectBody(),
        connectBottomBar()
      ],
    );
  }
}