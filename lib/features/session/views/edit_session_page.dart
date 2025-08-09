import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:new_ovacs/common/widgets/labeled_text_field.dart';
import 'package:new_ovacs/core/functions/show_snackbar.dart';
import 'package:new_ovacs/core/constants/app_colors.dart';
import '../../../data/models/session_model.dart';
import '../providers/session_details_provider.dart';
import '../providers/sessions_provider.dart';

class EditSessionPage extends StatefulWidget {
  final SessionModel sessionModel;
  final int caseId;

  const EditSessionPage({
    super.key,
    required this.sessionModel,
    required this.caseId,
  });

  @override
  State<EditSessionPage> createState() => _EditSessionPageState();
}

class _EditSessionPageState extends State<EditSessionPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _sessionNameC;
  late TextEditingController _sessionDescriptionC;
  late TextEditingController _dateC;
  late TextEditingController _timeC;

  @override
  void initState() {
    super.initState();
    _sessionNameC = TextEditingController(
      text: widget.sessionModel.title ?? '',
    );
    _sessionDescriptionC = TextEditingController(
      text: widget.sessionModel.description ?? '',
    );

    final date = widget.sessionModel.date;
    _dateC = TextEditingController(
      text: date != null ? DateFormat('yyyy-MM-dd').format(date) : '',
    );

    final time = widget.sessionModel.time;
    _timeC = TextEditingController(text: time ?? '');
  }

  @override
  void dispose() {
    _sessionNameC.dispose();
    _sessionDescriptionC.dispose();
    _dateC.dispose();
    _timeC.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    FocusScope.of(context).requestFocus(FocusNode());
    final initial = widget.sessionModel.date ?? DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      _dateC.text = DateFormat('yyyy-MM-dd').format(pickedDate);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    FocusScope.of(context).requestFocus(FocusNode());
    final initialTime = widget.sessionModel.time != null
        ? TimeOfDay(
            hour:
                int.tryParse(widget.sessionModel.time!.split(':')[0]) ??
                TimeOfDay.now().hour,
            minute:
                int.tryParse(widget.sessionModel.time!.split(':')[1]) ??
                TimeOfDay.now().minute,
          )
        : TimeOfDay.now();
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (pickedTime != null) {
      final now = DateTime.now();
      final fullDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      _timeC.text = DateFormat('HH:mm').format(fullDateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailProvider = context.watch<SessionDetailProvider>();
    final isLoading = detailProvider.status == SessionDetailStatus.loading;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Edit Session',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppColors.charcoalGrey.withValues(alpha: 0.04),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                color: Colors.transparent,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Session Name
                      LabeledTextField(
                        controller: _sessionNameC,
                        label: 'Session Name',

                        hint: 'Enter session name',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Session name is required';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      // Description
                      LabeledTextField(
                        controller: _sessionDescriptionC,
                        maxLines: 5,
                        label: 'Description',

                        hint: 'Enter the description of session...',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Description is required';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      // Date picker
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: LabeledTextField(
                          controller: _dateC,
                          label: 'Date',

                          hint: 'yyyy-MM-dd',
                          enabled: false,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Date is required';
                            }
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Time picker
                      GestureDetector(
                        onTap: () => _selectTime(context),
                        child: LabeledTextField(
                          controller: _timeC,
                          label: 'Time',

                          hint: 'HH:mm',
                          icon: Iconsax.timer,
                          enabled: false,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Time is required';
                            }
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Save Button
                      GestureDetector(
                        onTap: isLoading
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  final payload = {
                                    'case_id': widget.caseId,
                                    'title': _sessionNameC.text.trim(),
                                    'description': _sessionDescriptionC.text
                                        .trim(),
                                    'date': _dateC.text.trim().isNotEmpty
                                        ? (_timeC.text.trim().isNotEmpty
                                              ? '${_dateC.text.trim()}T${_timeC.text.trim()}:00Z'
                                              : _dateC.text.trim())
                                        : '',
                                  };

                                  final success = await detailProvider
                                      .updateSession(
                                        widget.sessionModel.id,
                                        payload,
                                      );

                                  if (success) {
                                    context
                                        .read<SessionsProvider>()
                                        .fetchSessions(widget.caseId);

                                    Navigator.of(context).pop(true);
                                    showAppSnackBar(
                                      context,
                                      'Session updated successfully',
                                      type: SnackBarType.success,
                                    );
                                  } else {
                                    showAppSnackBar(
                                      context,
                                      detailProvider.errorMessage,
                                    );
                                  }
                                }
                              },
                        child: Opacity(
                          opacity: isLoading ? 0.6 : 1,
                          child: Container(
                            width: 113,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Theme.of(context).primaryColor,
                                  AppColors.tealGreen,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : Text(
                                      'Save',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(color: AppColors.offWhite),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
