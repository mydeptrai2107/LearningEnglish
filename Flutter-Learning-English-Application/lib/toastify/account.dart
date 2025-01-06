import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart'; // Đảm bảo bạn đã thêm gói toastification vào pubspec.yaml

void showSuccessToast({
  required BuildContext context,
  required String title,
  required String description,
}) {
  toastification.show(
    context: context,
    type: ToastificationType.success,
    style: ToastificationStyle.fillColored,
    autoCloseDuration: const Duration(seconds: 5),
    title: Text(title),
    description: RichText(
      text: TextSpan(text: description),
    ),
  );
}

void showErrorToast({
  required BuildContext context,
  required String title,
  required String description,
}) {
  toastification.show(
    context: context,
    type: ToastificationType.error,
    style: ToastificationStyle.flatColored,
    autoCloseDuration: const Duration(seconds: 5),
    title: Text(title),
    description: RichText(
      text: TextSpan(text: description, style: TextStyle(color: Colors.black)),
    ),
  );
}
