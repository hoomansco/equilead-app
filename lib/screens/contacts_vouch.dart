import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:equilead/widgets/animation/press_effect.dart';
import 'package:equilead/widgets/common/icon_wrapper.dart';

class ContactsVouch extends StatefulWidget {
  final Function(List<String>, String) onSelectedContact;

  final List<Map<String, String>> contacts;
  const ContactsVouch(
      {super.key, required this.contacts, required this.onSelectedContact});

  @override
  State<ContactsVouch> createState() => _ContactsVouchState();
}

class _ContactsVouchState extends State<ContactsVouch> {
  Size get size => MediaQuery.of(context).size;
  List<Map<String, String>> filteredContacts = [];
  @override
  void initState() {
    setState(() {
      filteredContacts = widget.contacts;
    });
    super.initState();
  }

  void updateSearchTerm(String newname) {
    var searchTerm = newname.toLowerCase();
    filteredContacts = widget.contacts
        .where((contact) => contact["name"]!.toLowerCase().contains(searchTerm))
        .toList();
    setState(() {}); // Rebuild the list view
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(
            left: size.width * 0.08,
            right: size.width * 0.08,
            top: MediaQuery.of(context).padding.top),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconWrapper(
              icon: "assets/icons/back.svg",
              onTap: () {
                Navigator.pop(context);
              },
            ),
            SizedBox(
              height: size.height * 0.02,
            ),
            TextField(
              onChanged: (search) {
                updateSearchTerm(search);
              },
              decoration: InputDecoration(
                  hintText: "Search",
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Color(0xFFDEDEDE), width: 0.4)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Color(0xFFDEDEDE), width: 0.4)),
                  hintStyle: TextStyle(
                      color: Color(0xFFBFBFBF),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      fontFamily: "General Sans"),
                  prefixIcon: Container(
                    height: 15,
                    width: 15,
                    padding: EdgeInsets.only(left: 5),
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      "assets/icons/search_icon.svg",
                      height: 20,
                      width: 20,
                    ),
                  )),
            ),
            SizedBox(
              height: size.height * 0.02,
            ),
            Text(
              "Who you want to vouch?",
              style: TextStyle(
                  fontFamily: "General Sans",
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 24),
            ),
            SizedBox(height: size.height * 0.02),
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(0),
                children: [
                  Column(
                    children: listCntacts(),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> listCntacts() {
    List<Widget> list = [];
    for (var i = 0; i < filteredContacts.length; i++) {
      list.add(PressEffect(
        onPressed: () async {
          var selectedPhoneNumber =
              filteredContacts[i]["phoneNumber"]?.split(',');
          widget.onSelectedContact(
              selectedPhoneNumber!, filteredContacts[i]["name"]!);
        },
        child: Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(vertical: size.height * 0.01),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                filteredContacts[i]["name"]!,
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontFamily: "General Sans"),
              ),
              Text(
                filteredContacts[i]["phoneNumber"]!,
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontFamily: "General Sans"),
              )
            ],
          ),
        ),
      ));
    }
    return list;
  }
}
