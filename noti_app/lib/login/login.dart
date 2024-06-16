import 'package:flutter/material.dart';
import 'package:noti_app/homepage/homepage.dart'; // Cần thay thế với đường dẫn đúng nếu bạn có màn hình khác

class LoginScreen extends StatelessWidget {
  final List<Map<String, String>> accounts = [
    {
      'name': 'Hoàng Minh Ngọc',
      'image': 'assets/images/avatar.png',
      'username': 'user1'
    },
    {
      'name': 'Nguyễn Văn A',
      'image': 'assets/images/vanA.jpg',
      'username': 'user2'
    },
    {
      'name': 'Trần Thị B',
      'image': 'assets/images/thiB.jpg',
      'username': 'user3'
    },
    {
      'name': 'Lê Văn C',
      'image': 'assets/images/vanC.jpg',
      'username': 'user4'
    },
  ];

  final String validUsername = 'user1';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 50.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Chọn tài khoản của bạn',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: accounts.length,
                  itemBuilder: (context, index) {
                    final account = accounts[index];
                    return GestureDetector(
                      onTap: () {
                        if (account['username'] == validUsername) {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => HomePage(), // Thay thế HomePage bằng màn hình của bạn
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                const begin = Offset(1.0, 0.0);
                                const end = Offset.zero;
                                const curve = Curves.ease;

                                var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                                return SlideTransition(
                                  position: animation.drive(tween),
                                  child: child,
                                );
                              },
                            ),
                          );
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Đăng Nhập Thất Bại', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(account['image']!),
                                    SizedBox(height: 20),
                                    Text(account['name']!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
                                    //Text('Login thất bại.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                      child: Card(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                        child: ListTile(
                          contentPadding: EdgeInsets.all(10),
                          leading: CircleAvatar(
                            backgroundImage: AssetImage(account['image']!),
                          ),
                          title: Text(
                            account['name']!,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
