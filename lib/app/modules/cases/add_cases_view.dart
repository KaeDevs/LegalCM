import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/case_model.dart';
import '../../data/models/client_model.dart';
import '../clients/add_client_view.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';


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
  final _petitionerController = TextEditingController();
  final _petitionerAdvController = TextEditingController();
  final _respondentController = TextEditingController();
  final _respondentAdvController = TextEditingController();
  String _status = 'Pending';
  DateTime _hearingDate = DateTime.now();
  List<String> _attachedFiles = [];

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
      _petitionerController.text = c.petitioner ?? '';
      _petitionerAdvController.text = c.petitionerAdv ?? '';
      _respondentController.text = c.respondent ?? '';
      _respondentAdvController.text = c.respondentAdv ?? '';
      _attachedFiles = List<String>.from(c.attachedFiles ?? []);

      if (c.clientId != null) {
        _selectedClient =
            _clients.firstWhereOrNull((cl) => cl.id == c.clientId);
      }
    }
  }

  void _saveCase() async {
    if (_formKey.currentState!.validate() && _selectedClient != null) {
      if (_attachedFiles.isNotEmpty) {
        // Text('${_attachedFiles.length} files attached');}
        print("Attached");
      } else {
        print("Not Attached");
      }

      if (widget.existingCase != null) {
        widget.existingCase!
          ..title = _titleController.text.trim()
          ..clientName = _selectedClient!.name
          ..clientId = _selectedClient!.id
          ..court = _courtController.text.trim()
          ..courtNo = _courtNoController.text.trim()
          ..status = _status
          ..nextHearing = _hearingDate
          ..notes = _notesController.text.trim()
          ..petitioner = _petitionerController.text.trim()
          ..petitionerAdv = _petitionerAdvController.text.trim()
          ..respondent = _respondentController.text.trim()
          ..respondentAdv = _respondentAdvController.text.trim()
          ..attachedFiles = _attachedFiles;

        await widget.existingCase!.save();
        Get.back(result: 'updated');

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
          petitioner: _petitionerController.text.trim(),
          petitionerAdv: _petitionerAdvController.text.trim(),
          respondent: _respondentController.text.trim(),
          respondentAdv: _respondentAdvController.text.trim(),
          attachedFiles: _attachedFiles
        );
        await Hive.box<CaseModel>('cases').add(newCase);
        Get.back(result: 'updated');

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

  Future<void> _pickFiles() async {
  final result = await FilePicker.platform.pickFiles(allowMultiple: true);
  if (result != null) {
    final files = result.paths.whereType<String>().toList();
    final localPaths = await saveFilesToLocalStorage(files);
    setState(() {
      _attachedFiles.addAll(localPaths);
    });
  }
}


  
Future<List<String>> saveFilesToLocalStorage(List<String> paths) async {
  final List<String> copiedPaths = [];
  final appDir = await getApplicationDocumentsDirectory();

  for (final originalPath in paths) {
    final file = File(originalPath);
    if (await file.exists()) {
      final newPath = p.join(appDir.path, p.basename(originalPath));
      await file.copy(newPath);
      copiedPaths.add(newPath);
    }
  }
  return copiedPaths;
}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingCase == null ? 'Add New Case' : 'Edit Case'),
      ),
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
              const SizedBox(height: 16),
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
                      validator: (val) =>
                          val == null ? 'Select a client' : null,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addNewClient,
                    tooltip: 'Add New Client',
                  )
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _courtController,
                decoration: const InputDecoration(labelText: 'Court'),
              ),
              const SizedBox(height: 16),
              Row(
                spacing: 10,
                children: [
                  Flexible(
                    child: TextFormField(
                      controller: _courtNoController,
                      decoration: const InputDecoration(labelText: 'Court No'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  Flexible(
                    child: DropdownButtonFormField<String>(
                      value: _status,
                      items: ['Pending', 'Not Filed', 'Disposed', 'Closed']
                          .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (val) => setState(() => _status = val!),
                      decoration: const InputDecoration(labelText: 'Status'),
                    ),
                  ),
                ],
              ),
              // const SizedBox(height: 16),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Next Hearing Date'),
                subtitle: Text(
                  '${_hearingDate.day}/${_hearingDate.month}/${_hearingDate.year}',
                  style: textTheme.bodyMedium,
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              ExpansionTile(
                title: Text('Parties',style:  Theme.of(context).textTheme.titleMedium),
                leading: Icon(Icons.people, color: Theme.of(context).colorScheme.primary,),
                tilePadding: EdgeInsets.zero,
                childrenPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                children: [
                  TextFormField(
                    controller: _petitionerController,
                    decoration: const InputDecoration(labelText: 'Petitioner'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _petitionerAdvController,
                    decoration:
                        const InputDecoration(labelText: 'Petitioner Advocate'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _respondentController,
                    decoration: const InputDecoration(labelText: 'Respondent'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _respondentAdvController,
                    decoration:
                        const InputDecoration(labelText: 'Respondent Advocate'),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                  title: Row(
                    spacing: 10,
                    children: [
                      Icon(Icons.attach_file,
                          color: Theme.of(context).colorScheme.primary),
                      Text('Attached Files:',
                          style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                  children: [
                    
                        const SizedBox(height: 8),
                        ..._attachedFiles.map((file) => ListTile(
                              title: Text(file.split('/').last),
                              trailing: IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  setState(() => _attachedFiles.remove(file));
                                },
                              ),
                            )),
                        ElevatedButton.icon(
                          onPressed: _pickFiles,
                          icon:  Icon(Icons.attach_file, color: Theme.of(context).colorScheme.inversePrimary,),
                          label: const Text('Attach Files'),
                        ),
                     
                    
                  ]),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveCase,
                  icon: const Icon(Icons.save),
                  label: Text(widget.existingCase == null
                      ? 'Save Case'
                      : 'Update Case'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
