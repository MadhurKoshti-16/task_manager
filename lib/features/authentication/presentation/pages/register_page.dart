import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_form_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_animated_background.dart';
import '../widgets/auth_form_container.dart';
import '../widgets/auth_header.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final ValueNotifier<bool> _obscurePassword = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _obscureConfirmPassword = ValueNotifier<bool>(true);
  late final AnimationController _animationController;
  late final Animation<double> _backgroundAnimation;
  late final Animation<double> _headerAnimation;
  late final Animation<double> _formAnimation;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );
    _backgroundAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _headerAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0, 0.55, curve: Curves.easeOutCubic),
    );
    _formAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.25, 1, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }

  void _submitRegistration() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    context.read<AuthBloc>().add(
      AuthRegisterSubmitted(
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );
  }

  void _handleState(BuildContext context, AuthState state) {
    if (state case AuthAuthenticated()) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.dashboard,
        (_) => false,
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _obscurePassword.dispose();
    _obscureConfirmPassword.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: _handleState,
      child: Scaffold(
        body: Stack(
          children: [
            AuthAnimatedBackground(animation: _backgroundAnimation),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 28),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      children: [
                        AuthHeader(
                          title: AppStrings.authRegisterTitle,
                          description: AppStrings.authRegisterDescription,
                          animation: _headerAnimation,
                        ),
                        const SizedBox(height: 34),
                        AuthFormContainer(
                          animation: _formAnimation,
                          child: BlocBuilder<AuthBloc, AuthState>(
                            buildWhen: (previous, current) {
                              return previous.runtimeType !=
                                  current.runtimeType;
                            },
                            builder: (context, state) {
                              final isLoading = state is AuthLoading;
                              final errorMessage = switch (state) {
                                AuthFailure(:final message) => message,
                                _ => null,
                              };
                              return AutofillGroup(
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      AppTextFormField(
                                        controller: _emailController,
                                        label: AppStrings.authEmailAddressLabel,
                                        hint: AppStrings.authEmailHint,
                                        prefixIcon: Icons.email_outlined,
                                        validator: Validators.email,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        textInputAction: TextInputAction.next,
                                        autofillHints: const [
                                          AutofillHints.email,
                                        ],
                                        enabled: !isLoading,
                                      ),
                                      const SizedBox(height: 18),
                                      ValueListenableBuilder<bool>(
                                        valueListenable: _obscurePassword,
                                        builder: (context, isObscured, _) {
                                          return AppTextFormField(
                                            controller: _passwordController,
                                            label: AppStrings.authPasswordLabel,
                                            hint: AppStrings
                                                .authRegisterPasswordHint,
                                            prefixIcon:
                                                Icons.lock_outline_rounded,
                                            validator: Validators.password,
                                            obscureText: isObscured,
                                            enabled: !isLoading,
                                            textInputAction:
                                                TextInputAction.next,
                                            autofillHints: const [
                                              AutofillHints.newPassword,
                                            ],
                                            suffixIcon: IconButton(
                                              onPressed: () {
                                                _obscurePassword.value =
                                                    !isObscured;
                                              },
                                              icon: Icon(
                                                isObscured
                                                    ? Icons.visibility_outlined
                                                    : Icons
                                                          .visibility_off_outlined,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 18),
                                      ValueListenableBuilder<bool>(
                                        valueListenable:
                                            _obscureConfirmPassword,
                                        builder: (context, isObscured, _) {
                                          return AppTextFormField(
                                            controller:
                                                _confirmPasswordController,
                                            label: AppStrings
                                                .authConfirmPasswordLabel,
                                            hint: AppStrings
                                                .authConfirmPasswordHint,
                                            prefixIcon:
                                                Icons.lock_reset_rounded,
                                            validator: (value) {
                                              return Validators.confirmPassword(
                                                value: value,
                                                password:
                                                    _passwordController.text,
                                              );
                                            },
                                            obscureText: isObscured,
                                            enabled: !isLoading,
                                            textInputAction:
                                                TextInputAction.done,
                                            autofillHints: const [
                                              AutofillHints.newPassword,
                                            ],
                                            onFieldSubmitted: (_) {
                                              _submitRegistration();
                                            },
                                            suffixIcon: IconButton(
                                              onPressed: () {
                                                _obscureConfirmPassword.value =
                                                    !isObscured;
                                              },
                                              icon: Icon(
                                                isObscured
                                                    ? Icons.visibility_outlined
                                                    : Icons
                                                          .visibility_off_outlined,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      AnimatedSize(
                                        duration: const Duration(
                                          milliseconds: 250,
                                        ),
                                        child: errorMessage == null
                                            ? const SizedBox(height: 24)
                                            : Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 16,
                                                  bottom: 20,
                                                ),
                                                child: _RegisterError(
                                                  message: errorMessage,
                                                ),
                                              ),
                                      ),
                                      AppButton(
                                        label:
                                            AppStrings.authRegisterButtonLabel,
                                        icon: Icons.arrow_forward_rounded,
                                        isLoading: isLoading,
                                        onPressed: _submitRegistration,
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            AppStrings
                                                .authAlreadyRegisteredPrompt,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodyMedium,
                                          ),
                                          TextButton(
                                            onPressed: isLoading
                                                ? null
                                                : () {
                                                    Navigator.pop(
                                                      context,
                                                      AppRoutes.login,
                                                    );
                                                  },
                                            child: const Text(
                                              AppStrings.authSignInButtonLabel,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
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
      ),
    );
  }
}

class _RegisterError extends StatelessWidget {
  const _RegisterError({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
