import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:new_ovacs/features/document/providers/documents_provider.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/upload_documents_provider.dart';

class UploadDocumentsPage extends StatefulWidget {
  final int id;
  final int? groupId;
  final String? groupName;
  final String? groupDescription;

  const UploadDocumentsPage({
    super.key,
    required this.id,
    this.groupId,
    this.groupName,
    this.groupDescription,
  });

  @override
  State<UploadDocumentsPage> createState() => _UploadDocumentsPageState();
}

class _UploadDocumentsPageState extends State<UploadDocumentsPage> {
  late TextEditingController _groupNameController;
  late TextEditingController _groupDescriptionController;

  bool _storeAsGroup = false;
  final List<String> _selectedFilePaths = [];

  String? _selectedSecurityLevel;

  @override
  void initState() {
    super.initState();
    _groupNameController = TextEditingController(text: widget.groupName ?? '');
    _groupDescriptionController = TextEditingController(
      text: widget.groupDescription ?? '',
    );
    _storeAsGroup = widget.groupId != null || widget.groupName != null;
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    _groupDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );

    if (result != null) {
      final newFilePaths = result.files.map((file) => file.path!).toList();
      setState(() {
        for (var path in newFilePaths) {
          if (!_selectedFilePaths.contains(path)) {
            _selectedFilePaths.add(path);
          }
        }
      });
    }
  }

  void _removeFile(String path) {
    setState(() {
      _selectedFilePaths.remove(path);
    });
  }

  void _uploadFiles(BuildContext context) {
    final provider = context.read<UploadDocumentsProvider>();

    if (_selectedFilePaths.isEmpty) {
      _showSnackBar(AppLocalizations.of(context)!.pleaseSelectFilesToUpload);
      return;
    }
    if (_selectedSecurityLevel == null) {
      _showSnackBar(AppLocalizations.of(context)!.pleaseSelectSecurityLevel);
      return;
    }
    if (_storeAsGroup && _groupNameController.text.trim().isEmpty) {
      _showSnackBar(AppLocalizations.of(context)!.pleaseEnterGroupName);
      return;
    }

    provider.uploadDocuments(
      filePaths: _selectedFilePaths,
      securityLevel: _selectedSecurityLevel!,
      sessionId: widget.id,
      storeAsGroup: widget.groupId != null ? true : _storeAsGroup,
      groupId: widget.groupId,
      groupName: widget.groupId == null && _storeAsGroup
          ? _groupNameController.text
          : null,
      groupDescription: widget.groupId == null && _storeAsGroup
          ? _groupDescriptionController.text
          : null,
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _resetState() {
    setState(() {
      _selectedFilePaths.clear();
      _selectedSecurityLevel = null;
      _groupNameController.clear();
      _groupDescriptionController.clear();
      _storeAsGroup = false;
    });
    context.read<UploadDocumentsProvider>().reset();
  }

  @override
  Widget build(BuildContext context) {
    final uploadProvider = context.watch<UploadDocumentsProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (uploadProvider.status == UploadDocumentsStatus.success) {
        Navigator.of(context).pop();
        _showSnackBar(
          AppLocalizations.of(
            context,
          )!.uploadSuccessMessage(uploadProvider.uploadedDocuments.length),
        );
        _resetState();
        context.read<DocumentsProvider>().fetchDocumentsBySession(
          extraParams: widget.groupId != null
              ? {'session_id': widget.id, 'group': widget.groupId}
              : {'session_id': widget.id},
        );
      } else if (uploadProvider.status == UploadDocumentsStatus.failure) {
        _showSnackBar(
          '${AppLocalizations.of(context)!.uploadFailed}: ${uploadProvider.errorMessage}',
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.uploadDocuments),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedSecurityLevel,
              items: ['red', 'yellow', 'green']
                  .map(
                    (level) => DropdownMenuItem(
                      value: level,
                      child: Text(level[0].toUpperCase() + level.substring(1)),
                    ),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => _selectedSecurityLevel = value),
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.securityLevel,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                if (widget.groupId == null)
                  Row(
                    children: [
                      Checkbox(
                        value: _storeAsGroup,
                        onChanged: (value) =>
                            setState(() => _storeAsGroup = value ?? false),
                      ),
                      Text(AppLocalizations.of(context)!.storeAsGroup),
                    ],
                  )
                else
                  Row(
                    spacing: 10,
                    children: [
                      Text(AppLocalizations.of(context)!.storeAsGroup),
                      Text('{${widget.groupName}}'),
                    ],
                  ),
              ],
            ),
            if (widget.groupId == null && _storeAsGroup) ...[
              const SizedBox(height: 15),
              TextField(
                controller: _groupNameController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.groupName,
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _groupDescriptionController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.groupDescription,
                ),
              ),
            ],

            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: _pickFiles,
              child: Text(AppLocalizations.of(context)!.selectFiles),
            ),
            const SizedBox(height: 15),
            Text(
              '${AppLocalizations.of(context)!.selectFiles}: ${_selectedFilePaths.isEmpty ? AppLocalizations.of(context)!.none : _selectedFilePaths.length}',
            ),
            ..._selectedFilePaths.map(
              (path) => Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primaryBlue),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        path.split('/').last,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Iconsax.trash, color: Colors.red),
                      onPressed: () => _removeFile(path),
                      tooltip: AppLocalizations.of(context)!.removeFile,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (uploadProvider.status == UploadDocumentsStatus.loading)
              Column(
                children: [
                  const LinearProgressIndicator(),
                  const SizedBox(height: 10),
                  Text(AppLocalizations.of(context)!.uploading),
                ],
              )
            else
              ElevatedButton(
                onPressed: () => _uploadFiles(context),
                child: Text(AppLocalizations.of(context)!.uploadDocuments),
              ),
          ],
        ),
      ),
    );
  }
}
