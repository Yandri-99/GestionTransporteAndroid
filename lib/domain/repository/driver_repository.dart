import '../model/driver.dart';

abstract class DriverRepository {
  Future<List<Driver>> getDrivers();
  Future<void> createDriver(Driver driver);
  Future<void> updateDriver(Driver driver);
  Future<void> deleteDriver(int id);
}
