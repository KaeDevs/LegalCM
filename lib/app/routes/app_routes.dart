import 'package:get/get.dart';
import 'package:legalcm/app/modules/cases/add_cases_view.dart';
import '../modules/clients/add_client_view.dart';
import '../modules/dashboard/view.dart';
import '../modules/cases/view.dart';

import '../modules/clients/view.dart';
import '../modules/calendar/view.dart';

class AppPages{
  static const initial = '/dashboard' ;

  static final routes = [
    GetPage(name: '/dashboard', page: () => const DashboardView()),
    GetPage(name: '/cases', page: () => const CasesView()),
    GetPage(name: '/add-case', page: () => const AddCaseView()),
    GetPage(name: '/clients', page: () => const ClientsView()),
    GetPage(name: '/add-client', page: () => AddClientView()),
    GetPage(name: '/calendar', page: () => const CalendarView()),
  ];
}