import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nsbm_student_academic_tracker/models/event_model.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<DateTime, List<EventModel>>> fetchEvents(String uid) async {
    try {
      final querySnapshot = await _firestore
          .collection('student')
          .doc(uid)
          .collection('events')
          .get();
      final Map<DateTime, List<EventModel>> eventsMap = {};

      for (var doc in querySnapshot.docs) {
        final event = EventModel.fromMap(doc.data(), doc.id);
        final eventDate = DateTime(
          event.startDate.year,
          event.startDate.month,
          event.startDate.day,
        );
        eventsMap.putIfAbsent(eventDate, () => []);
        eventsMap[eventDate]!.add(event);
      }
      return eventsMap;
    } catch (e) {
      print("Error fetching events: $e");
      return {};
    }
  }

  Future<EventModel?> sendEvent(String uid, EventModel newEvent) async {
    try {
      final docRef = await _firestore
          .collection('student')
          .doc(uid)
          .collection('events')
          .add(newEvent.toMap());
      return EventModel(
        title: newEvent.title,
        description: newEvent.description,
        startDate: newEvent.startDate,
        endDate: newEvent.endDate,
        location: newEvent.location,
        id: docRef.id,
      );
    } catch (e) {
      print("Error sending event: $e");
      return null;
    }
  }
}
