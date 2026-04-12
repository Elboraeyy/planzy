import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planzy/data/database/isar/isar_service.dart';

// Centralised IsarService provider
final isarServiceProvider = Provider((ref) => IsarService());
