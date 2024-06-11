import 'package:digitallibrary/Models/models.dart';
import 'package:flutter/material.dart';

class DashboardTiles extends StatelessWidget {
  const DashboardTiles({super.key, required this.data});
  final List<ModelDashBoardData> data;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: ((context, index) {
        return InkWell(
          onTap: data[index].function,
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0, bottom: 20, right: 20),
            child: Container(
              padding: const EdgeInsets.all(10),
              width: 300,
              height: 90,
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5), // shadow color
                  spreadRadius: 2, // how spread the shadow is
                  blurRadius: 4, // how blurry the shadow is
                  offset: const Offset(0, 0), // changes position of shadow
                ),
              ], borderRadius: BorderRadius.circular(15), color: Colors.white),
              child: Row(
                children: [
                  data[index].icon,
                  const SizedBox(
                    width: 20,
                  ),
                  Text(
                    data[index].name,
                    style: const TextStyle(fontSize: 24),
                  )
                ],
              ),
            ),
          ),
        );
      }),
      itemCount: data.length,
    );
  }
}
