import 'package:digitallibrary/CustomWidgets/myappbar.dart';
import 'package:digitallibrary/CustomWidgets/mybutton.dart';
import 'package:flutter/material.dart';

class AddMultipleToc extends StatefulWidget {
  const AddMultipleToc({
    super.key,
    required this.bookId,
  });
  final int bookId;

  @override
  State<AddMultipleToc> createState() => _AddMultipleTocState();
}

class _AddMultipleTocState extends State<AddMultipleToc> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: const MyAppBar(title: "Add Multiple TOC"),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyButton(
                  width: 100,
                  text: "Select File",
                  onPressed: () {
                    // selectFile();
                  },
                ),
                const SizedBox(
                    width: 100,
                    child: Text(
                      "file",
                      overflow: TextOverflow.ellipsis,
                    )),
                MyButton(
                  width: 100,
                  text: "Load Data",
                  onPressed: () {
                    // if (filePath == null) {
                    //   showSnackBar("Select File First");
                    // } else {
                    //   readExcelFile(filePath!);
                    // }
                  },
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.7,
              width: 320,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 10,
                      ),
                      MyButton(
                        text: "Clear",
                        onPressed: () {
                          // clearRegisteredUsers();
                        },
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      MyButton(
                        text: "Clear All",
                        onPressed: () {
                          // users.clear();
                          setState(() {});
                        },
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.60,
                    child: ListView.builder(
                      // itemCount: users.length,
                      itemBuilder: (context, index) {
                        return;
                        // return BulkUserTile(
                        //   name: users[index].name!,
                        //   username: users[index].username!,
                        //   status: users[index].status,
                        //   message: users[index].message,
                        //   onDelete: () {
                        //     setState(() {
                        //       users.removeAt(index);
                        //     });
                        //   },
                        //   onEdit: () {
                        //     editUser(index);
                        //   },
                        // );
                      },
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            MyButton(
              onPressed: () {
                // addUsers();
              },
              text: "Add Users",
              width: 300,
              height: 40,
            )
          ],
        ),
      ),
    );
  }
}
