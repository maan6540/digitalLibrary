import 'package:digitallibrary/constants/constants.dart';
import 'package:flutter/material.dart';

class ProfileTile extends StatelessWidget {
  const ProfileTile(
      {super.key, required this.title, required this.data, required this.icon});
  final String data;
  final String title;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      width: 300,
      height: 90,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15), color: Colors.white),
      child: Row(
        children: [
          Icon(
            icon,
            size: 60,
            color: const Color(iconColor),
          ),
          const SizedBox(
            width: 20,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 200,
                child: Text(
                  overflow: TextOverflow.ellipsis,
                  title,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              SizedBox(
                width: 200,
                child: Text(
                  data,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
