import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

class DescriptionField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const DescriptionField({
    super.key,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          maxLines: 4,
          minLines: 3,
          textCapitalization: TextCapitalization.sentences,
          keyboardType: TextInputType.multiline,
          inputFormatters: [
            LengthLimitingTextInputFormatter(500),
          ],
          decoration: InputDecoration(
            hintText: 'Enter product description (optional)',
            alignLabelWithHint: true,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 4.w,
              vertical: 2.h,
            ),
          ),
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}
