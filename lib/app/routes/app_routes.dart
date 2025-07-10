import 'package:get/get.dart';
import 'package:legalcm/app/modules/billing/add_time_entry_view.dart';
import 'package:legalcm/app/modules/billing/expense/expense_list_view.dart';
import 'package:legalcm/app/modules/billing/invoice/invoiceListView.dart';
import 'package:legalcm/app/modules/cases/add_cases_view.dart';
import 'package:legalcm/app/modules/dashboard/binding.dart';
import '../modules/billing/billing_overview_view.dart';
import '../modules/billing/expense/add_expense_view.dart';
import '../modules/billing/invoice/addInvoiceView.dart';
import '../modules/billing/timeEntry/timeEntryListView.dart';
import '../modules/cases/case_binding.dart';
import '../modules/clients/add_client_view.dart';
import '../modules/clients/client_binding.dart';
import '../modules/dashboard/view.dart';
import '../modules/cases/view.dart';
import '../modules/login/binding.dart';
import '../modules/login/view.dart';

import '../modules/clients/view.dart';
import '../modules/calendar/view.dart';
import '../modules/tasks/add_task_view.dart';
import '../modules/tasks/view.dart';

class AppPages {
  static const initial = '/login';

  static final routes = [
    GetPage(
        name: '/login',
        page: () => const LoginView(),
        binding: LoginBinding()),
    GetPage(
        name: '/dashboard',
        page: () => const DashboardView(),
        binding: dashBoardBinding()),
    GetPage(name: '/cases', page: () => const CasesView(), binding: CaseBinding()),
    GetPage(name: '/add-case', page: () => const AddCaseView()),
    GetPage(name: '/clients', page: () => const ClientsView(), binding: ClientBinding()),
    GetPage(name: '/add-client', page: () => AddClientView()),
    GetPage(name: '/calendar', page: () => const CalendarView()),
    GetPage(name: '/tasks', page: () => TaskListView()),
    GetPage(name: '/add-task', page: () => const AddTaskView()),
    GetPage(name: '/add-time-entry', page: () => const AddTimeEntryView()),
    GetPage(name: '/time-entries',page: () => const TimeEntryListView(),),
    GetPage(name: '/add-expense', page: () => const AddExpenseView()),
    GetPage(name: '/expense-list', page: () => const ExpenseListView()),
    GetPage(name: '/billing', page: () => const BillingOverviewView()),
    GetPage(name: '/invoice-list', page: () => const InvoiceListView()),
    GetPage(name: '/add-invoice', page: () => const AddInvoiceView()),


  ];
}
