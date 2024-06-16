import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  uploadDataToFirestore();
}

void uploadDataToFirestore() async {
  final List<Map<String, String>> data = [
    {"title": "eHUST", "description": "Bạn có lớp học Kỹ năng ITSS học bằng tiếng Nhật 2 lúc 14h10 B1-404", "time": "13:50", "datetime": "2024-06-06"},
    {"title": "Teams", "description": "Sao anh không rep tin nhắn của em", "time": "14:30", "datetime": "2024-06-06"},
    {"title": "eHUST", "description": "Bạn có lớp học Kỹ năng ITSS học bằng tiếng Nhật 2 lúc 14h10 B1-404", "time": "13:50", "datetime": "2024-06-06"},
    {"title": "Teams", "description": "Bạn có cuộc họp với team lúc 15h00", "time": "14:30", "datetime": "2024-06-06"},
    {"title": "Outlook", "description": "Bạn có cuộc họp với đối tác lúc 10h00", "time": "09:30", "datetime": "2024-05-12"},
    {"title": "Outlook", "description": "Bạn tham gia workshop phát triển kỹ năng mềm lúc 16h00", "time": "15:30", "datetime": "2024-05-15"},
    {"title": "Outlook", "description": "Bạn tham gia hội thảo về công nghệ AI lúc 09h00", "time": "08:30", "datetime": "2024-05-18"},
    {"title": "Outlook", "description": "Bạn tham gia webinar về Flutter lúc 19h00", "time": "18:30", "datetime": "2024-05-21"},
    {"title": "eHUST", "description": "Buổi đào tạo kỹ năng giao tiếp lúc 14h00", "time": "13:30", "datetime": "2024-05-25"},
    {"title": "QLDT", "description": "Tham dự seminar về blockchain lúc 11h00", "time": "10:30", "datetime": "2024-05-28"},
    {"title": "QLDT", "description": "Điểm giữa kì kỹ năng mềm của bạn đã được nhập ", "time": "07:30", "datetime": "2024-06-01"},
    {"title": "Outlook", "description": "Hoạt động team building lúc 17h00", "time": "16:30", "datetime": "2024-06-07"},
    {"title": "Outlook", "description": "Thuyết trình dự án lúc 10h30", "time": "10:00", "datetime": "2024-06-10"},
    {"title": "eHUST", "description": "Hội thảo về kỹ năng làm việc nhóm lúc 10h00", "time": "09:30", "datetime": "2024-06-12"},
    {"title": "Teams", "description": "Cuộc họp triển khai dự án mới lúc 14h00", "time": "13:30", "datetime": "2024-06-15"},
    {"title": "Outlook", "description": "Tham gia buổi học trực tuyến về quản lý thời gian lúc 11h00", "time": "10:30", "datetime": "2024-06-18"},
    {"title": "QLDT", "description": "Buổi thảo luận về chiến lược marketing lúc 15h00", "time": "14:30", "datetime": "2024-06-20"},
    {"title": "eHUST", "description": "Báo cáo tiến độ dự án ITSS lúc 09h00", "time": "08:30", "datetime": "2024-06-22"},
    {"title": "Teams", "description": "Cuộc họp định kỳ với khách hàng lúc 16h00", "time": "15:30", "datetime": "2024-06-24"},
    {"title": "Outlook", "description": "Tham gia sự kiện công nghệ thông tin lúc 14h00", "time": "13:00", "datetime": "2024-06-27"},
    {"title": "QLDT", "description": "Hội thảo về trí tuệ nhân tạo lúc 17h00", "time": "16:30", "datetime": "2024-06-29"},
    {"title": "eHUST", "description": "Thuyết trình kế hoạch phát triển sản phẩm lúc 10h00", "time": "09:30", "datetime": "2024-07-02"},
    {"title": "Teams", "description": "Tham gia buổi thảo luận về phát triển ứng dụng di động lúc 13h00", "time": "12:30", "datetime": "2024-07-04"},
    {"title": "Outlook", "description": "Workshop về thiết kế UX/UI lúc 15h00", "time": "14:30", "datetime": "2024-07-06"},
    {"title": "QLDT", "description": "Buổi đào tạo về công cụ quản lý dự án lúc 09h00", "time": "08:30", "datetime": "2024-07-08"}
  ];

  final collectionRef = FirebaseFirestore.instance.collection('notifications');

  for (var item in data) {
    await collectionRef.add(item);
  }

  print('Data has been successfully added to Firestore');
}
