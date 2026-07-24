import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._();
  factory AnalyticsService() => _instance;
  AnalyticsService._();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  Future<void> logLogin(String method) async {
    await _analytics.logLogin(loginMethod: method);
  }

  Future<void> logLogout() async {
    await _analytics.logEvent(name: 'logout');
  }

  Future<void> logRouteView(String routeCode) async {
    await _analytics.logEvent(
      name: 'route_view',
      parameters: {'route_code': routeCode},
    );
  }

  Future<void> logIncidentCreated(String type, String severity) async {
    await _analytics.logEvent(
      name: 'incident_created',
      parameters: {'type': type, 'severity': severity},
    );
  }

  Future<void> logIncidentViewed(int incidentId) async {
    await _analytics.logEvent(
      name: 'incident_viewed',
      parameters: {'incident_id': incidentId},
    );
  }

  Future<void> logMapOpened(String source) async {
    await _analytics.logEvent(
      name: 'map_opened',
      parameters: {'source': source},
    );
  }

  Future<void> logSearch(String query) async {
    await _analytics.logSearch(searchTerm: query);
  }

  Future<void> logAdminAction(String action) async {
    await _analytics.logEvent(
      name: 'admin_action',
      parameters: {'action': action},
    );
  }

  Future<void> setUserRole(String role) async {
    await _analytics.setUserProperty(name: 'role', value: role);
  }
}
