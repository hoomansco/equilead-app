import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:equilead/widgets/common/icon_wrapper.dart';

class HygieneCheckScreen extends StatefulWidget {
  const HygieneCheckScreen({super.key});

  @override
  State<HygieneCheckScreen> createState() => _HygieneCheckScreenState();
}

class _HygieneCheckScreenState extends State<HygieneCheckScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late PageController controller;
  int currentPage = 0;
  Size get size => MediaQuery.of(context).size;
  List<Map<String, String>> _contents = [
    {
      "desc":
          "Please make sure to keep your bags in the designated space to avoid any obstructions. ",
      "icon": "bag"
    },
    {
      "desc":
          "After using any electronic items, we kindly request that you return them to their designated place.",
      "icon": "goggle"
    },
    {"desc": "Keep the common areas and canteen clean. ", "icon": "broom"},
    {
      "desc":
          "To help keep our premises clean and litter-free, please make use of the designated dustbins for waste disposal.",
      "icon": "waste_basket"
    },
    {"desc": "Keep your desk tidy and organized.", "icon": "card_file_box"},
    {
      "desc": "Any food item except water is prohibited inside the space.",
      "icon": "prohibited"
    },
    {
      "desc":
          "When using the washroom facilities, please be mindful of others and use them responsibly.",
      "icon": "lotion_bottle"
    },
    {
      "desc":
          "Please use headsets when listening to audio and avoid playing music loudly.",
      "icon": "headphone"
    }
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    controller = PageController(
      initialPage: currentPage,
      keepPage: false,
      viewportFraction: 0.85,
    );
    controller.addListener(() {
      setState(() {
        currentPage = controller.page!.round();
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            child: Image.asset(
              "assets/images/background_grid.png",
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top,
            right: 20,
            child: IconWrapper(
              icon: "assets/icons/close.svg",
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
          Container(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).padding.top + 40,
                ),
                Text(
                  "Hygiene Check",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    fontFamily: "General Sans",
                  ),
                ),
                Text(
                  "Housekeeping rules you should know",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: size.height * 0.1),
                Container(
                  height: size.height * 0.46,
                  child: PageView.builder(
                    itemCount: _contents.length,
                    onPageChanged: (value) {
                      setState(() {
                        currentPage = value;
                      });
                    },
                    controller: controller,
                    itemBuilder: (context, index) => builder(index),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  builder(int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOutCirc,
      margin: EdgeInsets.symmetric(
        horizontal: 10,
        vertical: currentPage == index ? 0 : 30,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        color: Colors.white,
      ),
      height: currentPage == index ? 300 : 200,
      padding: EdgeInsets.symmetric(
        vertical: size.width * 0.1,
        horizontal: 20,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset("assets/icons/${_contents[index]["icon"]}.svg"),
          SizedBox(height: 16),
          Text(
            '${_contents[index]["desc"]}',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
