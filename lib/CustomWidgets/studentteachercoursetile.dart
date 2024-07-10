import 'package:digitallibrary/Models/models.dart';
import 'package:digitallibrary/Users/Common/viewpdffile.dart';
import 'package:digitallibrary/constants/constants.dart';
import 'package:flutter/material.dart';

class TeacherStudentCourseTile extends StatelessWidget {
  const TeacherStudentCourseTile(
      {super.key,
      required this.course,
      required this.onPressed,
      this.studentId});
  final CourseModel course;
  final int? studentId;
  final Function(String) onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 20, 10, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
      ),
      height: 80,
      child: InkWell(
        onTap: () {
          onPressed(course.courseCode!);
        },
        child: Row(
          children: [
            Container(
              margin: const EdgeInsets.only(left: 10, right: 15),
              height: 50,
              width: 50,
              color: Colors.grey,
              child: Center(
                child: Text(
                  "${course.courseCode!.substring(0, 3)}\n${course.courseCode!.substring(4, course.courseCode!.length)}",
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 190,
                  child: Text(
                    style: const TextStyle(fontSize: 20),
                    course.courseName!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(
                  width: 190,
                  child: Text(
                    "CHR's : ${course.creditHours!}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              ],
            ),
            const SizedBox(
              width: 20,
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewPdfFileScreen(
                      studentId: studentId!,
                      path:
                          "$fileBaseUrl/CourseContentFolder/${course.courseContentUriPath!}",
                      name: course.courseCode!,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.list),
            ),
          ],
        ),
      ),
    );
  }
}
