import 'package:flutter/material.dart';

class ModelProfiletile {
  final String title;
  final String data;
  final IconData icon;
  ModelProfiletile(
      {required this.title, required this.data, required this.icon});
}

class ModelDashBoardData {
  final String name;
  final Widget icon;
  final Function() function;

  ModelDashBoardData(
      {required this.name, required this.icon, required this.function});
}

class DepartmentNameModel {
  String? departmentName;
  DepartmentNameModel({this.departmentName});
  DepartmentNameModel.fromJson(Map<String, dynamic> json) {
    departmentName = json['departmentName'];
  }
}

class StudentModel {
  String? studentName;
  int? studentId;
  String? studentRegNo;
  StudentModel({this.studentName, this.studentId, this.studentRegNo});
  StudentModel.fromJson(Map<String, dynamic> json) {
    studentName = json['studentName'];
    studentId = json['studentId'];
    studentRegNo = json['studentRegNo'];
  }
}

class TeacherModel {
  String? teacherName;
  int? teacherId;
  TeacherModel({this.teacherName, this.teacherId});
  TeacherModel.fromJson(Map<String, dynamic> json) {
    teacherName = json['teacherName'];
    teacherId = json['teacherId'];
  }
}

class CourseTeacherAssignModel {
  String? teacherName;
  String? courseCode;
  int? teacherId;

  CourseTeacherAssignModel({this.teacherName, this.courseCode, this.teacherId});
  CourseTeacherAssignModel.fromJson(Map<String, dynamic> json) {
    teacherName = json['teacherName'];
    courseCode = json['courseCode'];
    teacherId = json['teacherId'];
  }
}

class EnrolledCoursesModel {
  String? courseName;
  String? courseCode;
  int? studentId;

  EnrolledCoursesModel({this.courseName, this.courseCode, this.studentId});
  EnrolledCoursesModel.fromJson(Map<String, dynamic> json) {
    studentId = json['studentId'];
    courseCode = json['courseCode'];
    courseName = json['courseName'];
  }
}

class CourseModel {
  String? courseCode;
  String? courseName;
  String? courseContentUriPath;
  String? creditHours;

  CourseModel(
      {this.courseCode,
      this.courseName,
      this.courseContentUriPath,
      this.creditHours});

  CourseModel.fromJson(Map<String, dynamic> json) {
    courseCode = json['courseCode'];
    courseName = json['courseName'];
    courseContentUriPath = json['courseContentUriPath'];
    creditHours = json['creditHours'];
  }
}

class BookModel {
  int? bookId;
  String? bookName;
  String? bookAuthorName;
  String? bookCoverPagePath;
  String? bookPdfPath;
  String? categroyName;
  String? categoryId;
  String? bookKeywords;
  String? uploadType;
  int? userId;
  String? status;
  bool? isDownloaded;
  bool? isBookMarked = false;

  BookModel({
    this.bookId,
    this.bookName,
    this.bookAuthorName,
    this.bookCoverPagePath,
    this.bookPdfPath,
    this.categroyName,
    this.uploadType,
    this.bookKeywords,
    this.userId,
    this.categoryId,
    this.isDownloaded = false,
    this.isBookMarked = false,
    this.status,
  });

  BookModel.fromJson(Map<String, dynamic> json) {
    bookId = json['bookId'];
    bookName = json['bookName'];
    bookAuthorName = json['bookAuthorName'];
    bookCoverPagePath = json['bookCoverPagePath'];
    bookPdfPath = json['bookPdfPath'];
    categroyName = json['categroyName'];
    bookKeywords = json['bookKeywords'];
    uploadType = json['uploadType'];
    userId = json['userId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["bookId"] = bookId;
    data["bookName"] = bookName;
    data["bookAuthorName"] = bookAuthorName;
    data["bookCoverPagePath"] = bookCoverPagePath;
    data["bookPdfPath"] = bookPdfPath;
    data["categroyName"] = categroyName;
    data["bookKeywords"] = bookKeywords;
    data["uploadType"] = uploadType;
    data["userId"] = userId;
    return data;
  }

  BookModel.copy(BookModel original)
      : bookId = original.bookId,
        bookName = original.bookName,
        bookAuthorName = original.bookAuthorName,
        bookCoverPagePath = original.bookCoverPagePath,
        bookPdfPath = original.bookPdfPath,
        categroyName = original.categroyName,
        bookKeywords = original.bookKeywords,
        uploadType = original.uploadType,
        userId = original.userId,
        isDownloaded = original.isDownloaded;
}

class BookCategoryModel {
  int? categoryId;
  String? categroyName;

  BookCategoryModel({this.categoryId, this.categroyName});

