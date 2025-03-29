import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class ProfileMenuWidget extends StatelessWidget {
  const ProfileMenuWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.onPress,
    this.endIcon = true,
    this.textColor,
  });

  final String title;
  final IconData icon;
  final VoidCallback onPress;
  final bool endIcon;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    var isDark = Theme.of(context).brightness == Brightness.dark;
    var iconColor = isDark ? Colors.white : Colors.black;

    return ListTile(
      onTap: onPress,
      leading: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: iconColor.withOpacity(0.1),
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(
        title,

        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: textColor ?? iconColor,
        fontSize: 18,
        fontWeight: FontWeight.w600),
      ),
      trailing: endIcon
          ? Container(
        width: 35,
        height: 35,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Colors.grey.withOpacity(0.1),
        ),
        child: Icon(LineAwesomeIcons.angle_right_solid, size: 18.0, color: Colors.grey),
      )
          : null,
    );
  }
}
