import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class LivePreviewWidget extends StatefulWidget {
  final Map<String, dynamic>? selectedProduct;
  final double width;
  final double height;
  final String unit;
  final bool hasMosquitoNet;

  const LivePreviewWidget({
    super.key,
    this.selectedProduct,
    required this.width,
    required this.height,
    required this.unit,
    this.hasMosquitoNet = false,
  });

  @override
  State<LivePreviewWidget> createState() => _LivePreviewWidgetState();
}

class _LivePreviewWidgetState extends State<LivePreviewWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void didUpdateWidget(LivePreviewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedProduct != widget.selectedProduct ||
        oldWidget.width != widget.width ||
        oldWidget.height != widget.height) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'preview',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Live Preview',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
                if (widget.selectedProduct != null)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(
                              widget.selectedProduct!['category'] as String)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.selectedProduct!['category'] as String,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: _getCategoryColor(
                                widget.selectedProduct!['category'] as String),
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 2.h),

            // Preview Container
            Container(
              width: double.infinity,
              // made preview area larger per user request
              height: 34.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                ),
              ),
              child: widget.selectedProduct != null &&
                      widget.width > 0 &&
                      widget.height > 0
                  ? AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: CustomPaint(
                            // increase painter canvas to match container
                            size: Size(double.infinity, 34.h),
                            painter: ProductPreviewPainter(
                              product: widget.selectedProduct!,
                              width: widget.width,
                              height: widget.height,
                              unit: widget.unit,
                              hasMosquitoNet: widget.hasMosquitoNet,
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'visibility_off',
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.4),
                            size: 48,
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'Select product and enter dimensions\nto see live preview',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppTheme
                                      .lightTheme.colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                          ),
                        ],
                      ),
                    ),
            ),

            if (widget.selectedProduct != null &&
                widget.width > 0 &&
                widget.height > 0) ...[
              SizedBox(height: 2.h),

              // Dimensions Display
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildDimensionInfo('Width', widget.width, widget.unit),
                    Container(
                      width: 1,
                      height: 4.h,
                      color: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.3),
                    ),
                    _buildDimensionInfo('Height', widget.height, widget.unit),
                    Container(
                      width: 1,
                      height: 4.h,
                      color: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.3),
                    ),
                    _buildDimensionInfo('Area', _calculateArea(), 'sq ft'),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDimensionInfo(String label, double value, String unit) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.7),
              ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          '${value.toStringAsFixed(1)} $unit',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
        ),
      ],
    );
  }

  double _calculateArea() {
    double widthInFeet = widget.width;
    double heightInFeet = widget.height;

    // Convert to feet if necessary
    switch (widget.unit) {
      case 'inches':
        widthInFeet = widget.width / 12;
        heightInFeet = widget.height / 12;
        break;
      case 'cm':
        widthInFeet = widget.width / 30.48;
        heightInFeet = widget.height / 30.48;
        break;
    }

    return widthInFeet * heightInFeet;
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'aluminium':
        return Colors.grey.shade600;
      case 'pvc':
        return Colors.blue.shade600;
      case 'wooden':
        return Colors.brown.shade600;
      case 'glass':
        return Colors.cyan.shade600;
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class ProductPreviewPainter extends CustomPainter {
  final Map<String, dynamic> product;
  final double width;
  final double height;
  final String unit;
  final bool hasMosquitoNet;

  ProductPreviewPainter({
    required this.product,
    required this.width,
    required this.height,
    required this.unit,
    this.hasMosquitoNet = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.0;

    // outer frame paint (thicker to resemble sample)
    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..color = Colors.black87;

    // Calculate drawing dimensions
    final centerX = size.width / 2;
    final centerY = size.height / 2;
  // Allow the drawing to occupy a larger portion of the canvas so the
  // preview appears visually bigger.
  final maxWidth = size.width * 0.82;
  final maxHeight = size.height * 0.82;

    // Scale dimensions proportionally
    final aspectRatio = width / height;
    double drawWidth, drawHeight;

    if (aspectRatio > 1) {
      drawWidth = maxWidth;
      drawHeight = maxWidth / aspectRatio;
    } else {
      drawHeight = maxHeight;
      drawWidth = maxHeight * aspectRatio;
    }

    final rect = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: drawWidth,
      height: drawHeight,
    );

    // Get material color
    final materialColor = _getMaterialColor(product['category'] as String);
    paint.color = materialColor;

  // Draw an inner frame to create the visible white gap like the sample
  final innerFrame = rect.deflate(6);
  canvas.drawRRect(RRect.fromRectAndRadius(innerFrame, const Radius.circular(4)), Paint()..color = Colors.white);

  // Draw based on product template
    final template = _getProductTemplate(product['name'] as String);

    switch (template) {
      case 'door':
        _drawDoor(canvas, rect, paint, outlinePaint);
        break;
      case 'window':
        _drawWindow(canvas, rect, paint, outlinePaint);
        break;
      case 'cupboard':
        _drawCupboard(canvas, rect, paint, outlinePaint);
        break;
      default:
        _drawGeneric(canvas, rect, paint, outlinePaint);
    }

    // Draw dimensions
    _drawDimensions(canvas, rect, size);
    // For windows: show split widths below the main width text and
    // ensure mosquito net is drawn only on the right pane when split.
    if (template == 'window') {
      const double splitThreshold = 12.0;
      final bool shouldSplit = width > splitThreshold;

      if (shouldSplit) {
        // draw split widths below the full width label
        final textPainter = TextPainter(textDirection: TextDirection.ltr);
        final leftWidthValue = width / 2;
        final rightWidthValue = width - leftWidthValue;
        final leftText = '${leftWidthValue.toStringAsFixed(1)} $unit';
        final rightText = '${rightWidthValue.toStringAsFixed(1)} $unit';

        textPainter.text = TextSpan(
          text: leftText,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        );
        textPainter.layout();

        // position below the full width label
        final splitY = rect.bottom + 20 + 8 + 16;
        final leftX =
            rect.center.dx - (drawWidth / 4) - (textPainter.width / 2);
        textPainter.paint(canvas, Offset(leftX, splitY));

        textPainter.text = TextSpan(
          text: rightText,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        );
        textPainter.layout();
        final rightX =
            rect.center.dx + (drawWidth / 4) - (textPainter.width / 2);
        textPainter.paint(canvas, Offset(rightX, splitY));
      } else {
        // if not split and mosquito net selected, draw label on full rect
        if (hasMosquitoNet) {
          final textPainter = TextPainter(textDirection: TextDirection.ltr);
          textPainter.text = TextSpan(
            // text: 'Mosquito Net',
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          );
          textPainter.layout();
          textPainter.paint(
            canvas,
            Offset(rect.right - textPainter.width - 8, rect.top + 8),
          );
        }
      }
    }
  }

  void _drawMosquitoNetMesh(Canvas canvas, Rect rect) {
    final meshPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7
      ..color = Colors.black26;

    const int lines = 10;
    for (int i = 0; i <= lines; i++) {
      final dx = rect.left + (rect.width / lines) * i;
      canvas.drawLine(Offset(dx, rect.top), Offset(dx, rect.bottom), meshPaint);
    }
    for (int j = 0; j <= lines; j++) {
      final dy = rect.top + (rect.height / lines) * j;
      canvas.drawLine(Offset(rect.left, dy), Offset(rect.right, dy), meshPaint);
    }
  }

  void _drawDoor(Canvas canvas, Rect rect, Paint paint, Paint outlinePaint) {
    // Main door frame
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      outlinePaint,
    );

    // Door handle
    final handleRect = Rect.fromLTWH(
      rect.right - rect.width * 0.15,
      rect.center.dy - rect.height * 0.05,
      rect.width * 0.08,
      rect.height * 0.1,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(handleRect, const Radius.circular(4)),
      Paint()..color = Colors.black54,
    );

    // Door panels
    final panelPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.black38;

    final panel1 = Rect.fromLTWH(
      rect.left + rect.width * 0.1,
      rect.top + rect.height * 0.1,
      rect.width * 0.7,
      rect.height * 0.35,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(panel1, const Radius.circular(4)),
      panelPaint,
    );

    final panel2 = Rect.fromLTWH(
      rect.left + rect.width * 0.1,
      rect.top + rect.height * 0.55,
      rect.width * 0.7,
      rect.height * 0.35,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(panel2, const Radius.circular(4)),
      panelPaint,
    );
  }

  void _drawWindow(Canvas canvas, Rect rect, Paint paint, Paint outlinePaint) {
    // Main window frame
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      outlinePaint,
    );

    // Glass panes
    // stronger glass color and thicker divider to match sample
    final glassPaint = Paint()..color = Colors.lightBlue.withValues(alpha: 0.45);
    final dividerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.black87;

    // Determine if splitting is needed. Threshold is in same unit as provided width.
    const double splitThreshold = 12.0; // user can change this value as needed
    final bool shouldSplit = width > splitThreshold;

    // compute pane rects
    Rect leftPane, rightPane;
    if (shouldSplit) {
      // split into two equal panels with small gap
      final paneWidth = rect.width * 0.47;
      leftPane = Rect.fromLTWH(
        rect.left + rect.width * 0.03,
        rect.top + rect.height * 0.05,
        paneWidth,
        rect.height * 0.9,
      );
      rightPane = Rect.fromLTWH(
        leftPane.right + rect.width * 0.03,
        rect.top + rect.height * 0.05,
        paneWidth,
        rect.height * 0.9,
      );
    } else {
      // default two-pane layout as before
      leftPane = Rect.fromLTWH(
        rect.left + rect.width * 0.05,
        rect.top + rect.height * 0.05,
        rect.width * 0.42,
        rect.height * 0.9,
      );
      rightPane = Rect.fromLTWH(
        rect.left + rect.width * 0.53,
        rect.top + rect.height * 0.05,
        rect.width * 0.42,
        rect.height * 0.9,
      );
    }

    // Draw panes
    canvas.drawRect(leftPane, glassPaint);
    canvas.drawRect(leftPane, dividerPaint);

    canvas.drawRect(rightPane, glassPaint);
    canvas.drawRect(rightPane, dividerPaint);

    // Center divider (visual)
    canvas.drawLine(
      Offset((leftPane.right + rightPane.left) / 2, rect.top),
      Offset((leftPane.right + rightPane.left) / 2, rect.bottom),
      dividerPaint,
    );

    // If mosquito net selected, draw it only on the right pane
    if (hasMosquitoNet) {
      _drawMosquitoNetMesh(canvas, rightPane);
    }

    // Pane-level labels removed to avoid duplication; split widths are painted
    // below the full width in the main paint() flow.
  }

  void _drawCupboard(
      Canvas canvas, Rect rect, Paint paint, Paint outlinePaint) {
    // Main cupboard body
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      outlinePaint,
    );

    // Doors
    final doorPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.black54;

    // Left door
    final leftDoor = Rect.fromLTWH(
      rect.left + rect.width * 0.05,
      rect.top + rect.height * 0.05,
      rect.width * 0.42,
      rect.height * 0.9,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(leftDoor, const Radius.circular(4)),
      doorPaint,
    );

    // Right door
    final rightDoor = Rect.fromLTWH(
      rect.left + rect.width * 0.53,
      rect.top + rect.height * 0.05,
      rect.width * 0.42,
      rect.height * 0.9,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rightDoor, const Radius.circular(4)),
      doorPaint,
    );

    // Handles
    final handlePaint = Paint()..color = Colors.black87;

    // Left handle
    canvas.drawCircle(
      Offset(leftDoor.right - leftDoor.width * 0.15, leftDoor.center.dy),
      4,
      handlePaint,
    );

    // Right handle
    canvas.drawCircle(
      Offset(rightDoor.left + rightDoor.width * 0.15, rightDoor.center.dy),
      4,
      handlePaint,
    );
  }

  void _drawGeneric(Canvas canvas, Rect rect, Paint paint, Paint outlinePaint) {
    // Generic rectangular product
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      outlinePaint,
    );

    // Add some generic details
    final detailPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.black38;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(
          rect.left + rect.width * 0.1,
          rect.top + rect.height * 0.1,
          rect.right - rect.width * 0.1,
          rect.bottom - rect.height * 0.1,
        ),
        const Radius.circular(4),
      ),
      detailPaint,
    );
  }

  void _drawDimensions(Canvas canvas, Rect rect, Size canvasSize) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final dimensionPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 1.0;

    // Width dimension (bottom) - longer line and bigger ticks to match sample
    final widthY = rect.bottom + 26;
    canvas.drawLine(Offset(rect.left, widthY), Offset(rect.right, widthY), dimensionPaint);

    // Width end ticks
    const tickLen = 10.0;
    canvas.drawLine(Offset(rect.left, widthY - tickLen / 2), Offset(rect.left, widthY + tickLen / 2), dimensionPaint);
    canvas.drawLine(Offset(rect.right, widthY - tickLen / 2), Offset(rect.right, widthY + tickLen / 2), dimensionPaint);

    // Width text (bigger)
    textPainter.text = TextSpan(
      text: '${width.toStringAsFixed(1)} $unit',
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(rect.center.dx - textPainter.width / 2, widthY + 10));

    // Height dimension (right) - bigger ticks and larger rotated label
    final heightX = rect.right + 28;
    canvas.drawLine(Offset(heightX, rect.top), Offset(heightX, rect.bottom), dimensionPaint);

    // Height end ticks
    canvas.drawLine(Offset(heightX - tickLen / 2, rect.top), Offset(heightX + tickLen / 2, rect.top), dimensionPaint);
    canvas.drawLine(Offset(heightX - tickLen / 2, rect.bottom), Offset(heightX + tickLen / 2, rect.bottom), dimensionPaint);

    // Height text (rotated, larger)
    canvas.save();
    canvas.translate(heightX + 12, rect.center.dy);
    canvas.rotate(-1.5708); // -90 degrees
    textPainter.text = TextSpan(
      text: '${height.toStringAsFixed(1)} $unit',
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
    canvas.restore();
  }

  Color _getMaterialColor(String category) {
    switch (category.toLowerCase()) {
      case 'aluminium':
        return Colors.grey.shade300;
      case 'pvc':
        return Colors.white;
      case 'wooden':
        return Colors.brown.shade300;
      case 'glass':
        return Colors.lightBlue.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  String _getProductTemplate(String productName) {
    final name = productName.toLowerCase();
    if (name.contains('door')) return 'door';
    if (name.contains('window')) return 'window';
    if (name.contains('cupboard') || name.contains('cabinet'))
      return 'cupboard';
    return 'generic';
  }

  @override
  bool shouldRepaint(ProductPreviewPainter oldDelegate) {
    return oldDelegate.product != product ||
        oldDelegate.width != width ||
        oldDelegate.height != height ||
        oldDelegate.unit != unit ||
        oldDelegate.hasMosquitoNet != hasMosquitoNet;
  }
}
