import 'package:flutter/material.dart';

class InspectionFormScreen extends StatefulWidget {
  final String schoolUdiseCode;

  const InspectionFormScreen({Key? key, required this.schoolUdiseCode}) : super(key: key);

  @override
  _InspectionFormScreenState createState() => _InspectionFormScreenState();
}

class _InspectionFormScreenState extends State<InspectionFormScreen> {
  bool _infraVerified = false;
  bool _pedagogyMet = false;
  final TextEditingController _remarksController = TextEditingController();

  void _submitInspection() {
    // TODO: Link with InspectionModel and backend API
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Inspection Report Submitted Successfully')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log School Inspection'),
        backgroundColor: Colors.teal[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'School UDISE: ${widget.schoolUdiseCode}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Infrastructure Verified'),
                      subtitle: const Text('Toilets, labs, and classrooms match UDISE+ data'),
                      value: _infraVerified,
                      onChanged: (val) => setState(() => _infraVerified = val),
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text('Pedagogical Standards Met'),
                      subtitle: const Text('NIPUN Bharat & lesson plans followed'),
                      value: _pedagogyMet,
                      onChanged: (val) => setState(() => _pedagogyMet = val),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _remarksController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Inspector Remarks',
                border: OutlineInputBorder(),
                hintText: 'Add details about discrepancies or best practices found...',
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _submitInspection,
                icon: const Icon(Icons.send),
                label: const Text('Submit Report', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal[700],
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
