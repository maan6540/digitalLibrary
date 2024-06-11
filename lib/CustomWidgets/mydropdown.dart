import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class MyDropDown extends StatefulWidget {
  const MyDropDown(
      {super.key,
      required this.data,
      this.hintText = "Select",
      this.backgroundColor = Colors.black,
      this.borderColor = Colors.grey,
      this.searchEnabled = false,
      required this.onSelected,
      this.width = 225,
      this.height = 40,
      this.textColor = Colors.white,
      required this.clearSelectedValueCallback});

  final List<String> data;
  final Color? textColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool? searchEnabled;
  final String? hintText;
  final double? width;
  final double? height;
  final Function(String) onSelected;
  final Function(Function()) clearSelectedValueCallback;

  @override
  State<MyDropDown> createState() => _MyDropDownState();
}

class _MyDropDownState extends State<MyDropDown> {
  String? selectedValue;

  final TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.clearSelectedValueCallback(_clearSelectedValue);
  }

  void _clearSelectedValue() {
    setState(() {
      selectedValue = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        isExpanded: true,
        iconStyleData: IconStyleData(
          iconSize: 30,
          iconEnabledColor: widget.textColor,
          iconDisabledColor: Colors.grey,
        ),
        disabledHint: const Text(
          'Loading...',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        style: TextStyle(color: widget.textColor),
        hint: Text(
          widget.hintText!,
          style: TextStyle(
            fontSize: 14,
            color: widget.textColor,
          ),
        ),
        items: widget.data
            .map((item) => DropdownMenuItem(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ))
            .toList(),
        value: selectedValue,
        onChanged: (value) {
          if (value != null) {
            widget.onSelected(value);
          }
          setState(() {
            selectedValue = value;
          });
        },
        buttonStyleData: ButtonStyleData(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            border: Border.fromBorderSide(BorderSide(
              color: widget.borderColor!,
              width: 2,
              strokeAlign: BorderSide.strokeAlignInside,
            )),
          ),
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 130,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            border: Border(
              left: BorderSide(
                color: widget.borderColor!,
                width: 2,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
              right: BorderSide(
                color: widget.borderColor!,
                width: 2,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
              bottom: BorderSide(
                color: widget.borderColor!,
                width: 2,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
            ),
          ),
        ),
        menuItemStyleData: const MenuItemStyleData(
          height: 40,
        ),
        dropdownSearchData: widget.searchEnabled!
            ? DropdownSearchData(
                searchController: textEditingController,
                searchInnerWidgetHeight: 10,
                searchInnerWidget: Container(
                  height: 50,
                  padding: const EdgeInsets.only(
                    top: 2,
                    bottom: 0,
                    right: 8,
                    left: 8,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: widget.borderColor!,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                    ),
                    child: TextField(
                      style: TextStyle(color: widget.textColor),
                      expands: true,
                      maxLines: null,
                      cursorColor: widget.textColor,
                      controller: textEditingController,
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.fromLTRB(8, 10, 8, 0),
                        hintText: 'Search ...',
                        hintStyle: TextStyle(
                          fontSize: 12,
                          color: widget.textColor,
                        ),
                      ),
                    ),
                  ),
                ),
                searchMatchFn: (item, searchValue) {
                  return item.value!
                      .toUpperCase()
                      .toString()
                      .contains(searchValue.toUpperCase());
                },
              )
            : null,
        onMenuStateChange: (isOpen) {
          if (!isOpen) {
            textEditingController.clear();
          }
        },
      ),
    );
  }
}
