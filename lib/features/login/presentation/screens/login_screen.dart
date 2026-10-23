import 'package:flutter/material.dart';

import '../../../../config/app_colors.dart';
import '../../../../config/app_size.dart';
import '../../../../core/widgets/inline_error_box.dart';
import '../../data/datasources/auth_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final AuthRepository _auth =
      AuthRepositoryImpl(AuthDatasource());

  final _formKey          = GlobalKey<FormState>();
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();

  bool    _loading          = false;
  bool    _obscurePassword  = true;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });

    final result = await _auth.signIn(
      _emailController.text,
      _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    switch (result) {
      case SignInResult.success:
        break;
      case SignInResult.notAdmin:
        setState(() => _error =
            'Access denied. This account does not have admin privileges.');
      case SignInResult.invalidCredentials:
        setState(() => _error =
            'Incorrect email or password. Please try again.');
      case SignInResult.tooManyRequests:
        setState(() => _error =
            'Too many failed attempts. Please wait a moment and try again.');
      case SignInResult.error:
        setState(() => _error = 'Sign-in failed. Please try again.');
    }
  }

  InputDecoration _inputDecoration(
      {required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54),
      prefixIcon: Icon(icon, color: Colors.white38, size: AppSize.iconMd),
      filled: true,
      fillColor: Colors.white.withOpacity(0.07),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSize.radiusMd),
        borderSide: const BorderSide(color: Colors.white12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSize.radiusMd),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSize.radiusMd),
        borderSide: BorderSide(color: AppColors.danger.withOpacity(0.6)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSize.radiusMd),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
      errorStyle: const TextStyle(color: AppColors.danger),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Container(
          width: AppSize.loginCardWidth,
          padding: const EdgeInsets.all(AppSize.xxl),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSize.radiusXl),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 40,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Logo ──────────────────────────────────────────────────
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.checkroom,
                      color: Colors.white, size: AppSize.iconXl),
                ),
                const SizedBox(height: AppSize.lg),
                Text('Fashion Admin',
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: AppSize.sm),
                Text(
                  'Sign in to manage your outfit platform',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // ── Error banner ──────────────────────────────────────────
                if (_error != null) ...[
                  InlineErrorBox(message: _error!),
                  const SizedBox(height: 20),
                ],

                // ── Email ─────────────────────────────────────────────────
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  style: const TextStyle(color: AppColors.textLight),
                  decoration: _inputDecoration(
                      label: 'Email', icon: Icons.email_outlined),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter your email';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                  onFieldSubmitted: (_) =>
                      FocusScope.of(context).nextFocus(),
                ),
                const SizedBox(height: AppSize.md),

                // ── Password ──────────────────────────────────────────────
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  autofillHints: const [AutofillHints.password],
                  style: const TextStyle(color: AppColors.textLight),
                  decoration:
                      _inputDecoration(label: 'Password', icon: Icons.lock_outline)
                          .copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Colors.white38,
                        size: AppSize.iconMd,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter your password';
                    return null;
                  },
                  onFieldSubmitted: (_) => _handleSignIn(),
                ),
                const SizedBox(height: 28),

                // ── Sign in button ────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: AppSize.buttonHeight,
                  child: _loading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.accent))
                      : ElevatedButton(
                          onPressed: _handleSignIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppSize.radiusMd),
                            ),
                          ),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: AppSize.lg),

                // ── Footer ────────────────────────────────────────────────
                Row(
                  children: [
                    const Expanded(child: Divider(color: Colors.white12)),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'Admin access only',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontSize: 12),
                      ),
                    ),
                    const Expanded(child: Divider(color: Colors.white12)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
