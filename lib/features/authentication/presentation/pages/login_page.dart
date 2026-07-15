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

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final ValueNotifier<bool> _obscurePassword = ValueNotifier<bool>(true);
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

  void _submitLogin() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    context.read<AuthBloc>().add(
      AuthLoginSubmitted(
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
    _obscurePassword.dispose();
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
                          title: AppStrings.authWelcomeBackTitle,
                          description: AppStrings.authWelcomeBackDescription,
                          animation: _headerAnimation,
                        ),
                        const SizedBox(height: 34),
                        AuthFormContainer(
                          animation: _formAnimation,
                          child: _LoginForm(
                            formKey: _formKey,
                            emailController: _emailController,
                            passwordController: _passwordController,
                            obscurePassword: _obscurePassword,
                            onSubmit: _submitLogin,
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

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onSubmit,
  });
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final ValueNotifier<bool> obscurePassword;
  final VoidCallback onSubmit;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (previous, current) {
        return previous.runtimeType != current.runtimeType;
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        final errorMessage = switch (state) {
          AuthFailure(:final message) => message,
          _ => null,
        };
        return AutofillGroup(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                AppTextFormField(
                  fieldKey: const Key('login_email_field'),
                  controller: emailController,
                  label: AppStrings.authEmailAddressLabel,
                  hint: AppStrings.authEmailHint,
                  prefixIcon: Icons.email_outlined,
                  validator: Validators.email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  enabled: !isLoading,
                ),
                const SizedBox(height: 18),
                ValueListenableBuilder<bool>(
                  valueListenable: obscurePassword,
                  builder: (context, isObscured, _) {
                    return AppTextFormField(
                      fieldKey: const Key('login_password_field'),
                      controller: passwordController,
                      label: AppStrings.authPasswordLabel,
                      hint: AppStrings.authPasswordHint,
                      prefixIcon: Icons.lock_outline_rounded,
                      validator: Validators.password,
                      obscureText: isObscured,
                      enabled: !isLoading,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      onFieldSubmitted: (_) => onSubmit(),
                      suffixIcon: IconButton(
                        key: const Key('login_password_visibility_button'),
                        tooltip: isObscured
                            ? AppStrings.authPasswordShowTooltip
                            : AppStrings.authPasswordHideTooltip,
                        onPressed: () {
                          obscurePassword.value = !isObscured;
                        },
                        icon: Icon(
                          isObscured
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    );
                  },
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  child: errorMessage == null
                      ? const SizedBox(height: 24)
                      : Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 20),
                          child: _InlineError(message: errorMessage),
                        ),
                ),
                AppButton(
                  buttonKey: const Key('login_submit_button'),
                  label: AppStrings.authLoginButtonLabel,
                  icon: Icons.arrow_forward_rounded,
                  isLoading: isLoading,
                  onPressed: onSubmit,
                ),
                const SizedBox(width: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.authNewToAppPrompt,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      key: const Key('open_register_button'),
                      onPressed: isLoading
                          ? null
                          : () {
                              Navigator.pushNamed(context, AppRoutes.register);
                            },
                      child: const Text(
                        AppStrings.authCreateAccountButtonLabel,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});
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
