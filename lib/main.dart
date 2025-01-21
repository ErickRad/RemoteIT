import 'importManager.dart';

void main(){
  runApp(RemoteIT());
}

class RemoteIT extends StatelessWidget{
  const RemoteIT({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: "Remote It!",
      home: Home(),
    );
  }
}
