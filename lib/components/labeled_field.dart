import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LabeledField extends StatelessWidget {
  final String label;
  final Widget child;
  final bool isRequired;
  final bool showAsterisk;
  final EdgeInsetsGeometry? margin;

  const LabeledField({
    super.key,
    required this.label,
    required this.child,
    this.isRequired = true,
    this.showAsterisk = true,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: margin ?? EdgeInsets.only(bottom: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              text: label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14.sp,
                color: colorScheme.onSurfaceVariant,
              ),
              children: [
                if (isRequired && showAsterisk)
                  TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                else if (!isRequired && !showAsterisk)
                  TextSpan(
                    text: ' (Optional)',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.normal,
                    ),
                  )
                else
                  TextSpan(
                    text: ' ',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 6.h),
          child,
        ],
      ),
    );
  }
}
