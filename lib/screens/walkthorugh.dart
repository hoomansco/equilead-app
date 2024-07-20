import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:equilead/screens/auth/auth.dart';
import 'package:equilead/widgets/animation/press_effect.dart';

class WalkthroughScreen extends StatefulWidget {
  const WalkthroughScreen({super.key});

  @override
  State<WalkthroughScreen> createState() => _WalkthroughScreenState();
}

class _WalkthroughScreenState extends State<WalkthroughScreen> {
  int currentIndex = 0;
  PageController pageController = PageController();
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: PageView.builder(
          controller: pageController,
          itemBuilder: (context, index) => SizedBox(
            height: size.height,
            width: size.width,
            child: Column(
              children: [
                SizedBox(
                  height: size.height - 350,
                  width: size.width,
                  child: Image.asset(
                    'assets/images/walkthrough_bg_${index + 1}.png',
                    fit: BoxFit.fitWidth,
                  ),
                ),
                Container(
                  height: 350,
                  width: size.width,
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
                  color: Colors.white,
                  child: _getBottomWidget(index),
                ),
              ],
            ),
          ),
          itemCount: 4,
          onPageChanged: (value) {
            setState(() {
              currentIndex = value;
            });
          },
        ),
      ),
      floatingActionButton: SizedBox(
        width: size.width - 64,
        child: Row(
          children: [
            SizedBox(
              child: Row(
                children: [
                  _dotSelector(0),
                  _dotSelector(1),
                  _dotSelector(2),
                  _dotSelector(3),
                ],
              ),
            ),
            Spacer(),
            PressEffect(
              onPressed: () {
                if (currentIndex == 3) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => Authentication(),
                    ),
                  );
                } else {
                  pageController.nextPage(
                    duration: Duration(milliseconds: 400),
                    curve: Curves.easeInOutCirc,
                  );
                }
              },
              child: Container(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.black,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      currentIndex == 3 ? 'Get Started' : 'Next',
                      style: TextStyle(
                        fontFamily: 'General Sans',
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        height: 0.85,
                      ),
                    ),
                    SizedBox(width: 4),
                    SvgPicture.asset("assets/icons/arrow-r.svg")
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _dotSelector(int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 400),
      curve: Curves.easeInOutCirc,
      width: 6,
      height: 6,
      margin: EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: currentIndex == index ? Colors.black : Color(0xffEBEBEB),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _getBottomWidget(int index) {
    switch (index) {
      case 0:
        return Column(
          children: [
            SizedBox(height: 16),
            SvgPicture.asset('assets/images/walkthrough_b_1.svg'),
          ],
        );
      case 1:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 32),
            Text(
              'build your'.toUpperCase(),
              style: TextStyle(
                fontFamily: 'General Sans',
                fontSize: 24,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'portfolio',
              style: TextStyle(
                fontFamily: 'Instrumental Serif',
                fontSize: 60,
                fontWeight: FontWeight.w400,
                color: Colors.black,
                fontStyle: FontStyle.italic,
                height: 0.9,
                letterSpacing: -2,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'A public portfolio showcasing your skills and progress over time with Equilead.',
              style: TextStyle(
                fontFamily: 'General Sans',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black,
                height: 1.42,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      case 2:
        return Column(
          children: [
            SizedBox(height: 32),
            Text(
              'ticket to limitless'.toUpperCase(),
              style: TextStyle(
                fontFamily: 'General Sans',
                fontSize: 24,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'learning',
              style: TextStyle(
                fontFamily: 'Instrumental Serif',
                fontSize: 60,
                fontWeight: FontWeight.w400,
                color: Colors.black,
                fontStyle: FontStyle.italic,
                height: 0.9,
                letterSpacing: -2,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Don’t miss activities across Equilead foundation and campus.',
              style: TextStyle(
                fontFamily: 'General Sans',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black,
                height: 1.42,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      case 3:
        return Column(
          children: [
            SizedBox(height: 32),
            Text(
              'home of all things'.toUpperCase(),
              style: TextStyle(
                fontFamily: 'General Sans',
                fontSize: 24,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'community',
              style: TextStyle(
                fontFamily: 'Instrumental Serif',
                fontSize: 60,
                fontWeight: FontWeight.w400,
                color: Colors.black,
                fontStyle: FontStyle.italic,
                height: 0.9,
                letterSpacing: -2,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'You campus community is the manifestation of growing together as a community and now it has a digital space.',
              style: TextStyle(
                fontFamily: 'General Sans',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black,
                height: 1.42,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      default:
        SizedBox.shrink();
    }
    return SizedBox.shrink();
  }
}
