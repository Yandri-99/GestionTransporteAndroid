import '../model/driver_assignment.dart';

abstract class DriverAssignmentRepository {
  Future<List<DriverAssignment>> getAssignments();
  Future<void> createAssignment(DriverAssignment assignment);
  Future<void> updateAssignment(DriverAssignment assignment);
  Future<void> deleteAssignment(int id);
}
