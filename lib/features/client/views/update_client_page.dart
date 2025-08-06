import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:new_ovacs/core/functions/show_snackbar.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../common/providers/country_provider.dart';
import '../../../data/models/client_model.dart';
import '../../../data/models/country_model.dart';
import '../providers/clients_provider.dart';
import '../providers/update_client_provider.dart';
import '../../../common/widgets/labeled_text_field.dart';

class EditClientPage extends StatefulWidget {
  final ClientModel client;
  const EditClientPage({super.key, required this.client});

  @override
  State<EditClientPage> createState() => _EditClientPageState();
}

class _EditClientPageState extends State<EditClientPage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _mobileController;
  late TextEditingController _countryNameController;
  CountryModel? _selectedCountry;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.client.name);
    _emailController = TextEditingController(text: widget.client.email);
    _mobileController = TextEditingController(text: widget.client.mobile);
    _countryNameController = TextEditingController(
      text: widget.client.country.name ?? '',
    );
    _selectedCountry = widget.client.country;

    // Fetch countries after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CountryProvider>().fetchCountries();
    });
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
        title: const Text('Edit Client'),
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: Colors.transparent),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).primaryColor),
                ),
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Edit Client',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),

                      LabeledTextField(
                        filled: true,
                        fillColor: AppColors.mediumGrey.withValues(alpha: 0.1),
                        labelColor: AppColors.charcoalGrey,
                        label: 'Client Name',
                        hint: 'Enter client name',
                        controller: _nameController,
                        keyboardType: TextInputType.name,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Client name is required'
                            : null,
                      ),

                      const SizedBox(height: 12),

                      _PhoneInputRow(
                        mobileController: _mobileController,
                        countryNameController: _countryNameController,
                        selectedCountry: _selectedCountry,
                        onCountryChanged: (newCountry) {
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
                        fillColor: AppColors.mediumGrey.withValues(alpha: 0.1),
                        labelColor: AppColors.charcoalGrey,
                        label: 'Country',
                        hint: 'Country will appear here',
                        controller: _countryNameController,
                        enabled: false,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Country is required'
                            : null,
                      ),

                      const SizedBox(height: 12),

                      LabeledTextField(
                        filled: true,
                        fillColor: AppColors.mediumGrey.withValues(alpha: 0.1),
                        labelColor: AppColors.charcoalGrey,
                        label: 'Email',
                        hint: 'Enter your email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Email is required'
                            : null,
                      ),

                      const SizedBox(height: 24),

                      Consumer<UpdateClientProvider>(
                        builder: (context, provider, _) {
                          final isLoading =
                              provider.status == UpdateClientStatus.loading;

                          if (provider.status == UpdateClientStatus.success) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              context.read<ClientsProvider>().fetchClients();
                              Navigator.of(context).pop(true);
                              showAppSnackBar(
                                context,
                                'Client updated successfully!',
                                type: SnackBarType.success,
                              );
                            });
                          } else if (provider.status ==
                              UpdateClientStatus.error) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              final msg =
                                  provider.errorMessage ?? 'Unknown error';
                              showAppSnackBar(context, msg);
                            });
                          }

                          return SizedBox(
                            height: 44,
                            child: ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                      if (!_formKey.currentState!.validate()) {
                                        return;
                                      }
                                      if (_selectedCountry == null) {
                                        showAppSnackBar(
                                          context,
                                          'Please select a country.',
                                          type: SnackBarType.warning,
                                        );
                                        return;
                                      }
                                      await provider.updateClient(
                                        id: widget.client.id,
                                        name: _nameController.text.trim(),
                                        email: _emailController.text.trim(),
                                        mobile: _mobileController.text.trim(),
                                        countryId: _selectedCountry!.id,
                                      );
                                    },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                backgroundColor: Theme.of(context).primaryColor,
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
                                  : const Text('Save Changes'),
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
    final countryProvider = context.watch<CountryProvider>();
    final OutlineInputBorder border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide:  BorderSide(color: Theme.of(context).primaryColor),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Phone',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium!.copyWith(color: AppColors.charcoalGrey),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: countryProvider.isLoading
                  ? const SizedBox(
                      height: 44,
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : DropdownButtonFormField<CountryModel>(
                      isExpanded: true,
                      decoration: InputDecoration(
                        border: border,
                        enabledBorder: border,
                        focusedBorder: border,
                        contentPadding: const EdgeInsets.only(left: 12),
                      ),
                      value: selectedCountry,
                      hint: Text(
                        'Code',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: AppColors.mediumGrey,
                        ),
                      ),
                      items: countryProvider.countries
                          .map(
                            (country) => DropdownMenuItem(
                              value: country,
                              child: Text(
                                country.phoneCode ?? '',
                                style: Theme.of(context).textTheme.bodyMedium!
                                    .copyWith(color: AppColors.charcoalGrey),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: onCountryChanged,
                      validator: (value) =>
                          value == null ? 'Code is required' : null,
                    ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 5,
              child: TextFormField(
                controller: mobileController,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Phone is required'
                    : null,
                decoration: InputDecoration(
                  hintText: '8023456789',
                  border: border,
                  enabledBorder: border,
                  focusedBorder: border,
                ),
                keyboardType: TextInputType.phone,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.black,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
