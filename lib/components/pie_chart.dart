import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:money_wise/viewmodels/finance/finance_viewmodel.dart';
import 'package:provider/provider.dart';

// class PieChartSample2 extends StatefulWidget {
//   const PieChartSample2({super.key});

//   @override
//   State<StatefulWidget> createState() => PieChart2State();
// }

// class PieChart2State extends State<PieChartSample2> {
//   int touchedIndex = -1;

//   @override
//   Widget build(BuildContext context) {
//     final viewModel = Provider.of<FinanceViewModel>(context);
//     final colorScheme = Theme.of(context).colorScheme;

//     if (viewModel.isLoading) {
//       return Center(
//         child: CircularProgressIndicator(color: colorScheme.primary),
//       );
//     }

//     final categoryTotals = viewModel.groupedCategorySpending;

//     if (categoryTotals.isEmpty) {
//       return Center(
//         child: Text(
//           "No data for this range",
//           style: TextStyle(color: colorScheme.onSurfaceVariant),
//         ),
//       );
//     }

//     final entries = categoryTotals.entries.toList();
//     final double totalSpending = categoryTotals.values.fold(
//       0,
//       (sum, item) => sum + item,
//     );

//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         SizedBox(
//           width: 160.r,
//           height: 160.r,
//           child: PieChart(
//             PieChartData(
//               pieTouchData: PieTouchData(
//                 touchCallback: (FlTouchEvent event, pieTouchResponse) {
//                   setState(() {
//                     if (!event.isInterestedForInteractions ||
//                         pieTouchResponse == null ||
//                         pieTouchResponse.touchedSection == null) {
//                       touchedIndex = -1;
//                       return;
//                     }
//                     touchedIndex =
//                         pieTouchResponse.touchedSection!.touchedSectionIndex;
//                   });
//                 },
//               ),
//               borderData: FlBorderData(show: false),
//               sectionsSpace: 2,
//               centerSpaceRadius: 30.r,
//               sections: _getPieChartSections(entries, totalSpending),
//             ),
//           ),
//         ),

