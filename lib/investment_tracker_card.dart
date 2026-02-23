// import 'package:flutter/material.dart';
//
// class InvestmentTrackerCard extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 5,
//       child: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Investment Tracker',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 8),
//             Text('Track your SIPs, mutual funds, and EMIs.'),
//             SizedBox(height: 12),
//             ElevatedButton(
//               onPressed: () {
//                 // Navigate to investment tracker page
//               },
//               child: Text('View Investments'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class InvestmentTrackerCard extends StatelessWidget {
  const InvestmentTrackerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: const ListTile(
        leading: Icon(Icons.trending_up, color: Colors.green),
        title: Text("Investments"),
        subtitle: Text("₹1,20,000 Total Portfolio"),
      ),
    );
  }
}
