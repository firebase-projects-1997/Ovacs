import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:new_ovacs/common/providers/country_provider.dart';
import 'package:new_ovacs/core/constants/app_sizes.dart';
import 'package:new_ovacs/core/functions/show_snackbar.dart';
import 'package:new_ovacs/features/auth/views/otp_verification_page.dart';
import 'package:new_ovacs/main.dart';
import 'package:provider/provider.dart';

import '../../../common/widgets/labeled_text_field.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/functions/url_luncher.dart';
import '../../../data/models/country_model.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Controllers
  late TextEditingController _usernameC;
  late TextEditingController _companyNameC;
  late TextEditingController _emailC;
  late TextEditingController _passwordC;
  late TextEditingController _confirmPasswordC;
  late TextEditingController _mobileController;
  late TextEditingController _countryNameController;
  late TextEditingController _phoneCodeController;

  CountryModel? selectedCountry;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreedToTerms = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _usernameC = TextEditingController();
    _companyNameC = TextEditingController();
    _emailC = TextEditingController();
    _passwordC = TextEditingController();
    _confirmPasswordC = TextEditingController();
    _mobileController = TextEditingController();
    _countryNameController = TextEditingController();
    _phoneCodeController = TextEditingController();
    final provider = Provider.of<CountryProvider>(context, listen: false);
    Future.microtask(() {
      provider.fetchCountries();
    });
  }

  @override
  void dispose() {
    _usernameC.dispose();
    _companyNameC.dispose();
    _emailC.dispose();
    _passwordC.dispose();
    _confirmPasswordC.dispose();
    _mobileController.dispose();
    _countryNameController.dispose();
    _phoneCodeController.dispose();
    super.dispose();
  }

  void _submit() async {
    final auth = context.read<AuthProvider>();

    if (!_formKey.currentState!.validate()) return;

    if (!_agreedToTerms) {
      showAppSnackBar(
        context,
        AppLocalizations.of(context)!.pleaseAgreeToTerms,
        type: SnackBarType.warning,
      );
      return;
    }

    if (selectedCountry == null) {
      showAppSnackBar(
        context,
        AppLocalizations.of(context)!.pleaseSelectACountryCode,
        type: SnackBarType.warning,
      );
      return;
    }

    final success = await auth.register(
      name: _usernameC.text.trim(),
      email: _emailC.text.trim(),
      mobile: _mobileController.text.trim(),
      password: _passwordC.text.trim(),
      countryId: selectedCountry!.id,
    );

    if (success) {
      showAppSnackBar(
        context,
        AppLocalizations.of(context)!.checkYourEmailForConfirmation,
        type: SnackBarType.success,
      );
      navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (context) => OtpVerificationPage(email: _emailC.text.trim()),
        ),
      );
    } else {
      showAppSnackBar(
        context,
        auth.error ?? AppLocalizations.of(context)!.unknownError,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/auth_background.png',
              fit: BoxFit.cover,
            ),
          ),
          SingleChildScrollView(
            padding: AppSizes.defaultPadding(context),
            child: Form(
              key: _formKey,
              child: Column(
                spacing: 12,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    AppLocalizations.of(context)!.register,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: AppColors.pureWhite,
                    ),
                  ),

                  // User name
                  LabeledTextField(
                    labelColor: AppColors.pureWhite,
                    label: AppLocalizations.of(context)!.userName,
                    hint: AppLocalizations.of(context)!.enterYourName,
                    controller: _usernameC,
                    icon: Iconsax.personalcard,
                  ),

                  // Company name
                  LabeledTextField(
                    labelColor: AppColors.pureWhite,
                    label: AppLocalizations.of(context)!.companyName,
                    hint: AppLocalizations.of(context)!.enterYourCompanyName,
                    controller: _companyNameC,
                    icon: Iconsax.card_send,
                  ),

                  Text(
                    AppLocalizations.of(context)!.phone,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: AppColors.pureWhite,
                    ),
                  ),

                  Row(
                    spacing: 12,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Consumer<CountryProvider>(
                          builder: (context, value, child) {
                            return !value.isLoading
                                ? DropdownButtonFormField<CountryModel>(
                                    isExpanded: true,
                                    value: selectedCountry,
                                    hint: Text(
                                      '+',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall!,
                                    ),
                                    items: value.countries
                                        .map(
                                          (c) => DropdownMenuItem(
                                            value: c,
                                            child: Text(
                                              c.phoneCode ?? '',
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodySmall!,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() {
                                          selectedCountry = value;
                                          _phoneCodeController.text =
                                              value.phoneCode ?? '';
                                          _countryNameController.text =
                                              value.name!;
                                        });
                                      }
                                    },
                                    validator: (value) {
                                      if (value == null) {
                                        return AppLocalizations.of(
                                          context,
                                        )!.pleaseSelectACountryCode;
                                      }
                                      return null;
                                    },
                                  )
                                : const Center(
                                    child: CircularProgressIndicator(),
                                  );
                          },
                        ),
                      ),

                      Expanded(
                        flex: 5,
                        child: LabeledTextField(
                          labelColor: AppColors.pureWhite,
                          label: '',
                          hint: '8023456789',
                          controller: _mobileController,
                          keyboardType: TextInputType.phone,

                          icon: Iconsax.mobile,
                        ),
                      ),
                    ],
                  ),

                  // Country (readonly)
                  LabeledTextField(
                    labelColor: AppColors.pureWhite,
                    label: AppLocalizations.of(context)!.country,
                    hint: AppLocalizations.of(context)!.countryWillAppearHere,
                    controller: _countryNameController,
                    enabled: false,
                    icon: Iconsax.global,
                  ),

                  // Email
                  LabeledTextField(
                    labelColor: AppColors.pureWhite,
                    label: AppLocalizations.of(context)!.email,
                    hint: AppLocalizations.of(context)!.enterYourEmail,
                    controller: _emailC,
                    keyboardType: TextInputType.emailAddress,

                    icon: Iconsax.direct,
                  ),

                  // Password
                  LabeledTextField(
                    labelColor: AppColors.pureWhite,
                    label: AppLocalizations.of(context)!.password,
                    hint: AppLocalizations.of(context)!.enterYourPassword,
                    controller: _passwordC,
                    isPassword: true,
                    obscureText: !_isPasswordVisible,
                    toggleObscure: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },

                    icon: Iconsax.password_check,
                  ),

                  // Confirm password
                  LabeledTextField(
                    labelColor: AppColors.pureWhite,
                    label: AppLocalizations.of(context)!.confirmPassword,
                    hint: AppLocalizations.of(context)!.enterYourPasswordAgain,
                    controller: _confirmPasswordC,
                    isPassword: true,
                    obscureText: !_isConfirmPasswordVisible,
                    toggleObscure: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                    validator: (value) {
                      if (value != _passwordC.text) {
                        return AppLocalizations.of(
                          context,
                        )!.passwordsDoNotMatch;
                      }
                      return null;
                    },
                    icon: Iconsax.password_check,
                  ),

                  // Terms and privacy checkbox
                  Row(
                    children: [
                      Checkbox(
                        value: _agreedToTerms,
                        onChanged: (value) {
                          setState(() {
                            _agreedToTerms = value ?? false;
                          });
                        },
                        activeColor: Theme.of(context).primaryColor,
                      ),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            text: AppLocalizations.of(
                              context,
                            )!.iHaveReadAndAgreeTo,
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(color: AppColors.pureWhite),
                            children: [
                              TextSpan(
                                text: AppLocalizations.of(
                                  context,
                                )!.termsOfService,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.pureWhite,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    launchGivenUrl(
                                      context,
                                      'https://your-terms-of-service-url.com',
                                    );
                                  },
                              ),
                              TextSpan(text: AppLocalizations.of(context)!.and),
                              TextSpan(
                                text: AppLocalizations.of(
                                  context,
                                )!.privacyPolicy,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.pureWhite,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    launchGivenUrl(
                                      context,
                                      'https://your-privacy-policy-url.com',
                                    );
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Register button
                  Consumer<AuthProvider>(
                    builder: (_, auth, __) {
                      return ElevatedButton(
                        onPressed: auth.isLoading ? null : _submit,
                        child: auth.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(AppLocalizations.of(context)!.register),
                      );
                    },
                  ),

                  // Sign in prompt
                  Text.rich(
                    TextSpan(
                      text: AppLocalizations.of(context)!.alreadyHaveAnAccount,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: AppColors.pureWhite,
                      ),
                      children: [
                        TextSpan(
                          text: AppLocalizations.of(context)!.signIn,
                          style: Theme.of(context).textTheme.bodyLarge!
                              .copyWith(color: AppColors.pureWhite),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              navigatorKey.currentState!.pushNamed(
                                AppRoutes.loginRoute,
                              );
                            },
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
