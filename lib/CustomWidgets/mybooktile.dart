import 'package:digitallibrary/Models/models.dart';
import 'package:digitallibrary/constants/constants.dart';
import 'package:flutter/material.dart';

class MyBookTile extends StatelessWidget {
  const MyBookTile({
    super.key,
    this.ftn1,
    this.icon1,
    this.ftn2,
    this.icon2,
    this.ftn3,
    this.icon3,
    this.ftn4,
    this.icon4,
    this.ftn5,
    this.icon5,
    this.ftn6,
    this.icon6,
    required this.book,
  });

  final String imagePath = "$fileBaseUrl/BookImageFolder";

  final Function(int)? ftn1;
  final IconData? icon1;
  final Function(int)? ftn2;
  final IconData? icon2;
  final Function(int)? ftn3;
  final IconData? icon3;
  final Function(int)? ftn4;
  final IconData? icon4;
  final Function(int)? ftn5;
  final IconData? icon5;
  final Function(int)? ftn6;
  final IconData? icon6;
  final BookModel book;

  @override
  Widget build(BuildContext context) {
    double calculateWidth() {
      if (icon1 == null && icon3 == null && icon5 == null ||
          icon2 == null &&
              icon4 == null &&
              icon6 == null &&
              (icon1 != null || icon3 != null || icon5 != null)) {
        return 30;
      } else {
        return 3;
      }
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(10, 5, 10, 10),
      height: ftn5 == null ? 120 : 170,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Container(
            width: 90,
            height: 150,
            margin: const EdgeInsets.fromLTRB(5, 10, 5, 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors
                  .grey.shade300, // Use a default color or define iconColor
            ),
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(8.0), // Optional: for rounded corners
              child: Image.network(
                "$imagePath/${book.bookCoverPagePath}",
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error,
                      color: Colors.red, size: 50); // Error icon
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              (loadingProgress.expectedTotalBytes ?? 1)
                          : null,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.3,
                child: Text(
                  book.bookName!,
                  style: const TextStyle(fontSize: 20),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(
                    Icons.person,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 2),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.29,
                    child: Text(
                      book.bookAuthorName!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              )
            ],
          ),
          SizedBox(width: calculateWidth()),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  if (icon1 != null && ftn1 != null) ...[
                    IconButton(
                      onPressed: () {
                        ftn1!(book.bookId!);
                      },
                      icon: Icon(
                        icon1,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 2),
                  ],
                  if (icon2 != null && ftn2 != null) ...[
                    IconButton(
                      onPressed: () {
                        ftn2!(book.bookId!);
                      },
                      icon: Icon(
                        icon2,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 2),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  if (icon3 != null && ftn3 != null) ...[
                    IconButton(
                      onPressed: () {
                        ftn3!(book.bookId!);
                      },
                      icon: Icon(
                        icon3,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 2),
                  ],
                  if (icon4 != null && ftn4 != null) ...[
                    IconButton(
                      onPressed: () {
                        ftn4!(book.bookId!);
                      },
                      icon: Icon(
                        icon4,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 2),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  if (icon5 != null && ftn5 != null) ...[
                    IconButton(
                      onPressed: () {
                        ftn5!(book.bookId!);
                      },
                      icon: Icon(
                        icon5,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 2),
                  ],
                  if (icon6 != null && ftn6 != null) ...[
                    IconButton(
                      onPressed: () {
                        ftn6!(book.bookId!);
                      },
                      icon: Icon(
                        icon6,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 2),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
