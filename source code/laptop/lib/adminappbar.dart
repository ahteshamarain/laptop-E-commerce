import 'package:flutter/material.dart';

class AppBarCustom extends StatelessWidget implements PreferredSizeWidget {
  const AppBarCustom({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        'Custom App Bar',
        style: TextStyle(color: Colors.white), // Customize text color
      ),
      backgroundColor: Colors.blue, // Customize background color
      actions: [
        IconButton(
          onPressed: () {
            // Add onPressed action for the icon
          },
          icon: Icon(Icons.search), // Use any desired icon
          color: Colors.white, // Customize icon color
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(70);
}
