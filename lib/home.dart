import 'importManager.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  GyroscopeEvent? _gyroscopeEvent;
  Offset _startPosition = Offset.zero;
  Offset _currentPosition = Offset.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
              Spacer(),
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
              child: GestureDetector(
                onPanEnd: (details) {
                  setState(() {
                    _currentPosition = Offset.zero;
                  });
                },
                onPanStart: (details) {
                  setState(() {
                    _startPosition = details.localPosition;
                  });
                },
                onPanUpdate: (details) {
                  setState(() {
                    _currentPosition = details.localPosition;
                  });
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
                      'X: ${_currentPosition.dx.toStringAsFixed(2)}\nY: ${_currentPosition.dy.toStringAsFixed(2)}',
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
          alignment: Alignment.bottomCenter,
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Scheme.GRAY,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(50),
              topRight: Radius.circular(50),
            ),
            border: Border.all(
              color: Scheme.GRAY,
              width: 0
            )
          ),
          child: TextButton(
            child: !connected 
            ? Text(
              "Connect Device",
              style: TextStyle(
                color: Scheme.WIDGETS,
                fontSize: Sizes.PRIMARY_TEXT,
                decoration: TextDecoration.none,
              ),
            ) : Text(
              "${hostnames[0]}",
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
        Container(
          width: double.infinity,
          alignment: Alignment.topCenter,
          child: TextButton(
            child: Text("",
              style: TextStyle(
                color: Scheme.WIDGETS,
                fontSize: Sizes.SECONDARY_TEXT,
                decoration: TextDecoration.none,
              ),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => Connect())
              );
            },
          ),
          height: Sizes.ICON / 1.5,
          decoration: BoxDecoration(
            color: Scheme.GRAY,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50),
            ),
            border: Border.all(
              color: Scheme.GRAY,
              width: 0
            )
          ),
        )
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
