import 'package:flutter/material.dart';

void main() {
  runApp(const CoachingApp());
}

class Student {
  String id;
  String name;
  String className;
  String rollNo;
  String contact;
  String parentContact;
  DateTime admissionDate;
  double monthlyFee;

  Student({
    required this.id,
    required this.name,
    required this.className,
    required this.rollNo,
    required this.contact,
    required this.parentContact,
    required this.admissionDate,
    required this.monthlyFee,
  });
}

class FeeRecord {
  String id;
  String studentId;
  DateTime date;
  double amount;
  String month;

  FeeRecord({
    required this.id,
    required this.studentId,
    required this.date,
    required this.amount,
    required this.month,
  });
}

class AttendanceRecord {
  String studentId;
  DateTime date;
  String status; // 'Present', 'Absent', 'Late'

  AttendanceRecord({
    required this.studentId,
    required this.date,
    required this.status,
  });
}

class AppState extends ChangeNotifier {
  List<Student> students = [
    Student(
      id: '1',
      name: 'Rahul Kumar',
      className: '10th',
      rollNo: '101',
      contact: '9876543210',
      parentContact: '9876543211',
      admissionDate: DateTime.now().subtract(const Duration(days: 30)),
      monthlyFee: 1500,
    ),
    Student(
      id: '2',
      name: 'Priya Singh',
      className: '10th',
      rollNo: '102',
      contact: '9876543212',
      parentContact: '9876543213',
      admissionDate: DateTime.now().subtract(const Duration(days: 60)),
      monthlyFee: 1500,
    ),
  ];

  List<FeeRecord> feeRecords = [];
  List<AttendanceRecord> attendanceRecords = [];

  void addStudent(Student student) {
    students.add(student);
    notifyListeners();
  }

  void addFeeRecord(FeeRecord record) {
    feeRecords.add(record);
    notifyListeners();
  }

  void markAttendance(String studentId, DateTime date, String status) {
    attendanceRecords.removeWhere((a) =>
        a.studentId == studentId &&
        a.date.year == date.year &&
        a.date.month == date.month &&
        a.date.day == date.day);
    attendanceRecords.add(
        AttendanceRecord(studentId: studentId, date: date, status: status));
    notifyListeners();
  }

  String getAttendanceStatus(String studentId, DateTime date) {
    final record = attendanceRecords.where((a) =>
        a.studentId == studentId &&
        a.date.year == date.year &&
        a.date.month == date.month &&
        a.date.day == date.day).firstOrNull;
    return record?.status ?? 'Not Marked';
  }

  double get pendingFees {
    double totalExpected = students.fold(0.0, (sum, s) => sum + s.monthlyFee);
    double totalCollectedThisMonth = feeRecords
        .where((f) => f.date.month == DateTime.now().month && f.date.year == DateTime.now().year)
        .fold(0.0, (sum, f) => sum + f.amount);
    return totalExpected > totalCollectedThisMonth
        ? totalExpected - totalCollectedThisMonth
        : 0;
  }

  double get collectedFees {
    return feeRecords
        .where((f) => f.date.month == DateTime.now().month && f.date.year == DateTime.now().year)
        .fold(0.0, (sum, f) => sum + f.amount);
  }
}

final appState = AppState();

class CoachingApp extends StatelessWidget {
  const CoachingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Coaching Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MainScreen(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const StudentsScreen(),
    const AttendanceScreen(),
    const FeesScreen(),
  ];

  @override
  void initState() {
    super.initState();
    appState.addListener(_update);
  }

  @override
  void dispose() {
    appState.removeListener(_update);
    super.dispose();
  }

  void _update() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Coaching Manager'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.people), label: 'Students'),
          NavigationDestination(icon: Icon(Icons.calendar_today), label: 'Attendance'),
          NavigationDestination(icon: Icon(Icons.currency_rupee), label: 'Fees'),
        ],
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dashboard', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Total Students',
                  '${appState.students.length}',
                  Icons.people,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Collected Fees',
                  '₹${appState.collectedFees}',
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Pending Fees',
                  '₹${appState.pendingFees}',
                  Icons.warning,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class StudentsScreen extends StatelessWidget {
  const StudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: appState.students.length,
        itemBuilder: (context, index) {
          final student = appState.students[index];
          return ListTile(
            leading: CircleAvatar(child: Text(student.name[0])),
            title: Text(student.name),
            subtitle: Text('Class: ${student.className} | Roll: ${student.rollNo}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Edit or View Details
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add student
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Date: ${_selectedDate.toString().split(' ')[0]}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ElevatedButton(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    setState(() {
                      _selectedDate = date;
                    });
                  }
                },
                child: const Text('Change Date'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: appState.students.length,
            itemBuilder: (context, index) {
              final student = appState.students[index];
              final status = appState.getAttendanceStatus(student.id, _selectedDate);

              return ListTile(
                title: Text(student.name),
                subtitle: Text('Class: ${student.className}'),
                trailing: DropdownButton<String>(
                  value: status == 'Not Marked' ? null : status,
                  hint: const Text('Mark'),
                  items: ['Present', 'Absent', 'Late']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      appState.markAttendance(student.id, _selectedDate, val);
                      setState(() {});
                    }
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class FeesScreen extends StatelessWidget {
  const FeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: appState.students.length,
      itemBuilder: (context, index) {
        final student = appState.students[index];
        return ListTile(
          title: Text(student.name),
          subtitle: Text('Fee: ₹${student.monthlyFee} / month'),
          trailing: ElevatedButton(
            onPressed: () {
              appState.addFeeRecord(FeeRecord(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                studentId: student.id,
                date: DateTime.now(),
                amount: student.monthlyFee,
                month: '${DateTime.now().month}-${DateTime.now().year}',
              ));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Fee collected for ${student.name}')),
              );
            },
            child: const Text('Collect'),
          ),
        );
      },
    );
  }
}
