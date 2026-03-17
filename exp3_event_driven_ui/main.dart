import 'package:flutter/material.dart';

void main() => runApp(const EventApp());

class EventApp extends StatelessWidget {
  const EventApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Driven UI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.orange),
      home: const EventScreen(),
    );
  }
}

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});
  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  String _output = '';
  int _counter = 0;
  Color _bgColor = Colors.white;
  double _fontSize = 20;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() {
      if (_nameCtrl.text.isEmpty || _emailCtrl.text.isEmpty) {
        _output = 'Please fill all fields!';
      } else {
        _output = 'Hello, ${_nameCtrl.text}!\nEmail: ${_emailCtrl.text}';
      }
    });
  }

  void _changeColor() {
    final colors = [Colors.yellow.shade100, Colors.green.shade100, Colors.blue.shade100, Colors.pink.shade100];
    setState(() => _bgColor = colors[_counter % colors.length]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: const Text('Event Driven UI'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                'https://picsum.photos/400/200',
                height: 160,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 160, color: Colors.orange.shade100,
                  child: const Icon(Icons.image, size: 60, color: Colors.orange),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: 'Enter Name',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailCtrl,
              decoration: InputDecoration(
                labelText: 'Enter Email',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.send),
              label: const Text('Submit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            if (_output.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange),
                ),
                child: Text(_output, style: TextStyle(fontSize: _fontSize)),
              ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle, size: 36, color: Colors.red),
                  onPressed: () => setState(() { if (_counter > 0) _counter--; }),
                ),
                Text('$_counter', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add_circle, size: 36, color: Colors.green),
                  onPressed: () => setState(() => _counter++),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _changeColor,
              icon: const Icon(Icons.color_lens),
              label: const Text('Change Background Color'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Font Size: '),
                Expanded(
                  child: Slider(
                    value: _fontSize,
                    min: 12, max: 36,
                    onChanged: (v) => setState(() => _fontSize = v),
                  ),
                ),
                Text('${_fontSize.round()}px'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