//         SizedBox(width: 20.w),
//         Flexible(
//           child: ConstrainedBox(
//             constraints: BoxConstraints(maxWidth: 160.w),
//             child: ListView.builder(
//               shrinkWrap: true,
//               physics: const BouncingScrollPhysics(),
//               itemCount: entries.length,
//               itemBuilder: (context, index) {
//                 return _buildLegendItem(
//                   entries[index],
//                   index,
//                   touchedIndex == index,
//                 );
//               },
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   List<PieChartSectionData> _getPieChartSections(
//     List<MapEntry<String, double>> entries,
//     double totalSpending,
//   ) {
//     return List.generate(entries.length, (i) {
//       final entry = entries[i];
//       final isTouched = i == touchedIndex;
//       final double percentage = (entry.value / totalSpending) * 100;

//       final double radius = isTouched ? 45.r : 35.r;
//       final bool showTitle = percentage > 5.0;

//       return PieChartSectionData(
//         color: _getColor(i),
//         value: entry.value,
//         title: showTitle ? '${percentage.toStringAsFixed(0)}%' : '',
//         radius: radius,
//         titleStyle: TextStyle(
//           fontSize: isTouched ? 12.sp : 10.sp,
//           fontWeight: FontWeight.bold,
//           color: Colors.white,
//           shadows: const [Shadow(color: Colors.black26, blurRadius: 2)],
//         ),
//       );
//     });
//   }

//   Widget _buildLegendItem(
//     MapEntry<String, double> entry,
//     int index,
//     bool isTouched,
//   ) {
//     final formatter = NumberFormat.currency(
//       locale: 'id_ID',
//       symbol: 'Rp ',
//       decimalDigits: 0,
//     );
//     final colorScheme = Theme.of(context).colorScheme;

//     return Padding(
//       padding: EdgeInsets.only(bottom: 12.h),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // The Color Dot
//           Container(
//             width: 12.r,
//             height: 12.r,
//             margin: EdgeInsets.only(top: 4.h),
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: _getColor(index),
//               border: isTouched
//                   ? Border.all(color: colorScheme.onSurface, width: 1.5)
//                   : null,
//             ),
//           ),
//           SizedBox(width: 8.w),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   entry.key,
//                   style: TextStyle(
//                     fontSize: 12.sp,
//                     fontWeight: isTouched ? FontWeight.bold : FontWeight.w600,
//                     // White/Black if touched, soft muted adaptive grey if not
//                     color: isTouched
//                         ? colorScheme.onSurface
//                         : colorScheme.onSurfaceVariant,
//                   ),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 SizedBox(height: 2.h),

//                 FittedBox(
//                   fit: BoxFit.scaleDown,
//                   alignment: Alignment.centerLeft,
//                   child: Text(
//                     formatter.format(entry.value),
//                     style: TextStyle(
//                       fontSize: 11.sp,
//                       color: colorScheme.onSurfaceVariant,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Color _getColor(int index) {
//   //   final colorScheme = Theme.of(context).colorScheme;
//   //   final isDark = Theme.of(context).brightness == Brightness.dark;
//   //   final primaryBlue = colorScheme.primary;

//   //   if (isDark) {
//   //     final double stepRatio = (index * 0.22).clamp(0.0, 0.65);
//   //     return Color.lerp(primaryBlue, Colors.white, stepRatio)!;
//   //   } else {
//   //     final double stepRatio = (index * 0.30).clamp(0.0, 0.5);
//   //     return Color.lerp(primaryBlue, Colors.white, stepRatio)!;
//   //   }
//   // }

//   Color _getColor(int index) {
//     final colorScheme = Theme.of(context).colorScheme;
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final primaryBlue = colorScheme.primary;

//     final hsv = HSVColor.fromColor(primaryBlue);

//     final List<Color> lightPalette = [
//       primaryBlue, // 0: Food & Drinks (Base Royal Blue)
//       Color.lerp(
//         primaryBlue,
//         Colors.teal.shade700,
//         0.45,
//       )!, // 1: Transport (Deep Emerald Teal)
//       Color.lerp(
//         primaryBlue,
//         Colors.indigo.shade800,
//         0.6,
//       )!, // 2: Shopping (Rich Midnight Indigo)
//       Color.lerp(
//         primaryBlue,
//         Colors.cyan.shade700,
//         0.5,
//       )!, // 3: Entertainment (Electric Cyan)
//       Color.lerp(
//         primaryBlue,
//         Colors.deepPurple.shade600,
//         0.4,
//       )!, // 4: Bills & Utilities (Royal Purple)
//       Color.lerp(
//         primaryBlue,
//         Colors.blue.shade300,
//         0.4,
//       )!, // 5: Health (Bright Sky Blue)
//       Color.lerp(
//         primaryBlue,
//         Colors.blueGrey.shade400,
//         0.6,
//       )!, // 6: Income/Salary (Clean Cool Slate)
//       Colors.grey.shade400, // 7: Others (Muted Balance Grey)
//     ];

//     final List<Color> darkPalette = [
//       primaryBlue, // 0: Food & Drinks
//       hsv
//           .withHue((hsv.hue - 25) % 360)
//           .withValue(0.95)
//           .toColor(), // 1: Transport (Neon Teal-Blue)
//       hsv
//           .withHue((hsv.hue + 25) % 360)
//           .withValue(0.90)
//           .toColor(), // 2: Shopping (Electric Indigo)
//       hsv
//           .withHue((hsv.hue - 45) % 360)
//           .withValue(1.0)
//           .toColor(), // 3: Entertainment (Bright Cyan)
//       hsv
//           .withHue((hsv.hue + 45) % 360)
//           .withValue(0.85)
//           .toColor(), // 4: Bills & Utilities (Pastel Purple)
//       Color.lerp(
//         primaryBlue,
//         Colors.white,
//         0.45,
//       )!, // 5: Health (Vivid Ice Blue)
//       hsv
//           .withSaturation(0.35)
//           .withValue(0.90)
//           .toColor(), // 6: Income/Salary (Metallic Platinum)
//       Colors.grey.shade500, // 7: Others (Muted Charcoal Grey)
//     ];

//     // Safety guardrail to fetch from the clean color arrays without breaking
//     final List<Color> selectedPalette = isDark ? darkPalette : lightPalette;
//     return selectedPalette[index.clamp(0, selectedPalette.length - 1)];
//   }
// }

class PieChartSample2 extends StatefulWidget {
  const PieChartSample2({super.key});

  @override
  State<StatefulWidget> createState() => PieChart2State();
}

class PieChart2State extends State<PieChartSample2> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<FinanceViewModel>(context);
    final colorScheme = Theme.of(context).colorScheme;

    if (viewModel.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: colorScheme.primary),
      );
    }

    final categoryTotals = viewModel.groupedCategorySpending;

    if (categoryTotals.isEmpty) {
      return Center(
        child: Text(
          "No data for this range",
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
      );
    }

    final entries = categoryTotals.entries.toList();
    final double totalSpending = categoryTotals.values.fold(
      0,
      (sum, item) => sum + item,
    );

    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 160.r,
              height: 160.r,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex = pieTouchResponse
                            .touchedSection!
                            .touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 2,
                  centerSpaceRadius: 50.r,
                  sections: _getPieChartSections(entries, totalSpending),
                ),
              ),
            ),

            IgnorePointer(
              child: SizedBox(
                width: 84.r,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        touchedIndex == -1
                            ? "TOTAL SPENT"
                            : entries[touchedIndex].key,
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.6,
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.75,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 3.h),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        touchedIndex == -1
                            ? formatter.format(totalSpending)
                            : '${((entries[touchedIndex].value / totalSpending) * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: touchedIndex == -1 ? 13.sp : 18.sp,
                          fontWeight: FontWeight.bold,
                          color: touchedIndex == -1
                              ? colorScheme.onSurface
                              : _getColor(touchedIndex),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        SizedBox(width: 20.w),
        Flexible(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 160.w),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                return _buildLegendItem(
                  entries[index],
                  index,
                  touchedIndex == index,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _getPieChartSections(
    List<MapEntry<String, double>> entries,
    double totalSpending,
  ) {
    return List.generate(entries.length, (i) {
      final entry = entries[i];
      final isTouched = i == touchedIndex;
      final double radius = isTouched ? 24.r : 16.r;

      return PieChartSectionData(
        color: _getColor(i),
        value: entry.value,
        title: '',
        radius: radius,
      );
    });
  }

  Widget _buildLegendItem(
    MapEntry<String, double> entry,
    int index,
    bool isTouched,
  ) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12.r,
            height: 12.r,
            margin: EdgeInsets.only(top: 4.h),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getColor(index),
              border: isTouched
                  ? Border.all(color: colorScheme.onSurface, width: 1.5)
                  : null,
            ),
          ),
          SizedBox(width: 8.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  entry.key,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: isTouched ? FontWeight.bold : FontWeight.w600,
                    color: isTouched
                        ? colorScheme.onSurface
                        : colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),

                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    formatter.format(entry.value),
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor(int index) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryBlue = colorScheme.primary;

    final double ratio = (index / 7.0).clamp(0.0, 1.0);

    if (isDark) {
      const electricCyan = Color(0xFF00F5D4);
      return Color.lerp(primaryBlue, electricCyan, ratio)!;
    } else {
      const royalVelvetPurple = Color(0xFF7209B7);
      return Color.lerp(primaryBlue, royalVelvetPurple, ratio)!;
    }
  }

  //HIGH CONTRAST
  // Color _getColor(int index) {
  //   final colorScheme = Theme.of(context).colorScheme;
  //   final isDark = Theme.of(context).brightness == Brightness.dark;
  //   final primaryBlue = colorScheme.primary;

  //   // Linear ratio from 0.0 to 1.0 across the 8 items
  //   final double ratio = (index / 7.0).clamp(0.0, 1.0);

  //   if (isDark) {
  //     const midPointColor = Color(0xFFD000FF);
  //     const endPointColor = Color(0xFF00F5D4);

  //     if (ratio < 0.5) {
  //       return Color.lerp(primaryBlue, midPointColor, ratio * 2.0)!;
  //     } else {
  //       return Color.lerp(midPointColor, endPointColor, (ratio - 0.5) * 2.0)!;
  //     }
  //   } else {
  //     const midPointColor = Color(0xFF009688);
  //     const endPointColor = Color(0xFF6A0DAD);

  //     if (ratio < 0.5) {
  //       return Color.lerp(primaryBlue, midPointColor, ratio * 2.0)!;
  //     } else {
  //       return Color.lerp(midPointColor, endPointColor, (ratio - 0.5) * 2.0)!;
  //     }
  //   }
  // }
}
