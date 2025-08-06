import 'dart:ui'; // For ImageFilter

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:new_ovacs/core/functions/show_snackbar.dart';
import 'package:new_ovacs/features/client/providers/clients_provider.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../common/providers/country_provider.dart';
import '../../../common/widgets/rounded_container.dart';
import '../../../data/models/country_model.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/add_client_provider.dart'; // تأكد من المسار الصحيح لـ AddClientProvider

import '../../../common/widgets/labeled_text_field.dart'; // مسار ملف LabeledTextField

class AddNewClientPage extends StatefulWidget {
  const AddNewClientPage({super.key});

  @override
  State<AddNewClientPage> createState() => _AddNewClientPageState();
}

class _AddNewClientPageState extends State<AddNewClientPage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _mobileController;
  late TextEditingController _countryNameController;

  CountryModel? _selectedCountry;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CountryProvider>().fetchCountries();
    });
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _mobileController = TextEditingController();
    _countryNameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _countryNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(AppLocalizations.of(context)!.addNewClient),
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(color: Colors.transparent),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: RoundedContainer(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.addNewClient,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),

                      LabeledTextField(
                        filled: true,
                        fillColor: AppColors.mediumGrey.withValues(alpha: .1),

                        label: AppLocalizations.of(context)!.clientName,
                        hint: AppLocalizations.of(context)!.enterClientName,
                        controller: _nameController,
                        keyboardType: TextInputType.name,
                      ),

                      const SizedBox(height: 12),

                      _PhoneInputRow(
                        mobileController: _mobileController,
                        countryNameController: _countryNameController,
                        selectedCountry: _selectedCountry,
                        onCountryChanged: (CountryModel? newCountry) {
                          setState(() {
                            _selectedCountry = newCountry;
                            if (newCountry != null) {
                              _countryNameController.text =
                                  newCountry.name ?? '';
                            } else {
                              _countryNameController.clear();
                            }
                          });
                        },
                      ),

                      const SizedBox(height: 12),

                      LabeledTextField(
                        filled: true,
                        fillColor: AppColors.mediumGrey.withValues(alpha: .1),
                        label: AppLocalizations.of(context)!.country,
                        hint: AppLocalizations.of(
                          context,
                        )!.countryWillAppearHere,
                        controller: _countryNameController,
                        enabled: false,
                      ),

                      const SizedBox(height: 12),

                      LabeledTextField(
                        filled: true,
                        fillColor: AppColors.mediumGrey.withValues(alpha: .1),

                        label: AppLocalizations.of(context)!.email,
                        hint: AppLocalizations.of(context)!.enterYourEmail,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),

                      const SizedBox(height: 24),

                      _AddClientButtons(
                        formKey: _formKey,
                        nameController: _nameController,
                        emailController: _emailController,
                        mobileController: _mobileController,
                        selectedCountry: _selectedCountry,
                        onSaveSuccess: () {
                          context.read<ClientsProvider>().fetchClients();
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhoneInputRow extends StatelessWidget {
  const _PhoneInputRow({
    required this.mobileController,
    required this.countryNameController,
    required this.selectedCountry,
    required this.onCountryChanged,
  });

  final TextEditingController mobileController;
  final TextEditingController countryNameController;
  final CountryModel? selectedCountry;
  final ValueChanged<CountryModel?> onCountryChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppLocalizations.of(context)!.phone,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Consumer<CountryProvider>(
                builder: (context, countryProvider, _) {
                  if (countryProvider.isLoading) {
                    return const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  } else if (countryProvider.error != null) {
                    return Text(
                      'Error loading countries: ${countryProvider.error}',
                    );
                  } else {
                    final countries = countryProvider.countries;
                    return DropdownButtonFormField<CountryModel>(
                      isExpanded: true,
                      decoration: InputDecoration(
                        fillColor: AppColors.mediumGrey.withValues(alpha: .1),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                      ),
                      value: selectedCountry,
                      hint: Text(AppLocalizations.of(context)!.code),
                      items: countries
                          .map(
                            (country) => DropdownMenuItem(
                              value: country,
                              child: Text(country.phoneCode ?? ''),
                            ),
                          )
                          .toList(),
                      onChanged: (newValue) {
                        onCountryChanged(newValue);
                      },
                    );
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 5,
              child: LabeledTextField(
                filled: true,
                fillColor: AppColors.mediumGrey.withValues(alpha: .1),

                label: '',
                hint: '8023456789',
                controller: mobileController,
                keyboardType: TextInputType.phone,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AddClientButtons extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController mobileController;
  final CountryModel? selectedCountry;
  final VoidCallback onSaveSuccess;

  const _AddClientButtons({
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.mobileController,
    required this.selectedCountry,
    required this.onSaveSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AddClientProvider>(
      builder: (context, addClientProvider, _) {
        final isLoading = addClientProvider.status == AddClientStatus.loading;

        if (addClientProvider.status == AddClientStatus.success) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            addClientProvider.resetStatus();
            context.read<ClientsProvider>().fetchClients();
            onSaveSuccess();
            showAppSnackBar(
              context,
              AppLocalizations.of(context)!.clientAddedSuccessfully,
              type: SnackBarType.success,
            );
          });
        } else if (addClientProvider.status == AddClientStatus.error) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final msg =
                addClientProvider.errorMessage ??
                AppLocalizations.of(context)!.unknownError;
            showAppSnackBar(context, msg);
            addClientProvider.resetStatus();
          });
        }

        return SizedBox(
          height: 44,
          child: ElevatedButton(
            onPressed: isLoading
                ? null
                : () {
                    if (formKey.currentState!.validate()) {
                      if (selectedCountry == null) {
                        showAppSnackBar(
                          context,
                          AppLocalizations.of(
                            context,
                          )!.pleaseSelectACountryCode,
                          type: SnackBarType.warning,
                        );
                        return;
                      }
                      addClientProvider.addClient(
                        name: nameController.text.trim(),
                        email: emailController.text.trim(),
                        mobile: mobileController.text.trim(),
                        countryId: selectedCountry!.id,
                      );
                    }
                  },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(AppLocalizations.of(context)!.save),
          ),
        );
      },
    );
  }
}
