import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'services/auth.dart';
import 'screens/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'models/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: StreamProvider<CustomUser>.value(
        value: AuthService().user,
        child: OverlaySupport(child: MaterialApp(home: Wrapper())),
      )
    );
  }
}
