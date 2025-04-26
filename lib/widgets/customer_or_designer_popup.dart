import 'package:design_hub/screens/customer_signup_screen.dart';
import 'package:design_hub/screens/designer_signup_screen.dart';
import 'package:design_hub/theme/colors.dart';
import 'package:flutter/material.dart';

class CustomerOrDesignerPopup {
  static String? selectedValue = 'customer';

  static void showPopup(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return popup(context);
        });
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
                activeColor: primaryColor,
                title: Text('Customer'),
                value: 'customer',
                groupValue: selectedValue,
                onChanged: (value) {
                  setState(() {
                    selectedValue = value;
                  });
                }),
            RadioListTile(
                activeColor: primaryColor,
                title: Text('Designer'),
                value: 'designer',
                groupValue: selectedValue,
                onChanged: (value) {
                  setState(() {
                    selectedValue = value;
                  });
                })
          ],
        );
      }),
      actions: [
        ElevatedButton(
            onPressed: () {
              if(selectedValue == 'customer'){
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CustomerSignupScreen(),
                  )
                );
              }
              else if(selectedValue == 'designer'){
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => DesignerSignupScreen(),
                  )
                );
              }
            },
            child: Text('Submit'),
            style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: whiteColor,
                maximumSize: Size(200, 40),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)))),
      ],
    );
  }
}
