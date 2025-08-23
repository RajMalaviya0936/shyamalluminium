import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class LivePreviewWidget extends StatefulWidget {
  final Map<String, dynamic>? selectedProduct;
  final double width;
  final double height;
  final String unit;

  const LivePreviewWidget({
    super.key,
    this.selectedProduct,
    required this.width,
    required this.height,
    required this.unit,
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
              height: 25.h,
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
                            size: Size(double.infinity, 25.h),
                            painter: ProductPreviewPainter(
                              product: widget.selectedProduct!,
                              width: widget.width,
                              height: widget.height,
                              unit: widget.unit,
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

  ProductPreviewPainter({
    required this.product,
    required this.width,
    required this.height,
    required this.unit,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.0;

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.black87;

    // Calculate drawing dimensions
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final maxWidth = size.width * 0.7;
    final maxHeight = size.height * 0.7;

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
    final glassPaint = Paint()..color = Colors.lightBlue.withValues(alpha: 0.3);
    final dividerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.black54;

    // Left pane
    final leftPane = Rect.fromLTWH(
      rect.left + rect.width * 0.05,
      rect.top + rect.height * 0.05,
      rect.width * 0.42,
      rect.height * 0.9,
    );
    canvas.drawRect(leftPane, glassPaint);
    canvas.drawRect(leftPane, dividerPaint);

    // Right pane
    final rightPane = Rect.fromLTWH(
      rect.left + rect.width * 0.53,
      rect.top + rect.height * 0.05,
      rect.width * 0.42,
      rect.height * 0.9,
    );
    canvas.drawRect(rightPane, glassPaint);
    canvas.drawRect(rightPane, dividerPaint);

    // Center divider
    canvas.drawLine(
      Offset(rect.center.dx, rect.top),
      Offset(rect.center.dx, rect.bottom),
      dividerPaint,
    );
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

    // Width dimension (bottom)
    final widthY = rect.bottom + 20;
    canvas.drawLine(
      Offset(rect.left, widthY),
      Offset(rect.right, widthY),
      dimensionPaint,
    );

    // Width arrows
    canvas.drawLine(
      Offset(rect.left, widthY - 5),
      Offset(rect.left, widthY + 5),
      dimensionPaint,
    );
    canvas.drawLine(
      Offset(rect.right, widthY - 5),
      Offset(rect.right, widthY + 5),
      dimensionPaint,
    );

    // Width text
    textPainter.text = TextSpan(
      text: '${width.toStringAsFixed(1)} $unit',
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        rect.center.dx - textPainter.width / 2,
        widthY + 8,
      ),
    );

    // Height dimension (right)
    final heightX = rect.right + 20;
    canvas.drawLine(
      Offset(heightX, rect.top),
      Offset(heightX, rect.bottom),
      dimensionPaint,
    );

    // Height arrows
    canvas.drawLine(
      Offset(heightX - 5, rect.top),
      Offset(heightX + 5, rect.top),
      dimensionPaint,
    );
    canvas.drawLine(
      Offset(heightX - 5, rect.bottom),
      Offset(heightX + 5, rect.bottom),
      dimensionPaint,
    );

    // Height text (rotated)
    canvas.save();
    canvas.translate(heightX + 8, rect.center.dy);
    canvas.rotate(-1.5708); // -90 degrees
    textPainter.text = TextSpan(
      text: '${height.toStringAsFixed(1)} $unit',
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );
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
        oldDelegate.unit != unit;
  }
}
