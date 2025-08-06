import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:new_ovacs/core/functions/show_snackbar.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/constants/app_routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../main.dart';
import '../providers/auth_provider.dart';

class OtpVerificationPage extends StatefulWidget {
  final String email;
  const OtpVerificationPage({super.key, required this.email});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  late TextEditingController _pinController;
  Timer? _timer;
  int _resendSeconds = 120;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _pinController = TextEditingController();
    _startResendTimer();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _resendSeconds = 120;
      _canResend = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds > 0) {
        setState(() => _resendSeconds--);
      } else {
        setState(() => _canResend = true);
        timer.cancel();
      }
    });

    final provider = context.read<AuthProvider>();
    provider.resendConfirmationCode(widget.email).then((success) {
      if (!success && mounted) {
        showAppSnackBar(context, provider.error);
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remaining = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remaining';
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
                  children: [
                    _buildHeaderText(),
                    const SizedBox(height: 30),
                    _buildOtpInputField(),
                    const SizedBox(height: 30),
                    _buildResendCodeSection(),
                    const SizedBox(height: 15),
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
                              : Text(AppLocalizations.of(context)!.verify),
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
          AppLocalizations.of(context)!.otpVerification,
          style: Theme.of(
            context,
          ).textTheme.titleLarge!.copyWith(color: AppColors.pureWhite),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 15),
        Text(
          AppLocalizations.of(context)!.pleaseEnterTheCodeWeJustSentTo,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge!.copyWith(color: AppColors.pureWhite),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          widget.email,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium!.copyWith(color: AppColors.pureWhite),
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

  Widget _buildResendCodeSection() {
    return Text.rich(
      TextSpan(
        text: AppLocalizations.of(context)!.didntReceiveOTP,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium!.copyWith(color: AppColors.pureWhite),
        children: [
          TextSpan(
            text: _canResend
                ? AppLocalizations.of(context)!.resendCode
                : _formatTime(_resendSeconds),
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: _canResend
                  ? AppColors.pureWhite
                  : AppColors.pureWhite.withValues(alpha: 0.5),
              fontSize: 15,
              fontWeight: FontWeight.w700,
              decoration: _canResend
                  ? TextDecoration.underline
                  : TextDecoration.none,
              decorationColor: AppColors.pureWhite,
            ),
            recognizer: _canResend
                ? (TapGestureRecognizer()..onTap = _startResendTimer)
                : null,
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  _submit() async {
    final auth = context.read<AuthProvider>();

    if (_pinController.text.length != 6) {
      showAppSnackBar(
        context,
        AppLocalizations.of(context)!.pinIsRequired,
        type: SnackBarType.warning,
      );
      return;
    }

    final success = await auth.confirmAccount(
      email: widget.email,
      confirmationCode: _pinController.text,
    );

    if (!mounted) return;

    if (success) {
      navigatorKey.currentState!.pushReplacementNamed(AppRoutes.loginRoute);
    } else {
      showAppSnackBar(context, auth.error);
    }
  }
}
