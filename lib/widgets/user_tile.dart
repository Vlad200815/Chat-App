import 'package:chat_app/models/user_profile.dart';
import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final UserProfile userProfile;
  final void Function()? onPressed;

  const UserTile({
    super.key,
    required this.userProfile,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onPressed,
      dense: false,
      leading: CircleAvatar(
        backgroundImage: NetworkImage(userProfile.pfpURL!),
      ),
      title: Text(userProfile.name!),
    );
  }
}
