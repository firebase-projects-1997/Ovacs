import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:new_ovacs/core/constants/app_colors.dart';
import 'package:new_ovacs/core/functions/is_dark_mode.dart';
import 'package:new_ovacs/main.dart';
import 'package:provider/provider.dart';
import 'package:new_ovacs/core/constants/app_images.dart';
import 'package:new_ovacs/features/auth/providers/auth_provider.dart';

import '../../../common/widgets/labeled_text_field.dart';
import '../../../common/widgets/rounded_container.dart';
import '../../../core/functions/show_snackbar.dart';
import '../../../l10n/app_localizations.dart';
import '../../dashboard/views/navigation_menu.dart';
import 'forget_password_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailC;
  late TextEditingController _passwordC;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _emailC = TextEditingController();
    _passwordC = TextEditingController();
  }

  @override
  void dispose() {
    _emailC.dispose();
    _passwordC.dispose();
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 20,
                    children: [
                      _buildHeaderText(context),

                      RoundedContainer(
                        backgroundColor: isDarkMode(context)
                            ? AppColors.black.withValues(alpha: .3)
                            : AppColors.pureWhite.withValues(alpha: .3),
                        blur: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          spacing: 10,
                          children: [
                            LabeledTextField(
                              label: AppLocalizations.of(context)!.email,
                              hint: AppLocalizations.of(
                                context,
                              )!.enterYourEmail,
                              controller: _emailC,
                              icon: Iconsax.direct,
                              labelColor: AppColors.pureWhite,
                            ),
                            SizedBox.shrink(),
                            LabeledTextField(
                              labelColor: AppColors.pureWhite,
                              label: AppLocalizations.of(context)!.password,
                              hint: AppLocalizations.of(
                                context,
                              )!.enterYourPassword,
                              controller: _passwordC,
                              isPassword: true,
                              obscureText: _isPasswordVisible,
                              toggleObscure: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                              icon: Iconsax.password_check,
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  navigatorKey.currentState!.push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ForgetPasswordPage(),
                                    ),
                                  );
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.forgetPassword,
                                  style: Theme.of(context).textTheme.bodySmall!
                                      .copyWith(color: AppColors.pureWhite),
                                ),
                              ),
                            ),

                            Consumer<AuthProvider>(
                              builder: (_, auth, __) => ElevatedButton(
                                onPressed: auth.isLoading ? null : _submit,
                                child: auth.isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: AppColors.pureWhite,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        AppLocalizations.of(context)!.signIn,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                              color: AppColors.pureWhite,
                                            ),
                                      ),
                              ),
                            ),

                            _buildRegisterText(context),
                          ],
                        ),
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

  Widget _buildHeaderText(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 15,
      children: [
        Text(
          AppLocalizations.of(context)!.welcomeBack,
          style: Theme.of(
            context,
          ).textTheme.displayLarge!.copyWith(color: AppColors.pureWhite),
          textAlign: TextAlign.center,
        ),
        Text(
          AppLocalizations.of(context)!.enterYourLogId,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall!.copyWith(color: AppColors.pureWhite),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRegisterText(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: AppLocalizations.of(context)!.dontHaveAnAccount,
        style: Theme.of(
          context,
        ).textTheme.bodySmall!.copyWith(color: AppColors.pureWhite),
        children: [
          TextSpan(
            text: AppLocalizations.of(context)!.register,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge!.copyWith(color: AppColors.pureWhite),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                navigatorKey.currentState!.push(
                  MaterialPageRoute(
                    builder: (context) => const RegisterPage(),
                  ),
                );
              },
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  _submit() async {
    final auth = context.read<AuthProvider>();
    if (_formKey.currentState!.validate()) {
      final success = await auth.login(
        email: _emailC.text.trim(),
        password: _passwordC.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        showAppSnackBar(
          context,
          AppLocalizations.of(context)!.welcomeBackMessage,
          type: SnackBarType.success,
        );
        navigatorKey.currentState!.pushReplacement(
          MaterialPageRoute(builder: (context) => const NavigationMenu()),
        );
      } else if (auth.error != null) {
        showAppSnackBar(context, auth.error);
      }
    }
  }
}
