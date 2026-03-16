import 'package:admin/constants.dart';
import 'package:admin/controllers/MenuController.dart' as admin;
import 'package:admin/controllers/Auth.dart'; // Importe seu novo controller
import 'package:admin/controllers/OS.dart';
//import 'package:admin/models/OrdemServico.dart';
import 'package:admin/screens/main/main_screen.dart';
import 'package:admin/screens/login/login.dart';
import 'package:admin/screens/ordens/components/orders_details.dart';
//import 'package:admin/services/firestore_service.dart';
import 'package:firebase_core/firebase_core.dart'; // Adicione isto
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:admin/firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  // 1. Garante que os widgets estejam prontos antes do Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicializa o Firebase (Certifique-se de ter configurado o google-services.json)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // final firestoreService = FirestoreService();
  // Configura como lidar com mensagens recebidas com app aberto
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    // Aqui você pode disparar um alerta interno no app
    print(
        "Notificação recebida em primeiro plano: ${message.notification?.title}");
  });

  setupNotifications();
  await dotenv.load(fileName: ".env");

  runApp(MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void setupNotifications() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Recebi uma mensagem: ${message.notification?.title}');
    if (navigatorKey.currentContext != null) {
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(
          content: Text(
              "${message.notification?.title}: ${message.notification?.body}"),
          backgroundColor: Colors.orangeAccent,
        ),
      );
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('Usuário abriu o app pela notificação!');
    // Aqui você pode navegar direto para a tela da OS
    navigatorKey.currentState?.push(MaterialPageRoute(
        builder: (_) => OSDetailsScreen(os: message.data['osId'])));
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // 3. Colocamos os Providers aqui no topo para serem globais
      providers: [
        ChangeNotifierProvider(create: (context) => admin.MenuController()),
        ChangeNotifierProvider(create: (context) => AuthController()),
        ChangeNotifierProvider(create: (context) => OScontroller()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'SunSystem - SunCity',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: bgColor,
          textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
              .apply(bodyColor: Colors.white),
          canvasColor: secondaryColor,
        ),
        // 4. Lógica de Rota: Se estiver logado vai para Main, senão Login
        home: Consumer<AuthController>(
          builder: (context, auth, _) {
            if (auth.user != null) {
              return MainScreen();
            }
            return LoginView();
          },
        ),
      ),
    );
  }
}
