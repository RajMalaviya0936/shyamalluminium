import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CustomerDetailsWidget extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final String? nameError;
  final String? phoneError;
  final String? addressError;

  const CustomerDetailsWidget({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.addressController,
    this.nameError,
    this.phoneError,
    this.addressError,
  });

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
                  iconName: 'person',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Customer Details',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Customer Name *',
                hintText: 'Enter customer name',
                prefixIcon: Icon(
                  Icons.person_outline,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
                errorText: nameError,
              ),
              textCapitalization: TextCapitalization.words,
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
            ),
            SizedBox(height: 2.h),
            TextFormField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number *',
                hintText: 'Enter phone number',
                prefixIcon: Icon(
                  Icons.phone_outlined,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
                errorText: phoneError,
              ),
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(15),
              ],
            ),
            SizedBox(height: 2.h),
            TextFormField(
              controller: addressController,
              decoration: InputDecoration(
                labelText: 'Address *',
                hintText: 'Enter customer address',
                prefixIcon: Icon(
                  Icons.location_on_outlined,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
                errorText: addressError,
              ),
              textCapitalization: TextCapitalization.sentences,
              keyboardType: TextInputType.streetAddress,
              textInputAction: TextInputAction.done,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
