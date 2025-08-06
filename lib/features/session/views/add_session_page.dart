import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:new_ovacs/common/widgets/labeled_text_field.dart';
import 'package:new_ovacs/core/functions/show_snackbar.dart';
import 'package:new_ovacs/features/session/providers/sessions_provider.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';

import '../providers/add_session_provider.dart';

class AddSessionPage extends StatefulWidget {
  final int caseId;
  const AddSessionPage({super.key, required this.caseId});

  @override
  State<AddSessionPage> createState() => _AddSessionPageState();
}

class _AddSessionPageState extends State<AddSessionPage> {
  final GlobalKey<FormState> addSessionFormKey = GlobalKey<FormState>();
  final TextEditingController sessionNameC = TextEditingController();
  final TextEditingController sessionDescriptionC = TextEditingController();
  final TextEditingController dateC = TextEditingController();
  final TextEditingController timeC = TextEditingController();

  @override
  void dispose() {
    sessionNameC.dispose();
    sessionDescriptionC.dispose();
    dateC.dispose();
    timeC.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    FocusScope.of(context).requestFocus(FocusNode());
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      dateC.text = DateFormat('yyyy-MM-dd').format(pickedDate);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    FocusScope.of(context).requestFocus(FocusNode());
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      final now = DateTime.now();
      final DateTime fullDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      timeC.text = DateFormat('HH:mm').format(fullDateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Add New Session',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppColors.charcoalGrey.withValues(alpha:0.04),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                color: Colors.transparent,
                child: Form(
                  key: addSessionFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Session Name
                      LabeledTextField(
                        controller: sessionNameC,
                        label: 'Session Name',
                        labelColor: AppColors.charcoalGrey,
                        hint: 'Enter session name',

                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Session name is required';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      LabeledTextField(
                        controller: sessionDescriptionC,
                        maxLines: 5,

                        label: 'Description',
                        labelColor: AppColors.charcoalGrey,
                        hint: 'Enter the description of case...',

                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Description is required';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: LabeledTextField(
                          controller: dateC,
                          label: 'Date',
                          labelColor: AppColors.charcoalGrey,

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

                      GestureDetector(
                        onTap: () => _selectTime(context),
                        child: LabeledTextField(
                          controller: timeC,
                          label: 'Time',
                          labelColor: AppColors.charcoalGrey,
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

                      // Add Button
                      Consumer<AddSessionProvider>(
                        builder: (context, value, child) {
                          final isLoading =
                              value.status == AddSessionStatus.loading;

                          return GestureDetector(
                            onTap: isLoading
                                ? null
                                : () async {
                                    if (addSessionFormKey.currentState!
                                        .validate()) {
                                      final success = await value.addSession(
                                        caseId: widget.caseId,
                                        title: sessionNameC.text.trim(),
                                        description: sessionDescriptionC.text
                                            .trim(),
                                        date: dateC.text.trim(),
                                        time: timeC.text.trim(),
                                      );
                                      print(success);

                                      if (success) {
                                        context
                                            .read<SessionsProvider>()
                                            .fetchSessions(widget.caseId);

                                        Navigator.of(context).pop();
                                        showAppSnackBar(
                                          context,
                                          'Session created successfully',
                                          type: SnackBarType.success,
                                        );
                                        value.reset();
                                      } else if (!success) {
                                        showAppSnackBar(
                                          context,
                                          value.errorMessage,
                                        );
                                        value.reset();
                                      }
                                    }
                                  },
                            child: Opacity(
                              opacity: isLoading ? 0.6 : 1,
                              child: Container(
                                width: 113,
                                height: 44,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      AppColors.primaryBlue,
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
                                          'Add',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                color: AppColors.offWhite,
                                              ),
                                        ),
                                ),
                              ),
                            ),
                          );
                        },
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
