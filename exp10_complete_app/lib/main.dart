import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exp 10 - Complete App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AuthCheck(),
    );
  }
}

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});
  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  bool? _isAuth;
  @override
  void initState() {
    super.initState();
    _check();
  }
  Future<void> _check() async {
    final p = await SharedPreferences.getInstance();
    setState(() => _isAuth = p.getBool('auth') ?? false);
  }
  @override
  Widget build(BuildContext context) {
    return _isAuth == null ? const Scaffold(body: Center(child: CircularProgressIndicator())) : _isAuth! ? const DashboardPage() : const LoginPage();
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _u = TextEditingController();
  final _p = TextEditingController();
  String _err = '';
  Future<void> _login() async {
    if (_u.text == 'lab' && _p.text == '123') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('auth', true);
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardPage()));
    } else {
      setState(() => _err = 'Invalid! Use lab/123');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 80, color: Colors.blue),
              const SizedBox(height: 20),
              const Text('Complete App Login', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextField(controller: _u, decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: _p, obscureText: true, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder())),
              if (_err.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_err, style: const TextStyle(color: Colors.red))),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _login, child: const Text('Login')),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});
  Future<void> _logout(BuildContext context) async {
    final p = await SharedPreferences.getInstance();
    await p.clear();
    if (context.mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: () => _logout(context))],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        children: [
          _tile(context, 'Local Data\n(SQLite)', Icons.storage, const LocalDBPage()),
          _tile(context, 'Remote Data\n(REST API)', Icons.cloud, const RemoteDataPage()),
          _tile(context, 'User Profile', Icons.person, const ProfilePage()),
          _tile(context, 'Settings', Icons.settings, const SettingsPage()),
        ],
      ),
    );
  }
  Widget _tile(BuildContext ctx, String t, IconData i, Widget p) {
    return Card(
      child: InkWell(
        onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => p)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(i, size: 48, color: Colors.blue), const SizedBox(height: 12), Text(t, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16))],
        ),
      ),
    );
  }
}

class LocalDBPage extends StatefulWidget {
  const LocalDBPage({super.key});
  @override
  State<LocalDBPage> createState() => _LocalDBPageState();
}

class _LocalDBPageState extends State<LocalDBPage> {
  List<Map<String, dynamic>> _data = [];
  final _ctrl = TextEditingController();
  late Database _db;
  @override
  void initState() {
    super.initState();
    _initDB();
  }
  Future<void> _initDB() async {
    _db = await openDatabase(join(await getDatabasesPath(), 'items.db'), version: 1, onCreate: (db, v) async {
      await db.execute('CREATE TABLE items(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT)');
    });
    _load();
  }
  Future<void> _load() async {
    final r = await _db.query('items');
    setState(() => _data = r);
  }
  Future<void> _add() async {
    if (_ctrl.text.isEmpty) return;
    await _db.insert('items', {'name': _ctrl.text});
    _ctrl.clear();
    _load();
  }
  Future<void> _del(int id) async {
    await _db.delete('items', where: 'id = ?', whereArgs: [id]);
    _load();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Local Storage - SQLite')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _ctrl, decoration: const InputDecoration(labelText: 'Item name', border: OutlineInputBorder()))),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _add, child: const Icon(Icons.add)),
              ],
            ),
          ),
          Expanded(
            child: _data.isEmpty
                ? const Center(child: Text('No items'))
                : ListView.builder(
                    itemCount: _data.length,
                    itemBuilder: (ctx, i) {
                      final item = _data[i];
                      return ListTile(
                        title: Text(item['name']),
                        trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _del(item['id'])),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class RemoteDataPage extends StatefulWidget {
  const RemoteDataPage({super.key});
  @override
  State<RemoteDataPage> createState() => _RemoteDataPageState();
}

class _RemoteDataPageState extends State<RemoteDataPage> {
  List<dynamic> _posts = [];
  bool _loading = false;
  @override
  void initState() {
    super.initState();
    _fetch();
  }
  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final r = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts?_limit=10'));
      if (r.statusCode == 200) setState(() => _posts = jsonDecode(r.body));
    } catch (_) {}
    setState(() => _loading = false);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('REST API - Posts')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _posts.length,
              itemBuilder: (ctx, i) {
                final p = _posts[i];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(title: Text(p['title']), subtitle: Text(p['body'], maxLines: 2)),
                );
              },
            ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)), SizedBox(height: 16), Text('Lab User', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), SizedBox(height: 8), Text('lab@flutter.dev', style: TextStyle(color: Colors.grey))],
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Settings')), body: ListView(children: const [ListTile(leading: Icon(Icons.notifications), title: Text('Notifications')), ListTile(leading: Icon(Icons.security), title: Text('Privacy')), ListTile(leading: Icon(Icons.info), title: Text('About'))]));
  }
}
