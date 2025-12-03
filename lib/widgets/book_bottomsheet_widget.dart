import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:phara/data/distance_calculations.dart';
import 'package:phara/data/time_calculation.dart';
import 'package:phara/services/add_booking.dart';
import 'package:paymongo_sdk/paymongo_sdk.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get_storage/get_storage.dart';
import 'package:phara/utils/keys.dart';
import 'package:phara/utils/colors.dart';
import 'package:phara/widgets/text_widget.dart';
import 'package:phara/widgets/trackbooking_bottomsheet_widget.dart';
import 'button_widget.dart';

// Global navigator key for accessing context outside of widget tree
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class BookBottomSheetWidget extends StatefulWidget {
  final String driverId;

  final Map coordinates;

  final locationData;

  const BookBottomSheetWidget(
      {super.key,
      required this.driverId,
      required this.coordinates,
      required this.locationData});

  @override
  State<BookBottomSheetWidget> createState() => _BookBottomSheetWidgetState();
}

class _BookBottomSheetWidgetState extends State<BookBottomSheetWidget> {
  String userName = '';
  String userProfile = '';
  String paymentMethod = 'cash'; // Default payment method
  final box = GetStorage();
  bool isProcessingPayment = false;

  double _calculateFlatFare(int passengers) {
    return passengers >= 4 ? 52.0 : 39.0;
  }

  @override
  void initState() {
    getUserData();
    super.initState();
  }