  BookCategoryModel.fromJson(Map<String, dynamic> json) {
    categoryId = json['categoryId'];
    categroyName = json['categroyName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['categoryId'] = categoryId;
    data['categroyName'] = categroyName;
    return data;
  }
}

class TocModel {
  int? tocId;
  int? bookId;
  String? tocContent;
  int? tocPageNo;
  int? subTocOf;
  String? tocKeywords;

  TocModel(
      {this.tocId,
      this.bookId,
      this.tocContent,
      this.tocPageNo,
      this.subTocOf,
      this.tocKeywords});

  TocModel.fromJson(Map<String, dynamic> json) {
    tocId = json['tocId'];
    bookId = json['bookId'];
    tocContent = json['tocContent'];
    tocPageNo = json['tocPageNo'];
    subTocOf = json['subTocOf'];
    tocKeywords = json['tocKeywords'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['tocId'] = tocId;
    data['bookId'] = bookId;
    data['tocContent'] = tocContent;
    data['tocPageNo'] = tocPageNo;
    data['subTocOf'] = subTocOf;
    data['tocKeywords'] = tocKeywords;
    return data;
  }
}

class WeekLPModel {
  int? lessonPlanId;
  String? lessonPlanPdfPatn;
  String? lessonPlanTitle;

  WeekLPModel(
      {this.lessonPlanId, this.lessonPlanPdfPatn, this.lessonPlanTitle});

  WeekLPModel.fromJson(Map<String, dynamic> json) {
    lessonPlanId = json['lessonPlanId'];
    lessonPlanPdfPatn = json['lessonPlanPdfPatn'];
    lessonPlanTitle = json['lessonPlanTitle'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lessonPlanId'] = lessonPlanId;
    data['lessonPlanPdfPatn'] = lessonPlanPdfPatn;
    data['lessonPlanTitle'] = lessonPlanTitle;
    return data;
  }
}

class ReferenceModel {
  int? id;
  String? referenceTitle;
  String? referenceUri;
  String? uploaderType;
  int? uploaderId;

  ReferenceModel(
      {this.id,
      this.referenceTitle,
      this.referenceUri,
      this.uploaderType,
      this.uploaderId});

  ReferenceModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    referenceTitle = json['referenceTitle'];
    referenceUri = json['referenceUri'];
    uploaderType = json['uploaderType'];
    uploaderId = json['uploaderId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['referenceTitle'] = referenceTitle;
    data['referenceUri'] = referenceUri;
    data['uploaderType'] = uploaderType;
    data['uploaderId'] = uploaderId;
    return data;
  }
}

class BookMarkModel {
  int? bookId;
  int? bookmarkId;

  BookMarkModel({this.bookId, this.bookmarkId});

  BookMarkModel.fromJson(Map<String, dynamic> json) {
    bookId = json['bookId'];
    bookmarkId = json['bookmarkId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['bookId'] = bookId;
    data['bookmarkId'] = bookmarkId;
    return data;
  }
}

class HighlightModel {
  int? highlightId;
  String? highlightdItemType;
  int? studentId;
  String? highlightType;
  int? itemId;
  String? itemPath;
  String? highlightName;
  int? pageNo;

  HighlightModel(
      {this.highlightId,
      this.highlightdItemType,
      this.studentId,
      this.highlightType,
      this.itemId,
      this.itemPath,
      this.highlightName,
      this.pageNo});

  HighlightModel.fromJson(Map<String, dynamic> json) {
    highlightId = json['highlightId'];
    highlightdItemType = json['highlightdItemType'];
    studentId = json['studentId'];
    highlightType = json['highlightType'];
    itemId = json['itemId'];
    itemPath = json['itemPath'];
    highlightName = json['highlightName'];
    pageNo = json['pageNo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['highlightId'] = highlightId;
    data['highlightdItemType'] = highlightdItemType;
    data['studentId'] = studentId;
    data['highlightType'] = highlightType;
    data['itemId'] = itemId;
    data['itemPath'] = itemPath;
    data['highlightName'] = highlightName;
    data['pageNo'] = pageNo;
    return data;
  }
}

class LogsModel {
  String? startTime;
  String? endTime;
  String? actionPerformed;
  String? itemName;
  String? itemType;

  LogsModel(
      {this.startTime,
      this.endTime,
      this.actionPerformed,
      this.itemName,
      this.itemType});

  LogsModel.fromJson(Map<String, dynamic> json) {
    startTime = json['startTime'];
    endTime = json['endTime'];
    actionPerformed = json['actionPerformed'];
    itemName = json['itemName'];
    itemType = json['itemType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['startTime'] = startTime;
    data['endTime'] = endTime;
    data['actionPerformed'] = actionPerformed;
    data['itemName'] = itemName;
    data['itemType'] = itemType;
    return data;
  }
}

// String dateString = '6/11/2024 2:44:49 AM';
// DateTime parsedDate = DateTime.parse(dateString);
// print(parsedDate);

