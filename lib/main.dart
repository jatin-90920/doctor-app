import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ayurvedic_doctor_crm/services/database_service.dart';
import 'package:ayurvedic_doctor_crm/services/patient_service.dart';
import 'package:ayurvedic_doctor_crm/services/treatment_service.dart';
import 'package:ayurvedic_doctor_crm/widgets/notification_widget.dart';
import 'package:ayurvedic_doctor_crm/widgets/responsive_navigation.dart';
import 'package:ayurvedic_doctor_crm/utils/enhanced_app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize database
  // await DatabaseService.instance.database;
    if (!kIsWeb) {
    await DatabaseService.instance.database;
  }

  runApp(const AyurvedicDoctorCRM());
}

class AyurvedicDoctorCRM extends StatelessWidget {
  const AyurvedicDoctorCRM({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PatientService()),
        ChangeNotifierProvider(
          create: (_) {
            final treatmentService = TreatmentService();
            // Start listening to real-time updates
            treatmentService.startListeningToTreatments();
            return treatmentService;
          },
        ),
        ChangeNotifierProvider(create: (_) => NotificationService()),
      ],
      child: MaterialApp(
        title: 'Doctor CRM',
        theme: EnhancedAppTheme.lightTheme,
        darkTheme: EnhancedAppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const ResponsiveNavigationWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