  getUserData() {
    FirebaseFirestore.instance
        .collection('Users')
        .where('id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((QuerySnapshot querySnapshot) async {
      for (var doc in querySnapshot.docs) {
        setState(() {
          userName = doc['name'];
          userProfile = doc['profilePicture'];
        });
      }
    });
  }

  Future<void> processPayment(double amount) async {
    if (paymentMethod == 'cash') {
      // For cash payments, proceed directly to booking
      proceedWithBooking();
      return;
    }

    // For GCash payments, use PayMongo SDK
    setState(() {
      isProcessingPayment = true;
    });

    try {
      final publicSDK = PaymongoClient<PaymongoPublic>(
          payMongoPublicKey); // Use the API key from keys.dart
      final data = SourceAttributes(
        type: 'gcash', // 'gcash' or 'card'
        amount: amount,
        currency: 'PHP',
        redirect: const Redirect(
          success: "https://example.com/success",
          failed: "https://example.com/failed",
        ),
        billing: PayMongoBilling(
            email: 'user@example.com',
            phone: '09630539422',
            name: userName,
            address: PayMongoAddress(
                city: 'Quezon City',
                country: 'PH',
                line1: '123 Main St',
                postalCode: '1100')),
      );

      final result = await publicSDK.instance.source.create(data);
      final redirectUrl = result.attributes?.redirect?.checkoutUrl;

      print('PayMongo response: $result');
      print('Redirect URL: $redirectUrl');

      if (redirectUrl != null && redirectUrl.isNotEmpty) {
        // Check if URL can be launched
        final canLaunch = await canLaunchUrl(Uri.parse(redirectUrl));
        print('Can launch URL: $canLaunch');

        if (canLaunch) {
          // Launch payment page and handle result
          final launched = await launchUrl(
            Uri.parse(redirectUrl),
            mode: LaunchMode.externalApplication,
          );
          print('URL launched: $launched');

          if (launched) {
            // After payment is completed, proceed with booking
            proceedWithBooking();
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Could not launch payment page')),
              );
              setState(() {
                isProcessingPayment = false;
              });
            }
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cannot launch payment URL')),
            );
            setState(() {
              isProcessingPayment = false;
            });
          }
        }
      } else {
        print('Redirect URL is null or empty');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid payment URL')),
          );
          setState(() {
            isProcessingPayment = false;
          });
        }
      }
    } catch (e) {
      String errorMsg = 'Payment error: ';
      if (e is PaymongoError) {
        print('PayMongo error: ${e.toString()}');
        // Extract the actual error message from PaymongoError
        String paymongoErrorMsg =
            'Payment service is currently unavailable. Please try again later or use Cash on Delivery.';
        try {
          // Try to get more detailed error information from the error object
          final errorStr = e.toString();
          if (errorStr.contains('code') && errorStr.contains('detail')) {
            // Extract error details if available
            paymongoErrorMsg =
                'Payment service error. Please check your payment details and try again.';
          } else if (errorStr.contains('authentication')) {
            paymongoErrorMsg =
                'Payment authentication error. Please check your payment details.';
          } else if (errorStr.contains('network')) {
            paymongoErrorMsg =
                'Network error. Please check your internet connection and try again.';
          }
        } catch (_) {
          // Use default error message
        }
        errorMsg += paymongoErrorMsg;
      } else {
        print('Payment error: ${e.toString()}');
        errorMsg += e.toString();
      }

      // Use a mounted check before showing the snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
        setState(() {
          isProcessingPayment = false;
        });
      }
    }
  }

  void proceedWithBooking() {
    // This method will be called after payment is successful or for cash payments
    // The existing booking logic will be moved here
    Navigator.pop(context); // Close payment method dialog

    // Show passenger selection dialog
    int passengers = 1;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: TextBold(
            text: 'Number of Passengers',
            fontSize: 18,
            color: Colors.black,
          ),
          content: StatefulBuilder(builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (passengers > 1) {
                          setState(() {
                            passengers--;
                          });
                        }
                      },
                      icon: const Icon(Icons.remove),
                    ),
                    TextBold(
                      text: '$passengers',
                      fontSize: 18,
                      color: Colors.black,
                    ),
                    IconButton(
                      onPressed: () {
                        if (passengers < 4) {
                          setState(() {
                            passengers++;
                          });
                        }
                      },
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ],
            );
          }),
          actions: [
            TextButton(
              onPressed: () async {
                await createBooking(passengers);
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: TextBold(
                text: 'Continue',
                fontSize: 18,
                color: Colors.black,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> createBooking(int passengers) async {
    await FirebaseFirestore.instance
        .collection('Drivers')
        .doc(widget.driverId)
        .update({
      'notif': FieldValue.arrayUnion([
        {
          'notif': 'You received a new booking!',
          'read': false,
          'date': DateTime.now(),
        }
      ]),
    });

    final double fareAmount = _calculateFlatFare(passengers);

    final String docId = await addBooking(
        widget.driverId,
        widget.coordinates['pickupLocation'],
        widget.locationData['dropoff'],
        (calculateDistance(
          widget.coordinates['lat'],
          widget.coordinates['long'],
          widget.locationData['destinationlat'],
          widget.locationData['destinationlong'],
        )).toStringAsFixed(2),
        (calculateTravelTime(
                (calculateDistance(
                  widget.coordinates['lat'],
                  widget.coordinates['long'],
                  widget.locationData['destinationlat'],
                  widget.locationData['destinationlong'],
                )),
                26.8))
            .toStringAsFixed(2),
        fareAmount.toStringAsFixed(2),
        passengers,
        widget.coordinates['lat'],
        widget.coordinates['long'],
        widget.locationData['destinationlat'],
        widget.locationData['destinationlong'],
        userName,
        userProfile);

    // Get driver data for tracking screen
    final driverDoc = await FirebaseFirestore.instance
        .collection('Drivers')
        .doc(widget.driverId)
        .get();

    double rating = driverDoc['stars'] / driverDoc['ratings'].length;

    showModalBottomSheet(
        isDismissible: false,
        isScrollControlled: true,
        context: context,
        builder: ((context) {
          return TrackBookingBottomSheetWidget(
            tripDetails: {
              'userName': userName,
              'driverRatings': driverDoc['ratings'].length != 0
                  ? 'Rating: ${rating.toStringAsFixed(2)} ★'
                  : 'No ratings',
              'docId': docId,
              'driverProfile': driverDoc['profilePicture'],
              'driverName': driverDoc['name'],
              'driverId': widget.driverId,
              'distance': (calculateDistance(
                widget.coordinates['lat'],
                widget.coordinates['long'],
                widget.locationData['destinationlat'],
                widget.locationData['destinationlong'],
              )).toStringAsFixed(2),
              'origin': widget.coordinates['pickupLocation'],
              'destination': widget.locationData['dropoff'],
              'fare': fareAmount.toStringAsFixed(2),
              'paymentMethod': paymentMethod,
            },
          );
        }));
  }

  final destinationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final Stream<DocumentSnapshot> userData = FirebaseFirestore.instance
        .collection('Drivers')
        .doc(widget.driverId)
        .snapshots();
    return SingleChildScrollView(
      reverse: true,
      child: StreamBuilder<DocumentSnapshot>(
          stream: userData,
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: Text('Loading'));
            } else if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong'));
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            dynamic data = snapshot.data;

            double rating = data['stars'] / data['ratings'].length;
            return SizedBox(
              height: 500,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextBold(text: 'Driver', fontSize: 15, color: grey),
                          IconButton(
                            onPressed: (() {
                              Navigator.pop(context);
                            }),
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.red,
                              size: 32,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          CircleAvatar(
                            minRadius: 50,
                            maxRadius: 50,
                            backgroundImage:
                                NetworkImage(data['profilePicture']),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 225,
                                child: TextBold(
                                    text: 'Name: ${data['name']}',
                                    fontSize: 15,
                                    color: grey),
                              ),
                              TextRegular(
                                  text: 'Vehicle: ${data['vehicle']}',
                                  fontSize: 14,
                                  color: grey),
                              TextRegular(
                                  text: 'Plate No.: ${data['plateNumber']}',
                                  fontSize: 14,
                                  color: grey),
                              TextRegular(
                                  text: data['ratings'].length != 0
                                      ? 'Rating: ${rating.toStringAsFixed(2)} ★'
                                      : 'No ratings',
                                  fontSize: 14,
                                  color: Colors.amber),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Divider(
                        color: grey,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextBold(
                          text: 'Current Location', fontSize: 15, color: grey),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.my_location,
                            color: grey,
                            size: 32,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          SizedBox(
                            width: 270,
                            child: TextRegular(
                                text: widget.coordinates['pickupLocation'],
                                fontSize: 16,
                                color: grey),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          TextRegular(text: 'To:', fontSize: 18, color: grey),
                          const SizedBox(
                            width: 20,
                          ),
                          SizedBox(
                            width: 250,
                            height: 42,
                            child: TextFormField(
                              enabled: false,
                              controller: destinationController,
                              style: const TextStyle(
                                  color: Colors.black, fontFamily: 'QRegular'),
                              decoration: InputDecoration(
                                suffixIcon: const Icon(
                                  Icons.pin_drop_sharp,
                                  color: Colors.red,
                                ),
                                fillColor: Colors.white,
                                filled: true,
                                hintText: widget.locationData['dropoff'],
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      width: 1, color: Colors.black),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      width: 1, color: Colors.black),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      width: 1, color: Colors.black),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextRegular(
                          text:
                              'Distance: ${(calculateDistance(widget.coordinates['lat'], widget.coordinates['long'], widget.locationData['destinationlat'], widget.locationData['destinationlong'])).toStringAsFixed(2)} km',
                          fontSize: 18,
                          color: grey),
                      const SizedBox(
                        height: 5,
                      ),
                      TextRegular(
                          text:
                              'Estimated time: ${(calculateTravelTime((calculateDistance(widget.coordinates['lat'], widget.coordinates['long'], widget.locationData['destinationlat'], widget.locationData['destinationlong'])), 26.8)).toStringAsFixed(2)} hr/s',
                          fontSize: 18,
                          color: grey),
                      const SizedBox(
                        height: 5,
                      ),
                      TextRegular(
                          text:
                              'Fare: ₱${(((calculateDistance(widget.coordinates['lat'], widget.coordinates['long'], widget.locationData['destinationlat'], widget.locationData['destinationlong'])) * 10) + 20).toStringAsFixed(2)}',
                          fontSize: 18,
                          color: grey),
                      const SizedBox(
                        height: 10,
                      ),
                      const Divider(
                        color: grey,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextBold(
                          text: 'Payment Method', fontSize: 15, color: grey),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                paymentMethod = 'cash';
                              });
                            },
                            child: Container(
                              width: 120,
                              height: 50,
                              decoration: BoxDecoration(
                                color: paymentMethod == 'cash'
                                    ? Colors.green
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: paymentMethod == 'cash'
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                              ),
                              child: Center(
                                child: TextBold(
                                  text: 'Cash',
                                  fontSize: 16,
                                  color: paymentMethod == 'cash'
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                paymentMethod = 'gcash';
                              });
                            },
                            child: Container(
                              width: 120,
                              height: 50,
                              decoration: BoxDecoration(
                                color: paymentMethod == 'gcash'
                                    ? Colors.blue
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: paymentMethod == 'gcash'
                                      ? Colors.blue
                                      : Colors.grey,
                                ),
                              ),
                              child: Center(
                                child: TextBold(
                                  text: 'GCash',
                                  fontSize: 16,
                                  color: paymentMethod == 'gcash'
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Center(
                        child: ButtonWidget(
                            width: 250,
                            radius: 100,
                            opacity: isProcessingPayment ? 0.5 : 1,
                            color: Colors.green,
                            label: isProcessingPayment
                                ? 'Processing...'
                                : 'Continue',
                            onPressed: isProcessingPayment
                                ? () {}
                                : (() {
                                    showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                              title: const Text(
                                                'Booking Confirmation',
                                                style: TextStyle(
                                                    fontFamily: 'QBold',
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'Confirm booking?',
                                                    style: TextStyle(
                                                        fontFamily: 'QRegular'),
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Text(
                                                    'Payment Method: ${paymentMethod.toUpperCase()}',
                                                    style: const TextStyle(
                                                        fontFamily: 'QRegular',
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                              actions: <Widget>[
                                                MaterialButton(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(true),
                                                  child: const Text(
                                                    'Close',
                                                    style: TextStyle(
                                                        color: Colors.grey,
                                                        fontFamily: 'QRegular',
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                MaterialButton(
                                                  onPressed: () async {
                                                    Navigator.pop(context);

                                                    int passengers = 1;
                                                    if (mounted) {
                                                      showDialog(
                                                        context: navigatorKey
                                                                .currentContext ??
                                                            context,
                                                        builder: (context) {
                                                          return AlertDialog(
                                                            title: TextBold(
                                                              text:
                                                                  'Number of Passengers',
                                                              fontSize: 18,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                            content: StatefulBuilder(
                                                                builder: (context,
                                                                    setState) {
                                                              return Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      IconButton(
                                                                        onPressed:
                                                                            () {
                                                                          if (passengers >
                                                                              1) {
                                                                            setState(
                                                                              () {
                                                                                passengers--;
                                                                              },
                                                                            );
                                                                          }
                                                                        },
                                                                        icon:
                                                                            const Icon(
                                                                          Icons
                                                                              .remove,
                                                                        ),
                                                                      ),
                                                                      TextBold(
                                                                        text:
                                                                            '$passengers',
                                                                        fontSize:
                                                                            18,
                                                                        color: Colors
                                                                            .black,
                                                                      ),
                                                                      IconButton(
                                                                        onPressed:
                                                                            () {
                                                                          if (passengers <
                                                                              4) {
                                                                            setState(
                                                                              () {
                                                                                passengers++;
                                                                              },
                                                                            );
                                                                          }
                                                                        },
                                                                        icon:
                                                                            const Icon(
                                                                          Icons
                                                                              .add,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              );
                                                            }),
                                                            actions: [
                                                              TextButton(
                                                                onPressed:
                                                                    () async {
                                                                  final double
                                                                      fareAmount =
                                                                      _calculateFlatFare(
                                                                          passengers);

                                                                  if (paymentMethod ==
                                                                      'cash') {
                                                                    await FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                            'Drivers')
                                                                        .doc(widget
                                                                            .driverId)
                                                                        .update({
                                                                      'notif':
                                                                          FieldValue
                                                                              .arrayUnion([
                                                                        {
                                                                          'notif':
                                                                              'You received a new booking!',
                                                                          'read':
                                                                              false,
                                                                          'date':
                                                                              DateTime.now(),
                                                                        }
                                                                      ]),
                                                                    });

                                                                    final String docId = await addBooking(
                                                                        widget.driverId,
                                                                        widget.coordinates['pickupLocation'],
                                                                        widget.locationData['dropoff'],
                                                                        (calculateDistance(
                                                                          widget
                                                                              .coordinates['lat'],
                                                                          widget
                                                                              .coordinates['long'],
                                                                          widget
                                                                              .locationData['destinationlat'],
                                                                          widget
                                                                              .locationData['destinationlong'],
                                                                        )).toStringAsFixed(2),
                                                                        (calculateTravelTime(
                                                                                (calculateDistance(
                                                                                  widget.coordinates['lat'],
                                                                                  widget.coordinates['long'],
                                                                                  widget.locationData['destinationlat'],
                                                                                  widget.locationData['destinationlong'],
                                                                                )),
                                                                                26.8))
                                                                            .toStringAsFixed(2),
                                                                        fareAmount.toStringAsFixed(2),
                                                                        passengers,
                                                                        widget.coordinates['lat'],
                                                                        widget.coordinates['long'],
                                                                        widget.locationData['destinationlat'],
                                                                        widget.locationData['destinationlong'],
                                                                        userName,
                                                                        userProfile);
                                                                    Navigator.pop(
                                                                        context);
                                                                    Navigator.pop(
                                                                        context);

                                                                    showModalBottomSheet(
                                                                        isDismissible:
                                                                            false,
                                                                        isScrollControlled:
                                                                            true,
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            ((context) {
                                                                          return TrackBookingBottomSheetWidget(
                                                                            tripDetails: {
                                                                              'userName': userName,
                                                                              'driverRatings': data['ratings'].length != 0 ? 'Rating: ${rating.toStringAsFixed(2)} ★' : 'No ratings',
                                                                              'docId': docId,
                                                                              'driverProfile': data['profilePicture'],
                                                                              'driverName': data['name'],
                                                                              'driverId': widget.driverId,
                                                                              'distance': (calculateDistance(
                                                                                widget.coordinates['lat'],
                                                                                widget.coordinates['long'],
                                                                                widget.locationData['destinationlat'],
                                                                                widget.locationData['destinationlong'],
                                                                              )).toStringAsFixed(2),
                                                                              'origin': widget.coordinates['pickupLocation'],
                                                                              'destination': widget.locationData['dropoff'],
                                                                              'fare': fareAmount.toStringAsFixed(2)
                                                                            },
                                                                          );
                                                                        }));
                                                                  } else {
                                                                    await FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                            'Drivers')
                                                                        .doc(widget
                                                                            .driverId)
                                                                        .update({
                                                                      'notif':
                                                                          FieldValue
                                                                              .arrayUnion([
                                                                        {
                                                                          'notif':
                                                                              'You received a new booking!',
                                                                          'read':
                                                                              false,
                                                                          'date':
                                                                              DateTime.now(),
                                                                        }
                                                                      ]),
                                                                    });

                                                                    final String docId = await addBooking(
                                                                        widget.driverId,
                                                                        widget.coordinates['pickupLocation'],
                                                                        widget.locationData['dropoff'],
                                                                        (calculateDistance(
                                                                          widget
                                                                              .coordinates['lat'],
                                                                          widget
                                                                              .coordinates['long'],
                                                                          widget
                                                                              .locationData['destinationlat'],
                                                                          widget
                                                                              .locationData['destinationlong'],
                                                                        )).toStringAsFixed(2),
                                                                        (calculateTravelTime(
                                                                                (calculateDistance(
                                                                                  widget.coordinates['lat'],
                                                                                  widget.coordinates['long'],
                                                                                  widget.locationData['destinationlat'],
                                                                                  widget.locationData['destinationlong'],
                                                                                )),
                                                                                26.8))
                                                                            .toStringAsFixed(2),
                                                                        fareAmount.toStringAsFixed(2),
                                                                        passengers,
                                                                        widget.coordinates['lat'],
                                                                        widget.coordinates['long'],
                                                                        widget.locationData['destinationlat'],
                                                                        widget.locationData['destinationlong'],
                                                                        userName,
                                                                        userProfile);
                                                                    Navigator.pop(
                                                                        context);
                                                                    Navigator.pop(
                                                                        context);
                                                                    // Process payment

                                                                    showModalBottomSheet(
                                                                        isDismissible:
                                                                            false,
                                                                        isScrollControlled:
                                                                            true,
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            ((context) {
                                                                          return TrackBookingBottomSheetWidget(
                                                                            tripDetails: {
                                                                              'userName': userName,
                                                                              'driverRatings': data['ratings'].length != 0 ? 'Rating: ${rating.toStringAsFixed(2)} ★' : 'No ratings',
                                                                              'docId': docId,
                                                                              'driverProfile': data['profilePicture'],
                                                                              'driverName': data['name'],
                                                                              'driverId': widget.driverId,
                                                                              'distance': (calculateDistance(
                                                                                widget.coordinates['lat'],
                                                                                widget.coordinates['long'],
                                                                                widget.locationData['destinationlat'],
                                                                                widget.locationData['destinationlong'],
                                                                              )).toStringAsFixed(2),
                                                                              'origin': widget.coordinates['pickupLocation'],
                                                                              'destination': widget.locationData['dropoff'],
                                                                              'fare': fareAmount.toStringAsFixed(2),
                                                                              'paymentMethod': paymentMethod,
                                                                            },
                                                                          );
                                                                        }));
                                                                    await processPayment(
                                                                        fareAmount);
                                                                  }
                                                                },
                                                                child: TextBold(
                                                                  text:
                                                                      'Continue',
                                                                  fontSize: 18,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                    }
                                                  },
                                                  child: const Text(
                                                    'Continue',
                                                    style: TextStyle(
                                                        fontFamily: 'QBold',
                                                        fontWeight:
                                                            FontWeight.w800),
                                                  ),
                                                ),
                                              ],
                                            ));
                                  })),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }
}
