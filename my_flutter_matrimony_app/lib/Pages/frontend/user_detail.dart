// import 'package:flutter/material.dart';
//
// class UserDetailScreen extends StatelessWidget {//   final Map<String, dynamic> user;
//
//   UserDetailScreen({required this.user});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(user["fullName"] ?? "User Details"),
//         backgroundColor: Colors.blueAccent,
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(
//               child: CircleAvatar(
//                 radius: 50,
//                 backgroundColor: Colors.blue[100],
//                 child: Icon(Icons.person, size: 50, color: Colors.white),
//               ),
//             ),
//             SizedBox(height: 20),
//             ListTile(
//               leading: Icon(Icons.person, color: Colors.blue),
//               title: Text("Full Name"),
//               subtitle: Text(user["fullName"] ?? "N/A"),
//             ),
//             ListTile(
//               leading: Icon(Icons.location_on, color: Colors.orange),
//               title: Text("City"),
//               subtitle: Text(user["city"] ?? "N/A"),
//             ),
//             ListTile(
//               leading: Icon(Icons.phone, color: Colors.green),
//               title: Text("Mobile"),
//               subtitle: Text(user["mobile"] ?? "N/A"),
//             ),
//             ListTile(
//               leading: Icon(Icons.email, color: Colors.red),
//               title: Text("Email"),
//               subtitle: Text(user["email"] ?? "N/A"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
