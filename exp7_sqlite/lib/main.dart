import 'package:flutter/material.dart';
import 'database_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exp 7 - SQLite',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
      home: const StudentListPage(),
    );
  }
}

class StudentListPage extends StatefulWidget {
  const StudentListPage({super.key});
  @override
  State<StudentListPage> createState() => _StudentListPageState();
}

class _StudentListPageState extends State<StudentListPage> {
  final DatabaseHelper _db = DatabaseHelper();
  List<Map<String, dynamic>> _students = [];
  final _nameCtrl = TextEditingController();
  final _markCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final data = await _db.getStudents();
    setState(() => _students = data);
  }

  Future<void> _addStudent() async {
    if (_nameCtrl.text.isEmpty || _markCtrl.text.isEmpty) return;
    await _db.insertStudent({
      'name': _nameCtrl.text,
      'marks': int.tryParse(_markCtrl.text) ?? 0,
    });
    _nameCtrl.clear();
    _markCtrl.clear();
    _loadStudents();
  }

  Future<void> _deleteStudent(int id) async {
    await _db.deleteStudent(id);
    _loadStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SQLite - Student Records'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Student Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _markCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Marks',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _addStudent,
              icon: const Icon(Icons.add),
              label: const Text('Add Student'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
            ),
            const Divider(height: 24),
            Expanded(
              child: _students.isEmpty
                  ? const Center(child: Text('No records found.'))
                  : ListView.builder(
                      itemCount: _students.length,
                      itemBuilder: (ctx, i) {
                        final s = _students[i];
                        return Card(
                          child: ListTile(
                            leading: const CircleAvatar(child: Icon(Icons.person)),
                            title: Text(s['name']),
                            subtitle: Text('Marks: \${s['marks']}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteStudent(s['id']),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
