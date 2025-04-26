import 'package:design_hub/screens/customer_signup_screen.dart';
import 'package:design_hub/screens/designer_signup_screen.dart';
import 'package:flutter/material.dart';

class CustomerOrDesignerPopup {
  static String? selectedValue = 'customer';

  static Future<void> showPopup(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return popup(context);
      },
    );
  }

  static Widget popup(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      title: Text('Register as'),
      content: StatefulBuilder(builder: (context, setState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile(
              activeColor: Colors.blue,
              title: Text('Customer'),
              value: 'customer',
              groupValue: selectedValue,
              onChanged: (value) {
                setState(() {
                  selectedValue = value;
                });
              },
            ),
            RadioListTile(
              activeColor: Colors.blue,
              title: Text('Designer'),
              value: 'designer',
              groupValue: selectedValue,
              onChanged: (value) {
                setState(() {
                  selectedValue = value;
                });
              },
            ),
          ],
        );
      }),
      actions: [
        ElevatedButton(
          onPressed: () async {
            Navigator.of(context).pop(); // First pop the dialog

            // Delay a bit to ensure the popup is fully closed before navigation
          //  await Future.delayed(Duration(milliseconds: 100));

            if (selectedValue == 'customer') {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CustomerSignupScreen(),
                ),
              );
            } else if (selectedValue == 'designer') {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => DesignerSignupScreen(),
                ),
              );
            }
          },
          child: Text('Submit'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            maximumSize: Size(200, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
      ],
    );
  }
}
