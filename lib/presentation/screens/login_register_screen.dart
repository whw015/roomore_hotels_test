import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/app_flow/app_flow_cubit.dart';
import '../../cubits/app_flow/app_flow_state.dart';
import '../../data/repositories/auth_repository.dart';
import 'home_screen.dart';

class LoginRegisterScreen extends StatefulWidget {
  const LoginRegisterScreen({super.key});

  static const routeName = '/login';

  @override
  State<LoginRegisterScreen> createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLogin = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<AppFlowCubit, AppFlowState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == AppFlowStatus.home) {
          Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isLogin ? 'login'.tr() : 'create_account'.tr()),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ModeToggle(
                  isLogin: _isLogin,
                  onChanged: (value) {
                    setState(() {
                      _isLogin = value;
                    });
                  },
                ),
                const SizedBox(height: 24),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(labelText: 'email'.tr()),
                        validator: (value) {
                          final email = value?.trim() ?? '';
                          if (email.isEmpty || !email.contains('@')) {
                            return 'enter_valid_email'.tr();
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(labelText: 'password'.tr()),
                        validator: (value) {
                          final password = value ?? '';
                          if (password.length < 6) {
                            return 'min_6_chars'.tr();
                          }
                          return null;
                        },
                      ),
                      if (!_isLogin) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'confirm_password'.tr(),
                          ),
                          validator: (value) {
                            if (_isLogin) {
                              return null;
                            }
                            if (value == null || value.isEmpty) {
                              return 'required'.tr();
                            }
                            if (value != _passwordController.text) {
                              return 'passwords_not_match'.tr();
                            }
                            return null;
                          },
                        ),
                      ],
                      const SizedBox(height: 32),
                      FilledButton(
                        onPressed: _isSubmitting ? null : _submit,
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _isLogin ? 'login'.tr() : 'create_account'.tr(),
                              ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isLogin = !_isLogin;
                          });
                        },
                        child: Text(
                          _isLogin
                              ? 'create_account'.tr()
                              : 'already_have_account'.tr(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'auth.or_sign_in_with'.tr(),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelLarge,
                ),
                const SizedBox(height: 16),
                _SocialButton(
                  icon: Icons.phone,
                  label: 'by_phone'.tr(),
                  onPressed: _isSubmitting ? null : _signInWithPhone,
                ),
                const SizedBox(height: 12),
                _SocialButton(
                  icon: Icons.g_mobiledata,
                  label: 'google'.tr(),
                  onPressed: _isSubmitting ? null : _signInWithGoogle,
                ),
                const SizedBox(height: 12),
                _SocialButton(
                  icon: Icons.apple,
                  label: 'apple'.tr(),
                  onPressed: _isSubmitting ? null : _signInWithApple,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isSubmitting = true;
    });
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final authRepository = context.read<AuthRepository>();
    final flowCubit = context.read<AppFlowCubit>();
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (_isLogin) {
        await authRepository.signInWithEmail(email: email, password: password);
      } else {
        await authRepository.registerWithEmail(
          email: email,
          password: password,
        );
      }
      if (!mounted) return;
      await flowCubit.refreshFlow();
      messenger.showSnackBar(SnackBar(content: Text('success_signed_in'.tr())));
    } on FirebaseAuthException catch (e) {
      _showErrorMessage(e);
    } catch (error) {
      _showErrorMessage(error);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isSubmitting = true;
    });
    final authRepository = context.read<AuthRepository>();
    final flowCubit = context.read<AppFlowCubit>();
    final messenger = ScaffoldMessenger.of(context);
    try {
      await authRepository.signInWithGoogle();
      if (!mounted) return;
      await flowCubit.refreshFlow();
      messenger.showSnackBar(SnackBar(content: Text('success_signed_in'.tr())));
    } on AuthCancelledException {
      // User cancelled the dialog, no feedback needed.
    } on FirebaseAuthException catch (e) {
      _showErrorMessage(e);
    } catch (error) {
      _showErrorMessage(error);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _signInWithApple() async {
    setState(() {
      _isSubmitting = true;
    });
    final authRepository = context.read<AuthRepository>();
    final flowCubit = context.read<AppFlowCubit>();
    final messenger = ScaffoldMessenger.of(context);
    try {
      await authRepository.signInWithApple();
      if (!mounted) return;
      await flowCubit.refreshFlow();
      messenger.showSnackBar(SnackBar(content: Text('success_signed_in'.tr())));
    } on AuthUnavailableException catch (e) {
      _showErrorMessage(e);
    } on FirebaseAuthException catch (e) {
      _showErrorMessage(e);
    } catch (error) {
      _showErrorMessage(error);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _signInWithPhone() async {
    final phone = await _promptForValue(
      title: 'by_phone'.tr(),
      label: 'phone_number'.tr(),
      hint: 'enter_phone_number'.tr(),
      keyboardType: TextInputType.phone,
    );
    if (!mounted) return;
    if (phone == null) {
      return;
    }
    setState(() {
      _isSubmitting = true;
    });
    final authRepository = context.read<AuthRepository>();
    final flowCubit = context.read<AppFlowCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final completer = Completer<void>();
    try {
      await authRepository.auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (credential) async {
          if (completer.isCompleted) {
            return;
          }
          try {
            await authRepository.signInWithCredential(credential);
            completer.complete();
          } catch (error) {
            if (!completer.isCompleted) {
              completer.completeError(error);
            }
          }
        },
        verificationFailed: (e) {
          if (!completer.isCompleted) {
            completer.completeError(e);
          }
        },
        codeSent: (verificationId, resendToken) async {
          final code = await _promptForValue(
            title: 'sms_code'.tr(),
            label: 'sms_code'.tr(),
            hint: 'enter_sms_code'.tr(),
            keyboardType: TextInputType.number,
          );
          if (!mounted) {
            if (!completer.isCompleted) {
              completer.completeError(const AuthCancelledException('phone'));
            }
            return;
          }
          if (code == null) {
            if (!completer.isCompleted) {
              completer.completeError(const AuthCancelledException('phone'));
            }
            return;
          }
          final credential = PhoneAuthProvider.credential(
            verificationId: verificationId,
            smsCode: code,
          );
          try {
            await authRepository.signInWithCredential(credential);
            if (!completer.isCompleted) {
              completer.complete();
            }
          } catch (error) {
            if (!completer.isCompleted) {
              completer.completeError(error);
            }
          }
        },
        codeAutoRetrievalTimeout: (_) {
          if (!completer.isCompleted) {
            completer.completeError(
              FirebaseAuthException(
                code: 'timeout',
                message: 'common.error'.tr(),
              ),
            );
          }
        },
      );
      await completer.future;
      if (!mounted) return;
      await flowCubit.refreshFlow();
      messenger.showSnackBar(SnackBar(content: Text('success_signed_in'.tr())));
    } on AuthCancelledException {
      // User cancelled, no feedback needed.
    } on FirebaseAuthException catch (e) {
      _showErrorMessage(e);
    } catch (error) {
      _showErrorMessage(error);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<String?> _promptForValue({
    required String title,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(labelText: label, hintText: hint),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: Text(MaterialLocalizations.of(context).okButtonLabel),
            ),
          ],
        );
      },
    );
    controller.dispose();
    final value = result?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }
    return value;
  }

  void _showErrorMessage(Object error) {
    if (!mounted) return;
    String message;
    if (error is AuthUnavailableException) {
      message = 'common.coming_soon'.tr();
    } else if (error is FirebaseAuthException) {
      message = error.message ?? 'unknown_error'.tr();
    } else {
      message = 'unknown_error'.tr();
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.isLogin, required this.onChanged});

  final bool isLogin;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ModeButton(
            label: 'login'.tr(),
            isSelected: isLogin,
            onTap: () => onChanged(true),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ModeButton(
            label: 'create_account'.tr(),
            isSelected: !isLogin,
            onTap: () => onChanged(false),
          ),
        ),
      ],
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? Theme.of(context).colorScheme.primary
            : null,
        foregroundColor: isSelected
            ? Colors.white
            : Theme.of(context).colorScheme.primary,
      ),
      onPressed: onTap,
      child: Text(label),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}
