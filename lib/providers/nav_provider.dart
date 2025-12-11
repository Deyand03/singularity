import 'package:flutter_riverpod/legacy.dart';

// Ini remotenya. Default-nya 0 (Beranda)
final navIndexProvider = StateProvider<int>((ref) => 0);
final selectedCategoryProvider = StateProvider<String>((ref) => "Semua");