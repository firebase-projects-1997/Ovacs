import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:new_ovacs/common/widgets/labeled_text_field.dart';
import 'package:new_ovacs/core/functions/show_snackbar.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_images.dart';
import '../../../l10n/app_localizations.dart';
import '../../../main.dart';
import '../providers/auth_provider.dart';
import 'create_new_password_page.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({super.key});

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  late TextEditingController _emailController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _emailController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
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
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 30,
                  children: [
                    _buildHeaderText(),

                    _buildEmailForm(),

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
                              : Text(AppLocalizations.of(context)!.next),
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

  Widget _buildHeaderText() {
    return Column(
      children: [
        Text(
          AppLocalizations.of(context)!.forgetPasswordTitle,
          style: Theme.of(
            context,
          ).textTheme.displayLarge!.copyWith(color: AppColors.pureWhite),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          AppLocalizations.of(context)!.enterEmailOrPhoneForReset,
          style: Theme.of(
            context,
          ).textTheme.titleLarge!.copyWith(color: AppColors.pureWhite),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmailForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LabeledTextField(
            label: AppLocalizations.of(context)!.email,
            labelColor: AppColors.pureWhite,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            hint: AppLocalizations.of(context)!.enterYourEmail,
          ),
        ],
      ),
    );
  }

  _submit() async {
    final auth = context.read<AuthProvider>();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();
    final success = await auth.requestPasswordReset(email);

    if (!mounted) return;

    if (success) {
      showAppSnackBar(
        context,
        'Check your E-mail for confirmation code',
        type: SnackBarType.success,
      );

      navigatorKey.currentState!.push(
        MaterialPageRoute(builder: (_) => CreateNewPasswordPage(email: email)),
      );
    } else {
      showAppSnackBar(context, auth.error);
    }
  }
}
