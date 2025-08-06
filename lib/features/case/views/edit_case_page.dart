import 'package:flutter/material.dart';
import 'package:new_ovacs/core/functions/show_snackbar.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../data/models/case_model.dart';
import '../../../data/models/client_model.dart';
import '../../client/providers/clients_provider.dart';
import '../../case/provider/case_details_provider.dart';
import '../../../common/widgets/labeled_text_field.dart';
import '../provider/cases_provider.dart';
import '../../../l10n/app_localizations.dart';

class EditCasePage extends StatefulWidget {
  final CaseModel caseModel;
  const EditCasePage({super.key, required this.caseModel});

  @override
  State<EditCasePage> createState() => _EditCasePageState();
}

class _EditCasePageState extends State<EditCasePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _dateController;

  ClientModel? _selectedClient;

  DateTime? _selectedDate;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.caseModel.title);
    _descriptionController = TextEditingController(
      text: widget.caseModel.description,
    );

    _selectedDate = widget.caseModel.date;
    _dateController = TextEditingController(
      text: _selectedDate != null
          ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
          : '',
    );

    Future.microtask(() {
      context.read<ClientsProvider>().fetchClients();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initialDate = _selectedDate ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 10),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() ||
        _selectedClient == null ||
        _selectedDate == null) {
      showAppSnackBar(
        context,
        AppLocalizations.of(context)!.pleaseFillAllRequiredFields,
        type: SnackBarType.warning,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final payload = {
      'client_id_input': _selectedClient!.id,
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'date': DateFormat('yyyy-MM-dd').format(_selectedDate!),
    };

    final provider = context.read<CaseDetailProvider>();
    final success = await provider.updateCase(widget.caseModel.id, payload);

    setState(() {
      _isLoading = false;
    });

    if (success) {
      context.read<CaseDetailProvider>().fetchCaseDetail(widget.caseModel.id);
      context.read<CasesProvider>().fetchCases();
      Navigator.of(context).pop(true);
    } else {
      showAppSnackBar(
        context,
        provider.errorMessage ??
            AppLocalizations.of(context)!.failedToUpdateCase,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientsProvider = Provider.of<ClientsProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.editCase)),
      body: clientsProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // حقل عنوان الحالة
                    LabeledTextField(
                      label: AppLocalizations.of(context)!.caseTitle,
                      hint: AppLocalizations.of(context)!.enterCaseTitle,
                      controller: _titleController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppLocalizations.of(context)!.titleIsRequired;
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // حقل الوصف
                    LabeledTextField(
                      label: AppLocalizations.of(context)!.description,
                      hint: AppLocalizations.of(context)!.enterCaseDescription,
                      controller: _descriptionController,
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppLocalizations.of(
                            context,
                          )!.descriptionIsRequired;
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    _buildClientSelectionField(clientsProvider),

                    const SizedBox(height: 16),

                    // اختيار التاريخ
                    GestureDetector(
                      onTap: _pickDate,
                      child: LabeledTextField(
                        label: AppLocalizations.of(context)!.appearInCourtOn,
                        hint: AppLocalizations.of(context)!.selectDate,
                        controller: _dateController,

                        onChanged: null,
                        onFieldSubmitted: null,
                        maxLines: 1,
                        enabled: false,
                        keyboardType: TextInputType.datetime,

                        // عند الضغط على الحقل يظهر picker
                      ),
                    ),

                    const SizedBox(height: 24),

                    // زر الحفظ
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(AppLocalizations.of(context)!.saveChanges),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildClientSelectionField(ClientsProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (provider.errorMessage != null) {
      return Text(
        '${AppLocalizations.of(context)!.errorLoadingClients} ${provider.errorMessage}',
      );
    } else {
      _selectedClient = provider.clients.firstWhere(
        (client) => client.id == widget.caseModel.clientId,
      );
      return DropdownButtonFormField<ClientModel>(
        value: _selectedClient,

        decoration: InputDecoration(
          labelText: AppLocalizations.of(context)!.chooseYourClient,
        ),
        items: provider.clients.map((client) {
          return DropdownMenuItem(value: client, child: Text(client.name));
        }).toList(),
        onChanged: (val) => setState(() => _selectedClient = val),
      );
    }
  }
}
