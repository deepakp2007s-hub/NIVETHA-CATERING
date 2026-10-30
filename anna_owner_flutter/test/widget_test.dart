
import 'package:flutter_test/flutter_test.dart';
import 'package:anna_owner_flutter/core/theme/app_theme.dart';

void main() {
  group('Anna Owner App Tests', () {
    test('App theme uses Material 3', () {
      expect(AppTheme.light.useMaterial3, isTrue);
    });

    test('App theme has correct brand colors', () {
      expect(AppTheme.light.scaffoldBackgroundColor, AppTheme.background);
      expect(AppTheme.light.colorScheme.primary, AppTheme.navy);
      expect(AppTheme.light.colorScheme.secondary, AppTheme.gold);
    });
  });
}
