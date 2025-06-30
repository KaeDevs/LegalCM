import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/case_model.dart';
import '../../data/models/client_model.dart';
import '../clients/add_client_view.dart';


class AddCaseView extends StatefulWidget {
  final CaseModel? existingCase;

  const AddCaseView({super.key, this.existingCase});

  @override
  State<AddCaseView> createState() => _AddCaseViewState();
}

class _AddCaseViewState extends State<AddCaseView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _courtController = TextEditingController();
  final _courtNoController = TextEditingController();
  final _notesController = TextEditingController();

  String _status = 'Pending';
  DateTime _hearingDate = DateTime.now();

  ClientModel? _selectedClient;
  List<ClientModel> _clients = [];

  @override
  void initState() {
    super.initState();
    _clients = Hive.box<ClientModel>('clients').values.toList();

    if (widget.existingCase != null) {
      final c = widget.existingCase!;
      _titleController.text = c.title;
      _courtController.text = c.court;
      _courtNoController.text = c.courtNo;
      _notesController.text = c.notes;
      _status = c.status;
      _hearingDate = c.nextHearing;
      if (c.clientId != null) {
        _selectedClient = _clients.firstWhereOrNull((cl) => cl.id == c.clientId);
      }
    }
  }

  void _saveCase() async {
    if (_formKey.currentState!.validate() && _selectedClient != null) {
      if (widget.existingCase != null) {
        widget.existingCase!
          ..title = _titleController.text.trim()
          ..clientName = _selectedClient!.name
          ..clientId = _selectedClient!.id
          ..court = _courtController.text.trim()
          ..status = _status
          ..nextHearing = _hearingDate
          ..notes = _notesController.text.trim();
        await widget.existingCase!.save();
        Get.back();
        Get.snackbar('Updated', 'Case updated successfully!');
      } else {
        final newCase = CaseModel(
          id: const Uuid().v4(),
          title: _titleController.text.trim(),
          clientName: _selectedClient!.name,
          clientId: _selectedClient!.id,
          court: _courtController.text.trim(),
          courtNo: _courtNoController.text.trim(),
          status: _status,
          nextHearing: _hearingDate,
          notes: _notesController.text.trim(),
        );
        await Hive.box<CaseModel>('cases').add(newCase);
        Get.back();
        Get.snackbar('Success', 'Case added successfully!');
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _hearingDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _hearingDate = picked);
  }

  void _addNewClient() async {
    await Get.to(() => AddClientView());
    setState(() {
      _clients = Hive.box<ClientModel>('clients').values.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Case')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Case Title'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<ClientModel>(
                      value: _selectedClient,
                      items: _clients
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(c.name),
                              ))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedClient = val),
                      decoration: const InputDecoration(labelText: 'Client'),
                      validator: (val) => val == null ? 'Select a client' : null,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addNewClient,
                    tooltip: 'Add New Client',
                  )
                ],
              ),
              TextFormField(
                controller: _courtController,
                decoration: const InputDecoration(labelText: 'Court'),
              ),
              TextFormField(
                controller: _courtNoController,
                decoration: const InputDecoration(labelText: 'Court No'),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField<String>(
                value: _status,
                items: ['Pending', 'In Progress', 'Closed']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) => setState(() => _status = val!),
                decoration: const InputDecoration(labelText: 'Status'),
              ),
              ListTile(
                title: const Text('Next Hearing Date'),
                subtitle: Text(
                  '${_hearingDate.day}/${_hearingDate.month}/${_hearingDate.year}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _saveCase,
                icon: const Icon(Icons.save),
                label: const Text('Save Case'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
