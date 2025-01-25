import 'importManager.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  static double cursorX = 0.0; 
  static double cursorY = 0.0;
  static double screenWidth = 0.0;
  static double screenHeigth = 0.0;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late GyroscopeEvent _gyroscopeEvent;

  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;

  bool useGyroscope = false;

  double _currentPositionGestureX = 0.0;
  double _currentPositionGestureY = 0.0; 
  double _currentPositionGyroscopeX = 0.0;
  double _currentPositionGyroscopeY = 0.0;

  String x = "0.00";
  String y = "0.00";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    stopSensorControl();
    Connection.closeConnection();
    super.dispose();
  }
  
  void startSensorControl() {
    _gyroscopeSubscription = gyroscopeEventStream(
      samplingPeriod: Duration(milliseconds: 20),
    ).listen((GyroscopeEvent event) {
      setState(() {
        _currentPositionGyroscopeX += event.z * -50;
        _currentPositionGyroscopeY += event.x * -50;
        Connection.sendCommands(
            Home.cursorX + _currentPositionGyroscopeX,
            Home.cursorY + _currentPositionGyroscopeY, 
            "move"
          );
      });
    });
  }

  void stopSensorControl() {
    _gyroscopeSubscription?.cancel();
    _gyroscopeSubscription = null;
  }

  Widget homeTopBar() {
    return Column(
      children: [
        Container(
          height: Sizes.ICON / 1.5,
          color: Scheme.FRONT,
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          color: Scheme.FRONT,
          child: Row(
            children: [
              Text(
                "Remote It!",
                style: TextStyle(
                    color: Scheme.WIDGETS,
                    fontSize: Sizes.PRIMARY_TEXT,
                    decoration: TextDecoration.none),
              ),
              Spacer(flex: 15),
              Text(
                "Sensors",
                style: TextStyle(
                    color: Scheme.WIDGETS,
                    fontSize: Sizes.SECONDARY_TEXT,
                    decoration: TextDecoration.none),
              ),
              Spacer(flex: 1),
              GestureDetector(
                child: Container(
                  width: Sizes.ICON * 1.5,
                  height: Sizes.ICON / 1.5,
                  decoration: BoxDecoration(
                    color: !useGyroscope 
                    ? Scheme.FRONT
                    : Scheme.ENABLED,
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(
                      color: Scheme.WIDGETS,
                      width: 1
                    )
                  ),
                  child: !useGyroscope 
                  ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Spacer(flex: 1),
                      Icon(
                          Icons.circle,
                          color: Scheme.WIDGETS,
                          size: Sizes.ICON / 2,
                      ),
                      Spacer(flex: 10)
                    ],
                  )
                  : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Spacer(flex: 10),
                      Icon(
                          Icons.circle,
                          color: Scheme.WIDGETS,
                          size: Sizes.ICON / 2,
                      ),
                      Spacer(flex: 1)
                    ],
                  ),
                ),
                onTap: () {
                  setState(() {
                    if (!useGyroscope) {
                      useGyroscope = true;
                      _currentPositionGyroscopeX = _currentPositionGestureX;
                      _currentPositionGyroscopeY = _currentPositionGestureY;
                      startSensorControl();

                    } else {
                      useGyroscope = false;
                      _currentPositionGestureX = _currentPositionGyroscopeX;
                      _currentPositionGestureY = _currentPositionGyroscopeY;
                      stopSensorControl();
                      
                    }
                  });
                },    
              ),
              Spacer(flex: 3),
              IconButton(
                icon: Icon(
                  Icons.settings,
                  size: Sizes.ICON,
                  color: Scheme.WIDGETS,
                ),
                onPressed: () {},
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget homeBody() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: RawGestureDetector(
                gestures: {
                  TapGestureRecognizer: GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
                    () => TapGestureRecognizer(),
                    (instance) {
                      instance.onTap = () {
                        Connection.sendCommands(
                          Home.cursorX + _currentPositionGestureX, 
                          Home.cursorY + _currentPositionGestureY, 
                          "click"
                        );
                      };
                    },
                  ),
                  DoubleTapGestureRecognizer: GestureRecognizerFactoryWithHandlers<DoubleTapGestureRecognizer>(
                    () => DoubleTapGestureRecognizer(),
                    (instance) {
                      instance.onDoubleTap = () {
                        Connection.sendCommands(
                          Home.cursorX + _currentPositionGestureX, 
                          Home.cursorY + _currentPositionGestureY,
                          "double"
                        );
                      };
                    },
                  ),
                  LongPressGestureRecognizer: GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
                    () => LongPressGestureRecognizer(),
                    (instance) {
                      instance.onLongPress = () {
                        Connection.sendCommands(
                          Home.cursorX + _currentPositionGestureX, 
                          Home.cursorY + _currentPositionGestureY,
                          "right"
                        );
                      };
                    },
                  ),
                  PanGestureRecognizer: GestureRecognizerFactoryWithHandlers<PanGestureRecognizer>(
                    () => PanGestureRecognizer(),
                    (instance) {
                      instance.onUpdate = (details) {
                        setState(() {
                          _currentPositionGestureX += details.delta.dx.toDouble() * 2;
                          _currentPositionGestureY += details.delta.dy.toDouble() * 2;

                          x = _currentPositionGestureX.toStringAsFixed(2);
                          y = _currentPositionGestureY.toStringAsFixed(2);

                        });
                        Connection.sendCommands(
                            Home.cursorX + _currentPositionGestureX,
                            Home.cursorY + _currentPositionGestureY,
                            "move",
                          );
                      };
                      instance.onEnd = (_) {
                        setState(() {
                          x = "0.00";
                          y = "0.00";
                        });
                      };
                    },
                  ),
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Scheme.FRONT,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Scheme.WIDGETS,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'X: $x\nY: $y',
                      style: TextStyle(
                        color: Scheme.WIDGETS,
                        fontSize: Sizes.PRIMARY_TEXT,
                        decoration: TextDecoration.none,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: GestureDetector(
                      onTap: () {
                        Connection.sendCommands(
                          Home.cursorX + _currentPositionGestureX,
                          Home.cursorY + _currentPositionGestureY,
                          "click"
                        );  
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Scheme.FRONT,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Scheme.WIDGETS,
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            "Left Button",
                            style: TextStyle(
                              color: Scheme.WIDGETS,
                              fontSize: Sizes.SECONDARY_TEXT,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    flex: 4,
                    child: GestureDetector(
                      onTap: () {
                        Connection.sendCommands(
                          Home.cursorX + _currentPositionGestureX,
                          Home.cursorY + _currentPositionGestureY,
                          "right"
                        );  
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Scheme.FRONT,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Scheme.WIDGETS,
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            "Right Button",
                            style: TextStyle(
                              color: Scheme.WIDGETS,
                              fontSize: Sizes.SECONDARY_TEXT,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget homeBottomBar() {
    return Column(
      children: [
        Container(
          height: Sizes.ICON * 2,
          alignment: Alignment.center,
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Scheme.GRAY,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(45),
              topRight: Radius.circular(45),
            ),
            border: Border.all(
              color: Scheme.GRAY,
              width: 0
            )
          ),
          child: TextButton(
            child: Connection.hostname == "" 
            ? Text(
              "Connect Device",
              style: TextStyle(
                color: Scheme.WIDGETS,
                fontSize: Sizes.PRIMARY_TEXT,
                decoration: TextDecoration.none,
              ),
            ) : Text(
              "${Connection.hostname}",
              style: TextStyle(
                color: Scheme.WIDGETS,
                fontSize: Sizes.PRIMARY_TEXT,
                decoration: TextDecoration.none,
              ),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => Connect())
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        homeTopBar(),
        homeBody(),
        homeBottomBar(),
      ],
    );
  }
}