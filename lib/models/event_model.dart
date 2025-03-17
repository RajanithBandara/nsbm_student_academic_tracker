//this is the model to store the calender events on firebase firestore
import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final String id;

  EventModel({
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.id,
  });

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "description": description,
      "startDate": startDate,
      "endDate": endDate,
      "location": location,
      "id": id,
    };
  }

  factory EventModel.fromMap(Map<String, dynamic> map, String id) {
    return EventModel(
      title: map["title"],
      description: map["description"],
      startDate: (map["startDate"] as Timestamp).toDate(),
      endDate: (map["endDate"] as Timestamp).toDate(),
      location: map["location"],
      id: id,
    );
  }
}