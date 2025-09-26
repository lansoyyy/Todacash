import 'package:flutter/material.dart';
import 'package:phara/utils/colors.dart';
import 'package:phara/widgets/text_widget.dart';

import '../../widgets/appbar_widget.dart';
import '../../widgets/drawer_widget.dart';

class AboutusPage extends StatelessWidget {
  const AboutusPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DrawerWidget(),
      appBar: AppbarWidget('About Us'),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20,
              ),
              TextBold(text: 'Who we are', fontSize: 24, color: black),
              const SizedBox(
                height: 10,
              ),
              TextRegular(
                  text:
                      'At TodaCash, we are a team of student based in Pateros City, Philippines. Our mission is to create a ride-booking platform designed for tricycle transportation, making commuting more accessible, safe, and efficient for both passengers and drivers. We believe technology can transform everyday transportation, and we are committed to delivering user-friendly and innovative solutions.',
                  fontSize: 14,
                  color: grey),
              const SizedBox(
                height: 50,
              ),
              TextBold(text: 'What we do', fontSize: 24, color: black),
              const SizedBox(
                height: 10,
              ),
              TextRegular(
                  text:
                      'At TodaCash, we focus on creating digital payment and ride-booking solutions tailored to the tricycle sector. Our platform allows passengers to easily book rides, drivers to accept trips seamlessly, and operators to manage services more efficiently. By combining technology with community-driven goals, we strive to improve the public transportation experience in the Pateros.',
                  fontSize: 14,
                  color: grey),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
