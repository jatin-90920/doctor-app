import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ayurvedic_doctor_crm/services/database_service.dart';
import 'package:ayurvedic_doctor_crm/services/patient_service.dart';
import 'package:ayurvedic_doctor_crm/services/treatment_service.dart';
import 'package:ayurvedic_doctor_crm/screens/home_screen.dart';
import 'package:ayurvedic_doctor_crm/utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database
  await DatabaseService.instance.database;
  
  runApp(const AyurvedicDoctorCRM());
}

class AyurvedicDoctorCRM extends StatelessWidget {
  const AyurvedicDoctorCRM({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PatientService()),
        ChangeNotifierProvider(create: (_) => TreatmentService()),
      ],
      child: MaterialApp(
        title: 'Ayurvedic Doctor CRM',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

