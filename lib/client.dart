import 'package:ntucool/ntucool.dart';

class AppClient extends Client {
  AppClient();

  void dispose() {
    close();
  }
}
