import 'package:flutter/material.dart';
import 'package:bytequeens_adm/app.dart';
import 'package:bytequeens_adm/services/ad_service.dart';
import 'package:bytequeens_adm/services/iap_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize AdMob
  await AdService().initialize();
  
  // Initialize In-App Purchase
  await IAPService().initialize();
  
  runApp(const MyApp());
}
