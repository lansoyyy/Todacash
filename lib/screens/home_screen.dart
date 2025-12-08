import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_slider/carousel_slider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:phara/plugins/my_location.dart';
import 'package:phara/screens/map_screen.dart';
import 'package:phara/screens/pages/delivery/delivery_page.dart';
import 'package:phara/screens/pages/driver_profile_page.dart';
import 'package:phara/screens/pages/messages_tab.dart';
import 'package:phara/screens/pages/trips_page.dart';
import 'package:phara/utils/colors.dart';
import 'package:phara/utils/const.dart';
import 'package:phara/widgets/button_widget.dart';

import '../data/distance_calculations.dart';
import '../data/user_stream.dart';
import '../widgets/drawer_widget.dart';
import '../widgets/text_widget.dart';
import 'pages/notif_page.dart';
import 'package:badges/badges.dart' as b;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    determinePosition();
    getLocation();
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [
      mainHome(),
      const MessagesTab(
        useCase: ChatpageUsecase.trackDriver,
      ),
      const NotifTab(),
      MapScreen(
        inHome: true,
      ),
      const TripsPage(),
    ];
    return Scaffold(
      backgroundColor: Colors.grey[200],
      drawer: const Drawer(
        child: DrawerWidget(),
      ),
      appBar: _currentIndex == 0
          ? AppBar(
              centerTitle: true,
              foregroundColor: grey,
              backgroundColor: Colors.white,
              title: TextRegular(
                text: 'Home',
                fontSize: 24,
                color: grey,
              ),
              actions: [
                StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseData().userData,
                    builder:
                        (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (!snapshot.hasData) {
                        return const SizedBox();
                      } else if (snapshot.hasError) {
                        return const Center(
                            child: Text('Something went wrong'));
                      } else if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const SizedBox();
                      }
                      dynamic data = snapshot.data;

                      List oldnotifs = data['notif'];

                      List notifs = oldnotifs.reversed.toList();
                      return IconButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => const NotifTab()));
                        },
                        icon: b.Badge(
                            showBadge: notifs.isNotEmpty,
                            badgeContent: TextRegular(
                              text: data['notif'].length.toString(),
                              fontSize: 12,
                              color: Colors.white,
                            ),
                            child: const Icon(Icons.notifications_outlined)),
                      );
                    }),
              ],
            )
          : null,
      body: hasLoaded
          ? children[_currentIndex]
          : const Center(
              child: SpinKitPulse(
                color: grey,
              ),
            ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: BottomNavigationBar(
            selectedLabelStyle:
                const TextStyle(fontFamily: 'QBold', fontSize: 11),
            unselectedLabelStyle:
                const TextStyle(fontFamily: 'QBold', fontSize: 11),
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.grey[400],
            onTap: onTabTapped,
            currentIndex: _currentIndex,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: _currentIndex == 0
                    ? Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.home,
                          color: Colors.black,
                          size: 22,
                        ),
                      )
                    : const Icon(
                        Icons.home_outlined,
                        size: 22,
                      ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: _currentIndex == 1
                    ? Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.email,
                          color: Colors.black,
                          size: 22,
                        ),
                      )
                    : const Icon(
                        Icons.email_outlined,
                        size: 22,
                      ),
                label: 'Inbox',
              ),
              BottomNavigationBarItem(
                icon: _currentIndex == 2
                    ? Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.notifications,
                          color: Colors.black,
                          size: 22,
                        ),
                      )
                    : const Icon(
                        Icons.notifications_outlined,
                        size: 22,
                      ),
                label: 'Notifications',
              ),
              BottomNavigationBarItem(
                icon: _currentIndex == 3
                    ? Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.my_location,
                          color: Colors.black,
                          size: 22,
                        ),
                      )
                    : const Icon(
                        Icons.my_location,
                        size: 22,
                      ),
                label: 'Map',
              ),
              BottomNavigationBarItem(
                icon: _currentIndex == 4
                    ? Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.collections_bookmark,
                          color: Colors.black,
                          size: 22,
                        ),
                      )
                    : const Icon(
                        Icons.collections_bookmark_outlined,
                        size: 22,
                      ),
                label: 'History',
              ),
            ],
          ),
        ),
      ),
    );
  }

  late double lat = 0;

  late double long = 0;

  bool hasLoaded = false;

  getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      lat = position.latitude;
      long = position.longitude;
      hasLoaded = true;
    });
  }

  List imageLinks = [
    'tricycle_promo1.jpg',
    'tricycle_promo2.jpg',
    'tricycle_promo3.jpg',
  ];

  Widget mainHome() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Promotional Carousel
          SizedBox(
            height: 180,
            child: CarouselSlider.builder(
                unlimitedMode: true,
                slideBuilder: (index) {
                  List<Map<String, dynamic>> promoData = [
                    {
                      'title': 'Fast & Convenient',
                      'description':
                          'Book a tricycle ride anytime, anywhere with just a few taps on your phone.',
                      'color': Colors.blue.shade600,
                    },
                    {
                      'title': 'Safe & Reliable',
                      'description':
                          'All our drivers are verified and trained to ensure your safety and comfort.',
                      'color': Colors.green.shade600,
                    },
                    {
                      'title': 'Affordable Rides',
                      'description':
                          'Enjoy competitive prices and transparent fare calculation for every trip.',
                      'color': Colors.orange.shade600,
                    },
                  ];

                  return Padding(
                    padding:
                        const EdgeInsets.only(left: 15, right: 15, top: 10),
                    child: Container(
                      height: 170,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: promoData[index]['color'],
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextBold(
                              text: promoData[index]['title'],
                              fontSize: 24,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 10),
                            TextRegular(
                              text: promoData[index]['description'],
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                enableAutoSlider: true,
                autoSliderDelay: const Duration(seconds: 5),
                autoSliderTransitionTime: const Duration(milliseconds: 800),
                scrollPhysics: const BouncingScrollPhysics(),
                slideIndicator: CircularSlideIndicator(
                  indicatorRadius: 4,
                  currentIndicatorColor: Colors.white,
                  indicatorBackgroundColor: Colors.white.withOpacity(0.3),
                  padding: const EdgeInsets.only(bottom: 10),
                ),
                itemCount: 3),
          ),

          // Services Section
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextBold(
                  text: 'Our Services',
                  fontSize: 24,
                  color: Colors.black,
                ),
                Icon(
                  Icons.view_carousel_outlined,
                  color: grey,
                ),
              ],
            ),
          ),

          // Book a Ride Service
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => MapScreen()));
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: 185,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  image: const DecorationImage(
                      opacity: 0.8,
                      image: AssetImage(
                        'assets/images/graphics1.jpg',
                      ),
                      fit: BoxFit.cover),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.directions_bike,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 15),
                            TextBold(
                              text: 'Book a Tricycle Ride',
                              fontSize: 26,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 200,
                                  child: TextRegular(
                                    text:
                                        'Fast, safe, and affordable transportation',
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: TextBold(
                                    text: 'Book now',
                                    fontSize: 14,
                                    color: grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Available Riders Section
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextBold(
                  text: 'Available Riders',
                  fontSize: 20,
                  color: Colors.black,
                ),
                Icon(
                  Icons.bike_scooter,
                  color: grey,
                ),
              ],
            ),
          ),

          // Riders List
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Drivers')
                    .where('isActive', isEqualTo: true)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    print(snapshot.error);
                    return const Center(child: Text('Error loading riders'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 50, bottom: 50),
                      child: Center(
                          child: CircularProgressIndicator(
                        color: grey,
                      )),
                    );
                  }

                  final data = snapshot.requireData;
                  final sortedData =
                      List<QueryDocumentSnapshot>.from(data.docs);

                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                    sortedData.sort((a, b) {
                      final double lat1 = a['location']['lat'];
                      final double long1 = a['location']['long'];
                      final double lat2 = b['location']['lat'];
                      final double long2 = b['location']['long'];

                      final double distance1 =
                          calculateDistance(lat, long, lat1, long1);
                      final double distance2 =
                          calculateDistance(lat, long, lat2, long2);

                      return distance1.compareTo(distance2);
                    });
                  });

                  if (sortedData.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.bike_scooter_outlined,
                              size: 50,
                              color: grey.withOpacity(0.7),
                            ),
                            const SizedBox(height: 10),
                            TextRegular(
                              text: 'No riders available at the moment',
                              fontSize: 16,
                              color: grey,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return SizedBox(
                    height: 210,
                    child: ListView.builder(
                        itemCount: sortedData.length,
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        itemBuilder: (context, index) {
                          final driver = sortedData[index];
                          final distance = calculateDistance(
                              lat,
                              long,
                              driver['location']['lat'],
                              driver['location']['long']);

                          return Padding(
                            padding: const EdgeInsets.fromLTRB(5, 5, 15, 10),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => DriverProfilePage(
                                          driverId: driver.id,
                                        )));
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                width: 150,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      spreadRadius: 1,
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Driver Profile Picture
                                      Center(
                                        child: Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: blue.withOpacity(0.5),
                                              width: 2,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.1),
                                                spreadRadius: 1,
                                                blurRadius: 3,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: CircleAvatar(
                                            radius: 28,
                                            backgroundImage: NetworkImage(
                                                driver['profilePicture']),
                                            onBackgroundImageError:
                                                (exception, stackTrace) {
                                              // Handle image loading error
                                            },
                                            child:
                                                driver['profilePicture'] == null
                                                    ? const Icon(
                                                        Icons.person,
                                                        color: grey,
                                                        size: 30,
                                                      )
                                                    : null,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 12),

                                      // Driver Name
                                      TextBold(
                                        text: driver['name'],
                                        fontSize: 14,
                                        color: Colors.black,
                                        overflow: TextOverflow.ellipsis,
                                      ),

                                      const SizedBox(height: 5),

                                      // Rating
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 3),
                                          TextRegular(
                                            text: driver['ratings'].length != 0
                                                ? '${(driver['stars'] / driver['ratings'].length).toStringAsFixed(1)}'
                                                : 'New',
                                            fontSize: 12,
                                            color: grey,
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 5),

                                      // Distance
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on_outlined,
                                            color: grey,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 3),
                                          TextRegular(
                                            text:
                                                '${distance.toStringAsFixed(1)} km away',
                                            fontSize: 12,
                                            color: grey,
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 8),

                                      // View Profile Button
                                      Center(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: blue.withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: TextRegular(
                                            text: 'View Profile',
                                            fontSize: 11,
                                            color: grey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                  );
                }),
          ),
        ],
      ),
    );
  }
}
