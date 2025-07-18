import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drive_or_drunk_app/models/ride_model.dart' show Ride;
import 'package:drive_or_drunk_app/models/conversation_model.dart'
    as conversation_model;
import 'package:drive_or_drunk_app/models/conversation_model.dart'
    show Conversation;
import 'package:drive_or_drunk_app/models/event_model.dart' as event_model;
import 'package:drive_or_drunk_app/models/event_model.dart' show Event;
import 'package:drive_or_drunk_app/models/review_model.dart' as review_model;
import 'package:drive_or_drunk_app/models/review_model.dart' show Review;
import 'package:drive_or_drunk_app/models/ride_model.dart' as ride_model;
import 'package:drive_or_drunk_app/models/user_model.dart' as user_model;
import 'package:drive_or_drunk_app/models/user_model.dart' show User;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

// ==================== USER METHODS ====================
  Future<void> addUser(User user) async {
    return user_model.addUser(user, _db);
  }

  Future<User?> getUser(String id) async {
    return user_model.getUser(id, _db);
  }

  Future<DocumentReference?> getUserReference(String id) async {
    return user_model.getUserReference(id, _db);
  }

  Stream<List<User>> getUsers() {
    return user_model.getUsers(_db);
  }

  Stream<List<User>> searchUsersByName(String name) {
    return user_model.searchUsersByName(name, _db);
  }

  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    return user_model.updateUser(id, data, _db);
  }

  Future<void> deleteUser(String id) async {
    return user_model.deleteUser(id, _db);
  }

  Future<void> addFavoriteUser(
      DocumentReference userRef, User currentUser) async {
    return user_model.addFavoriteUser(userRef, currentUser, _db);
  }

  Future<void> removeFavoriteUser(
      DocumentReference userRef, User currentUser) async {
    return user_model.removeFavoriteUser(userRef, currentUser, _db);
  }

  Future<void> addFavoriteEvent(Event event, String userId) async {
    return user_model.addFavoriteEvent(event, userId, _db);
  }

  Future<void> removeFavoriteEvent(Event event, String userId) async {
    return user_model.removeFavoriteEvent(event, userId, _db);
  }

  Future<void> addReviewToUser(DocumentReference reviewRef, User user) async {
    return user_model.addReview(reviewRef, user, _db);
  }

  Future<List<Review>> getReviewsByType(User user, String reviewType) async {
    return user_model.getReviewsByType(user, _db, reviewType);
  }

  Future<double> getAverageRating(User user, String reviewType) async {
    return user_model.calculateRatingAverage(user, _db, reviewType);
  }

// ==================== EVENT METHODS ====================
  Future<void> addEvent(Event event) async {
    return event_model.addEvent(event, _db);
  }

  Future<Event?> getEvent(String id) async {
    return event_model.getEvent(id, _db);
  }

  Future<DocumentReference?> getEventReference(String id) async {
    return event_model.getEventReference(id, _db);
  }

  Stream<List<Event>> getEvents() {
    return event_model.getEvents(_db);
  }

  Stream<List<Event>> searchEvents({
    String? eventName,
    String? place,
    DateTimeRange? dateRange,
    LatLng? locationSearchCenter,
  }) {
    return event_model.searchEvents(
        eventName: eventName,
        place: place,
        dateRange: dateRange,
        locationSearchCenter: locationSearchCenter,
        _db);
  }

  Future<void> updateEvent(String id, Map<String, dynamic> data) async {
    return event_model.updateEvent(id, data, _db);
  }

  Future<void> deleteEvent(String id) async {
    return event_model.deleteEvent(id, _db);
  }

  Future<void> addDriverToEvent(
      String eventId, DocumentReference driverRef) async {
    return event_model.addDriver(eventId, driverRef, _db);
  }

  Future<void> addDrunkardToEvent(
      String eventId, DocumentReference drunkardRef) async {
    return event_model.addDrunkard(eventId, drunkardRef, _db);
  }

  Future<void> removeDriverFromEvent(
      String eventId, DocumentReference driverRef) async {
    return event_model.removeDriver(eventId, driverRef, _db);
  }

  Future<void> removeDrunkardFromEvent(
      String eventId, DocumentReference drunkardRef) async {
    return event_model.removeDrunkard(eventId, drunkardRef, _db);
  }

