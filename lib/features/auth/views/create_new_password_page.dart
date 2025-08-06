import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:new_ovacs/common/widgets/labeled_text_field.dart';
import 'package:new_ovacs/core/functions/show_snackbar.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../main.dart';
import '../providers/auth_provider.dart';

class CreateNewPasswordPage extends StatefulWidget {
  final String email;
  const CreateNewPasswordPage({super.key, required this.email});

  @override
  State<CreateNewPasswordPage> createState() => _CreateNewPasswordPageState();
}

class _CreateNewPasswordPageState extends State<CreateNewPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  late TextEditingController _pinController;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _pinController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(AppImages.authBackground, fit: BoxFit.cover),
          ),
          SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 30,
                  children: [
                    _buildHeader(),

                    _buildOtpInputField(),

                    _buildPasswordForm(),

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
                              : Text(
                                  'Done',
                                  style: Theme.of(context).textTheme.bodyMedium!
                                      .copyWith(color: AppColors.pureWhite),
                                ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(
                        Iconsax.close_circle,
                        color: AppColors.pureWhite,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          AppLocalizations.of(context)!.createNewPassword,
          style: Theme.of(
            context,
          ).textTheme.displayLarge!.copyWith(color: AppColors.pureWhite),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          AppLocalizations.of(
            context,
          )!.setYourNewPasswordSoYouCanLoginAndAccessOvacs,
          style: Theme.of(
            context,
          ).textTheme.titleLarge!.copyWith(color: AppColors.pureWhite),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildOtpInputField() {
    return Pinput(
      controller: _pinController,
      length: 6,
      keyboardType: TextInputType.number,
      validator: (s) {
        return s != null && s.length == 6
            ? null
            : AppLocalizations.of(context)!.pinIsRequired;
      },
      defaultPinTheme: PinTheme(
        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColors.pureWhite.withValues(alpha: .3),
        ),
      ),
      focusedPinTheme: PinTheme(
        textStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.pureWhite,
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColors.pureWhite.withValues(alpha: .5),
          border: Border.all(color: AppColors.pureWhite, width: 2),
        ),
      ),
    );
  }

  Widget _buildPasswordForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          LabeledTextField(
            label: AppLocalizations.of(context)!.password,
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            toggleObscure: () {
              setState(() => _isPasswordVisible = !_isPasswordVisible);
            },
            hint: AppLocalizations.of(context)!.enterYourPassword,
          ),
          const SizedBox(height: 16),
          LabeledTextField(
            label: AppLocalizations.of(context)!.confirmPassword,
            labelColor: AppColors.pureWhite,
            controller: _confirmPasswordController,
            obscureText: !_isConfirmPasswordVisible,
            toggleObscure: () {
              setState(() {
                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
              });
            },

            validator: (value) {
              if (value != _passwordController.text) {
                return AppLocalizations.of(context)!.passwordsDoNotMatch;
              }
              return null;
            },
            hint: AppLocalizations.of(context)!.enterYourPasswordAgain,
          ),
        ],
      ),
    );
  }

  _submit() async {
    final auth = context.watch<AuthProvider>();
    if (!_formKey.currentState!.validate()) return;

    if (_pinController.text.length != 6) {
      showAppSnackBar(
        context,
        AppLocalizations.of(context)!.pinIsRequired,
        type: SnackBarType.warning,
      );
      return;
    }

    final success = await auth.confirmPasswordReset(
      email: widget.email,
      token: _pinController.text.trim(),
      newPassword: _passwordController.text.trim(),
    );

    if (success) {
      showAppSnackBar(
        context,
        AppLocalizations.of(context)!.passwordChangedSuccessfully,
        type: SnackBarType.success,
      );

      navigatorKey.currentState!.pushNamedAndRemoveUntil(
        AppRoutes.loginRoute,
        (_) => false,
      );
    } else {
      showAppSnackBar(context, auth.error);
    }
  }
}
