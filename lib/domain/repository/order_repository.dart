import '../model/order.dart';

abstract class OrderRepository {
  Future<List<Incident>> getIncidents({String? status, String? severity});
  Future<void> createIncident(Incident incident);
  Future<void> resolveIncident(int id);
  Future<void> deleteIncident(int id);
}