// ==================== RIDE METHODS ====================
  Future<void> addRide(Ride ride) async {
    return ride_model.addRide(ride, _db);
  }

  Future<Ride?> getRide(String id) async {
    return ride_model.getRide(id, _db);
  }

  Stream<List<Ride>> getRidesByDriver(String userId) {
    return ride_model.getRidesByDriver(userId, _db);
  }

  Stream<List<Ride>> getRidesByEvent(String eventId) {
    return ride_model.getRidesByEvent(eventId, _db);
  }

  Stream<List<Ride>> getRidesByDrunkard(String userId) {
    return ride_model.getRidesByDrunkard(userId, _db);
  }

  Future<void> updateRide(String id, Map<String, dynamic> data) async {
    return ride_model.updateRide(id, data, _db);
  }

  Future<void> deleteRide(String id) async {
    return ride_model.deleteRide(id, _db);
  }

  Future<void> addDrunkardToRide(
      String rideId, DocumentReference<User> drunkardRef) async {
    return ride_model.addDrunkard(rideId, drunkardRef, _db);
  }

  Future<void> removeDrunkardFromRide(
      String rideId, DocumentReference<User> drunkardRef) async {
    return ride_model.removeDrunkard(rideId, drunkardRef, _db);
  }

// ==================== CONVERSATION METHODS ====================

  Future<void> setMessageSeen(String messageId) async {
    return conversation_model.setMessageSeen(messageId, _db);
  }

  Future<void> addConversation(Conversation conversation) async {
    return conversation_model.addConversation(conversation, _db);
  }

  Future<Conversation?> getConversation(String id) async {
    return conversation_model.getConversation(id, _db);
  }

  Stream<List<conversation_model.Conversation>> getConversations(
      DocumentReference userReference) {
    return conversation_model.getConversations(_db, userReference);
  }

  Future<void> updateConversation(String id, Map<String, dynamic> data) async {
    return conversation_model.updateConversation(id, data, _db);
  }

  Future<void> deleteConversation(String id) async {
    return conversation_model.deleteConversation(id, _db);
  }

  Future<void> sendMessage(
      String conversationId, conversation_model.Message message) async {
    return conversation_model.sendMessage(conversationId, message, _db);
  }

  Future<String> getOrCreateConversationId(
      DocumentReference user1, DocumentReference user2) async {
    return conversation_model.getOrCreateConversationId(user1, user2, _db);
  }

  Stream<List<conversation_model.Message>> getMessageStream(
      String conversationId) {
    return conversation_model.getMessagesStream(conversationId, _db);
  }

  Future<conversation_model.Message?> getMostRecentMessageFromConversation(
      Conversation conversation) async {
    return conversation_model.getMostRecentMessageFromConversation(
        conversation, _db);
  }

  Future<int> countUnseenMessages(
      Conversation conversationId, String userId) async {
    return conversation_model.countUnseenMessages(conversationId, userId, _db);
  }

// ==================== REVIEW METHODS ====================
  Future<void> addReview(Review review, User user) async {
    final reviewRef = await review_model.addReview(review, _db);
    user_model.addReview(reviewRef, user, _db);
  }

  Future<Review?> getReview(String id) async {
    return review_model.getReview(id, _db);
  }

  Stream<List<Review>> getReviews() {
    return review_model.getReviews(_db);
  }

  Future<void> updateReview(String id, Map<String, dynamic> data) async {
    return review_model.updateReview(id, data, _db);
  }

  Future<void> deleteReview(String id) async {
    return review_model.deleteReview(id, _db);
  }

  Future<User> getAuthor(Review review) async {
    return review_model.getAuthor(review, _db);
  }
}
