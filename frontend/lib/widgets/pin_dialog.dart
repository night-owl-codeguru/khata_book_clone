import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import '../services/security_service.dart';

class PinDialog extends StatefulWidget {
  final String title;
  final String? subtitle;
  final bool isSettingPin;
  final String? oldPin;

  const PinDialog({
    super.key,
    required this.title,
    this.subtitle,
    this.isSettingPin = false,
    this.oldPin,
  });

  static Future<String?> show(
    BuildContext context, {
    required String title,
    String? subtitle,
    bool isSettingPin = false,
    String? oldPin,
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PinDialog(
        title: title,
        subtitle: subtitle,
        isSettingPin: isSettingPin,
        oldPin: oldPin,
      ),
    );
  }

  @override
  State<PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<PinDialog> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  String _errorMessage = '';
  bool _isLoading = false;
  int _step = 0; // 0: enter PIN, 1: confirm PIN (for setting)

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.title,
        style: AppTypography.title.copyWith(fontWeight: FontWeight.w600),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.subtitle != null) ...[
              Text(
                widget.subtitle!,
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],

            if (_step == 0) ...[
              TextField(
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: InputDecoration(
                  labelText: widget.isSettingPin
                      ? 'Enter PIN'
                      : 'Enter your PIN',
                  hintText: '4-6 digits',
                  errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                autofocus: true,
                onChanged: (value) {
                  if (_errorMessage.isNotEmpty) {
                    setState(() => _errorMessage = '');
                  }
                },
              ),
            ] else ...[
              TextField(
                controller: _confirmPinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: InputDecoration(
                  labelText: 'Confirm PIN',
                  hintText: 'Re-enter your PIN',
                  errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                autofocus: true,
                onChanged: (value) {
                  if (_errorMessage.isNotEmpty) {
                    setState(() => _errorMessage = '');
                  }
                },
              ),
            ],

            if (_isLoading) ...[
              const SizedBox(height: 16),
              const CircularProgressIndicator(),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
        ),
        if (_step == 0)
          ElevatedButton(
            onPressed: _isLoading ? null : _onPrimaryButtonPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary500,
              foregroundColor: Colors.white,
            ),
            child: Text(widget.isSettingPin ? 'Next' : 'Verify'),
          )
        else
          ElevatedButton(
            onPressed: _isLoading ? null : _onConfirmPinPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary500,
              foregroundColor: Colors.white,
            ),
            child: const Text('Set PIN'),
          ),
      ],
    );
  }

  void _onPrimaryButtonPressed() async {
    final pin = _pinController.text.trim();

    if (pin.length < 4) {
      setState(() => _errorMessage = 'PIN must be at least 4 digits');
      return;
    }

    if (widget.isSettingPin) {
      // Move to confirmation step
      setState(() => _step = 1);
    } else {
      // Verify existing PIN
      await _verifyPin(pin);
    }
  }

  void _onConfirmPinPressed() async {
    final pin = _pinController.text.trim();
    final confirmPin = _confirmPinController.text.trim();

    if (pin != confirmPin) {
      setState(() => _errorMessage = 'PINs do not match');
      return;
    }

    await _setPin(pin);
  }

  Future<void> _verifyPin(String pin) async {
    setState(() => _isLoading = true);

    try {
      final isValid = await SecurityService.verifyPin(pin);
      if (isValid) {
        Navigator.of(context).pop(pin);
      } else {
        final status = await SecurityService.getSecurityStatus();
        final remainingAttempts = status['remainingAttempts'] as int;
        final isLockedOut = status['isLockedOut'] as bool;

        if (isLockedOut) {
          setState(
            () => _errorMessage = 'Too many failed attempts. Try again later.',
          );
        } else {
          setState(
            () => _errorMessage =
                'Incorrect PIN. $remainingAttempts attempts remaining.',
          );
        }
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _setPin(String pin) async {
    setState(() => _isLoading = true);

    try {
      await SecurityService.setPin(pin);
      Navigator.of(context).pop(pin);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
