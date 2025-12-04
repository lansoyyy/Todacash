import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phara/screens/map_screen.dart';
import 'package:phara/utils/colors.dart';
import 'package:phara/widgets/text_widget.dart';

class TripSummaryPage extends StatelessWidget {
  final Map tripDetails;
  final DateTime date;

  const TripSummaryPage(
      {super.key, required this.tripDetails, required this.date});

  @override
  Widget build(BuildContext context) {
    final dateText = DateFormat('dd MMM yyyy, hh:mm a').format(date);
    final String bookingId = tripDetails['docId'] ?? '';
    final String vehicleType = 'Motorcycle';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => MapScreen()),
              (route) => false,
            );
          },
        ),
        centerTitle: true,
        title: TextBold(
          text: dateText,
          fontSize: 14,
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.lightBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  TextBold(
                    text: 'Completed',
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextRegular(
                      text: 'Booking ID',
                      fontSize: 11,
                      color: grey,
                    ),
                    const SizedBox(height: 4),
                    TextBold(
                      text: bookingId,
                      fontSize: 12,
                      color: Colors.black,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.motorcycle, color: Colors.red),
                        const SizedBox(width: 6),
                        TextBold(
                          text: vehicleType,
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.circle, size: 12, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextRegular(
                            text: tripDetails['origin'] ?? '',
                            fontSize: 13,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on,
                            size: 16, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextRegular(
                            text: tripDetails['destination'] ?? '',
                            fontSize: 13,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextRegular(
                          text: 'Final Fare',
                          fontSize: 13,
                          color: Colors.black,
                        ),
                        TextBold(
                          text: '₱${tripDetails['fare'] ?? '0.00'}',
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextRegular(
                          text: 'Payment Method',
                          fontSize: 13,
                          color: grey,
                        ),
                        TextRegular(
                          text: (tripDetails['paymentMethod'] ?? 'Cash')
                              .toString()
                              .toUpperCase(),
                          fontSize: 13,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => MapScreen()),
                    (route) => false,
                  );
                },
                child: TextBold(
                  text: 'Back to Home',
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
