import 'package:customer/themes/app_colors.dart';
import 'package:customer/themes/responsive.dart';
import 'package:customer/utils/DarkThemeProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LocationView extends StatelessWidget {
  final String? sourceLocation;
  final String? destinationLocation;

  const LocationView(
      {super.key, this.sourceLocation, this.destinationLocation});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            const SizedBox(height: 4),
            Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                    color: themeChange.getThem()
                        ? AppColors.darkContainerBackground
                        : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: themeChange.getThem()
                            ? Colors.white
                            : const Color(0xff092d5c),
                        width: 3))),
            Dash(
                direction: Axis.vertical,
                length: Responsive.height(7, context),
                dashLength: 4,
                dashColor: Colors.grey.shade400),
            Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                    color: themeChange.getThem()
                        ? AppColors.darkContainerBackground
                        : Colors.white,
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: const Color(0xff22B55E), width: 3))),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("PICKUP".tr,
                  style: GoogleFonts.poppins(
                      color: themeChange.getThem()
                          ? Colors.white
                          : const Color(0xff092d5c),
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(sourceLocation.toString(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: themeChange.getThem()
                          ? Colors.white
                          : Colors.black87)),
              SizedBox(height: Responsive.height(2.5, context)),
              Text("DROP-OFF".tr,
                  style: GoogleFonts.poppins(
                      color: const Color(0xff22B55E),
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(destinationLocation.toString(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: themeChange.getThem()
                          ? Colors.white
                          : Colors.black87)),
            ],
          ),
        )
      ],
    );
  }

  int calculateLineWraps({
    required String text,
    required TextStyle textStyle,
    required double maxWidth,
  }) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
      maxLines: null, // Allow unlimited lines
    )..layout(maxWidth: maxWidth);
    return textPainter.computeLineMetrics().length;
  }
}
