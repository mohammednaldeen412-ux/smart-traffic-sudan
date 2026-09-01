import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_traffic_sudan/core/theme/app_colors.dart';
import 'package:smart_traffic_sudan/core/theme/app_theme.dart';
import 'package:smart_traffic_sudan/widgets/skeleton_loader.dart';
import 'package:smart_traffic_sudan/widgets/success_animation.dart';
import 'package:smart_traffic_sudan/widgets/sudan_plate_widget.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    GoogleFonts.config.allowRuntimeFetching = false;
    await initializeDateFormatting('ar', null);
  });

  Widget createTestWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(body: child),
      ),
    );
  }

  testWidgets('SudanPlateWidget renders plate number and sovereign badge', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SudanPlateWidget(
            plateNumber: '48291',
            stateCode: 'خ',
            categoryCode: '5',
          ),
        ),
      ),
    );

    expect(find.text('48291'), findsOneWidget);
    expect(find.text('السودان'), findsOneWidget);
    expect(find.text('الخرطوم'), findsOneWidget);
  });

  testWidgets('SkeletonLoader renders animated gradient placeholders and list', (tester) async {
    await tester.pumpWidget(
      createTestWidget(
        Column(
          children: [
            const SkeletonLoader.circle(size: 40),
            const SkeletonLoader.rectangle(width: 100, height: 20),
            SkeletonLoader.list(count: 2),
          ],
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(SkeletonLoader), findsWidgets);
  });

  testWidgets('SuccessCheckmarkAnimation renders CustomPaint properly', (tester) async {
    await tester.pumpWidget(
      createTestWidget(
        const SuccessCheckmarkAnimation(size: 80),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(SuccessCheckmarkAnimation), findsOneWidget);
  });

  testWidgets('AppColors contains dark and light sovereign theme colors', (tester) async {
    expect(AppColors.goldPrimary, isNotNull);
    expect(AppColors.background, isNotNull);
    expect(AppColors.lightBackground, isNotNull);
    expect(AppColors.goldDark, isNotNull);
  });
}
