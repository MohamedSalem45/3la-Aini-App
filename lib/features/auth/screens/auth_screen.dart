import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../../orders/screens/home_screen.dart';
import '../../../core/constants/app_colors.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  final _loginPhone = TextEditingController();
  final _loginPassword = TextEditingController();
  final _regName = TextEditingController();
  final _regPhone = TextEditingController();
  final _regPassword = TextEditingController();
  final _regConfirm = TextEditingController();

  bool _loginObscure = true;
  bool _regObscure = true;
  bool _loading = false;

  // Brute Force Protection
  int _failedAttempts = 0;
  DateTime? _lockUntil;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginPhone.dispose();
    _loginPassword.dispose();
    _regName.dispose();
    _regPhone.dispose();
    _regPassword.dispose();
    _regConfirm.dispose();
    super.dispose();
  }

  // ===== التحقق من قوة كلمة السر =====
  int _passwordStrength(String password) {
    int score = 0;
    if (password.length >= 8) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) score++;
    return score; // 0-4
  }

  Color _strengthColor(int strength) {
    switch (strength) {
      case 0:
      case 1: return Colors.redAccent;
      case 2: return Colors.orange;
      case 3: return Colors.amber;
      default: return AppColors.statusDelivered;
    }
  }

  String _strengthLabel(int strength) {
    switch (strength) {
      case 0:
      case 1: return '\u0636\u0639\u064a\u0641\u0629 \u062c\u062f\u0627\u064b';
      case 2: return '\u0645\u062a\u0648\u0633\u0637\u0629';
      case 3: return '\u062c\u064a\u062f\u0629';
      default: return '\u0642\u0648\u064a\u0629 \u062c\u062f\u0627\u064b \u2705';
    }
  }

  // ===== التحقق من رقم الهاتف =====
  String? _validatePhone(String? v) {
    if (v == null || v.trim().isEmpty) {
      return '\u0623\u062f\u062e\u0644 \u0631\u0642\u0645 \u0627\u0644\u0647\u0627\u062a\u0641';
    }
    final digits = v.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 7 || digits.length > 15) {
      return '\u0631\u0642\u0645 \u0627\u0644\u0647\u0627\u062a\u0641 \u063a\u064a\u0631 \u0635\u062d\u064a\u062d';
    }
    return null;
  }

  // ===== Brute Force Check =====
  bool get _isLocked {
    if (_lockUntil == null) return false;
    if (DateTime.now().isAfter(_lockUntil!)) {
      _lockUntil = null;
      _failedAttempts = 0;
      return false;
    }
    return true;
  }

  int get _lockSecondsLeft {
    if (_lockUntil == null) return 0;
    return _lockUntil!.difference(DateTime.now()).inSeconds.clamp(0, 999);
  }

  void _onLoginFailed() {
    _failedAttempts++;
    if (_failedAttempts >= 5) {
      _lockUntil = DateTime.now().add(const Duration(minutes: 5));
      _failedAttempts = 0;
    }
  }

  // ===== تسجيل الدخول =====
  void _login() async {
    if (_isLocked) {
      _showError('\u062a\u0645 \u062a\u062c\u0645\u064a\u062f \u0627\u0644\u062d\u0633\u0627\u0628 \u0645\u0624\u0642\u062a\u0627\u064b. \u062d\u0627\u0648\u0644 \u0628\u0639\u062f $_lockSecondsLeft \u062b\u0627\u0646\u064a\u0629');
      return;
    }
    if (!_loginFormKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AuthService.instance.login(
        phone: _loginPhone.text.trim(),
        password: _loginPassword.text,
      );
      _failedAttempts = 0;
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      _onLoginFailed();
      _showError(_authError(e.code));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ===== إنشاء حساب =====
  void _register() async {
    if (!_registerFormKey.currentState!.validate()) return;
    if (_passwordStrength(_regPassword.text) < 2) {
      _showError('\u0643\u0644\u0645\u0629 \u0627\u0644\u0633\u0631 \u0636\u0639\u064a\u0641\u0629. \u0623\u0636\u0641 \u0623\u0631\u0642\u0627\u0645\u0627\u064b \u0648\u062d\u0631\u0648\u0641\u0627\u064b \u0643\u0628\u064a\u0631\u0629');
      return;
    }
    setState(() => _loading = true);
    try {
      await AuthService.instance.register(
        name: _regName.text.trim(),
        phone: _regPhone.text.trim(),
        password: _regPassword.text,
      );
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      _showError(_authError(e.code));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _authError(String code) {
    switch (code) {
      case 'user-not-found': return '\u0631\u0642\u0645 \u0627\u0644\u0647\u0627\u062a\u0641 \u063a\u064a\u0631 \u0645\u0633\u062c\u0651\u0644';
      case 'wrong-password': return '\u0643\u0644\u0645\u0629 \u0627\u0644\u0633\u0631 \u063a\u064a\u0631 \u0635\u062d\u064a\u062d\u0629';
      case 'email-already-in-use': return '\u0647\u0630\u0627 \u0627\u0644\u0631\u0642\u0645 \u0645\u0633\u062c\u0651\u0644 \u0645\u0633\u0628\u0642\u0627\u064b';
      case 'weak-password': return '\u0643\u0644\u0645\u0629 \u0627\u0644\u0633\u0631 \u0636\u0639\u064a\u0641\u0629 (6 \u0623\u062d\u0631\u0641 \u0639\u0644\u0649 \u0627\u0644\u0623\u0642\u0644)';
      case 'invalid-credential': return '\u0631\u0642\u0645 \u0627\u0644\u0647\u0627\u062a\u0641 \u0623\u0648 \u0643\u0644\u0645\u0629 \u0627\u0644\u0633\u0631 \u063a\u064a\u0631 \u0635\u062d\u064a\u062d\u0629';
      case 'too-many-requests': return '\u0645\u062d\u0627\u0648\u0644\u0627\u062a \u0643\u062b\u064a\u0631\u0629. \u062d\u0627\u0648\u0644 \u0644\u0627\u062d\u0642\u0627\u064b';
      default: return '\u062d\u062f\u062b \u062e\u0637\u0623\u060c \u062d\u0627\u0648\u0644 \u0645\u0631\u0629 \u062b\u0627\u0646\u064a\u0629';
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'IBMPlexSansArabic', )),
      backgroundColor: Colors.redAccent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            _buildTabContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      child: Column(
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20, offset: const Offset(0, 8),
              )],
            ),
            child: const Icon(Icons.remove_red_eye_outlined,
                color: AppColors.primary, size: 40),
          ).animate().scale(
              begin: const Offset(0.5, 0.5),
              duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 16),
          const Text('\u0639\u0644\u0649 \u0639\u064a\u0646\u064a',
              style: TextStyle(fontFamily: 'IBMPlexSansArabic', 
                  fontSize: 32, fontWeight: FontWeight.w800,
                  color: Colors.white))
              .animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
          const SizedBox(height: 6),
          const Text('\u062a\u0633\u0648\u0642 \u0634\u062e\u0635\u064a \u2022 \u062a\u0648\u0635\u064a\u0644 \u0641\u0648\u0631\u064a \u2022 \u0645\u0639\u0631\u0628\u0627',
              style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 13, color: Colors.white70))
              .animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(14),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontWeight: FontWeight.w700, fontSize: 14),
        unselectedLabelStyle: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontWeight: FontWeight.w500, fontSize: 14),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: '\u062a\u0633\u062c\u064a\u0644 \u0627\u0644\u062f\u062e\u0648\u0644'),
          Tab(text: '\u062d\u0633\u0627\u0628 \u062c\u062f\u064a\u062f'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return SizedBox(
      height: 560,
      child: TabBarView(
        controller: _tabController,
        children: [_buildLoginForm(), _buildRegisterForm()],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _loginFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isLocked)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_clock_outlined,
                        color: Colors.redAccent, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '\u062a\u0645 \u062a\u062c\u0645\u064a\u062f \u0627\u0644\u062d\u0633\u0627\u0628 \u0645\u0624\u0642\u062a\u0627\u064b. \u062d\u0627\u0648\u0644 \u0628\u0639\u062f $_lockSecondsLeft \u062b\u0627\u0646\u064a\u0629',
                        style: const TextStyle(fontFamily: 'IBMPlexSansArabic', 
                            fontSize: 12, color: Colors.redAccent),
                      ),
                    ),
                  ],
                ),
              ),
            if (_failedAttempts > 0 && !_isLocked)
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '\u062a\u062d\u0630\u064a\u0631: ${5 - _failedAttempts} \u0645\u062d\u0627\u0648\u0644\u0629 \u0645\u062a\u0628\u0642\u064a\u0629 \u0642\u0628\u0644 \u0627\u0644\u062a\u062c\u0645\u064a\u062f',
                  style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 12, color: Colors.orange),
                ),
              ),
            _buildField(
              controller: _loginPhone,
              hint: '\u0631\u0642\u0645 \u0627\u0644\u0647\u0627\u062a\u0641',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              ltr: true,
              validator: _validatePhone,
            ),
            const SizedBox(height: 16),
            _buildField(
              controller: _loginPassword,
              hint: '\u0643\u0644\u0645\u0629 \u0627\u0644\u0633\u0631',
              icon: Icons.lock_outline,
              obscure: _loginObscure,
              suffixIcon: IconButton(
                icon: Icon(
                  _loginObscure ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textSecondary, size: 20,
                ),
                onPressed: () => setState(() => _loginObscure = !_loginObscure),
              ),
              validator: (v) => (v == null || v.isEmpty)
                  ? '\u0623\u062f\u062e\u0644 \u0643\u0644\u0645\u0629 \u0627\u0644\u0633\u0631' : null,
            ),
            const SizedBox(height: 28),
            _buildSubmitButton('\u062f\u062e\u0648\u0644', _login),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterForm() {
    final strength = _passwordStrength(_regPassword.text);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _registerFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildField(
              controller: _regName,
              hint: '\u0627\u0633\u0645\u0643 \u0627\u0644\u0643\u0631\u064a\u0645',
              icon: Icons.person_outline,
              validator: (v) => (v == null || v.trim().length < 2)
                  ? '\u0623\u062f\u062e\u0644 \u0627\u0633\u0645\u0643 (\u062d\u0631\u0641\u064a\u0646 \u0639\u0644\u0649 \u0627\u0644\u0623\u0642\u0644)' : null,
            ),
            const SizedBox(height: 14),
            _buildField(
              controller: _regPhone,
              hint: '\u0631\u0642\u0645 \u0627\u0644\u0647\u0627\u062a\u0641',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              ltr: true,
              validator: _validatePhone,
            ),
            const SizedBox(height: 14),
            _buildField(
              controller: _regPassword,
              hint: '\u0643\u0644\u0645\u0629 \u0627\u0644\u0633\u0631',
              icon: Icons.lock_outline,
              obscure: _regObscure,
              suffixIcon: IconButton(
                icon: Icon(
                  _regObscure ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textSecondary, size: 20,
                ),
                onPressed: () => setState(() => _regObscure = !_regObscure),
              ),
              onChanged: (_) => setState(() {}),
              validator: (v) {
                if (v == null || v.length < 6) {
                  return '\u0643\u0644\u0645\u0629 \u0627\u0644\u0633\u0631 \u0642\u0635\u064a\u0631\u0629 (6 \u0623\u062d\u0631\u0641 \u0639\u0644\u0649 \u0627\u0644\u0623\u0642\u0644)';
                }
                return null;
              },
            ),
            // مؤشر قوة كلمة السر
            if (_regPassword.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  ...List.generate(4, (i) => Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(left: i < 3 ? 4 : 0),
                      decoration: BoxDecoration(
                        color: i < strength
                            ? _strengthColor(strength)
                            : AppColors.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  )),
                  const SizedBox(width: 8),
                  Text(_strengthLabel(strength),
                      style: TextStyle(fontFamily: 'IBMPlexSansArabic', 
                          fontSize: 11,
                          color: _strengthColor(strength),
                          fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 6),
              // نصائح كلمة السر
              _buildPasswordTips(),
            ],
            const SizedBox(height: 14),
            _buildField(
              controller: _regConfirm,
              hint: '\u062a\u0623\u0643\u064a\u062f \u0643\u0644\u0645\u0629 \u0627\u0644\u0633\u0631',
              icon: Icons.lock_outline,
              obscure: _regObscure,
              validator: (v) => v != _regPassword.text
                  ? '\u0643\u0644\u0645\u062a\u0627 \u0627\u0644\u0633\u0631 \u063a\u064a\u0631 \u0645\u062a\u0637\u0627\u0628\u0642\u062a\u064a\u0646' : null,
            ),
            const SizedBox(height: 28),
            _buildSubmitButton('\u0625\u0646\u0634\u0627\u0621 \u062d\u0633\u0627\u0628', _register),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordTips() {
    final p = _regPassword.text;
    return Column(
      children: [
        _tip(p.length >= 8, '8 \u0623\u062d\u0631\u0641 \u0639\u0644\u0649 \u0627\u0644\u0623\u0642\u0644'),
        _tip(p.contains(RegExp(r'[A-Z]')), '\u062d\u0631\u0641 \u0643\u0628\u064a\u0631 (A-Z)'),
        _tip(p.contains(RegExp(r'[0-9]')), '\u0631\u0642\u0645 \u0648\u0627\u062d\u062f \u0639\u0644\u0649 \u0627\u0644\u0623\u0642\u0644'),
        _tip(p.contains(RegExp(r'[!@#\$%^&*]')), '\u0631\u0645\u0632 \u062e\u0627\u0635 (!@#\$)'),
      ],
    );
  }

  Widget _tip(bool done, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            size: 14,
            color: done ? AppColors.statusDelivered : AppColors.textHint,
          ),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(fontFamily: 'IBMPlexSansArabic', 
                  fontSize: 11,
                  color: done ? AppColors.statusDelivered : AppColors.textHint)),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    bool ltr = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      textDirection: ltr ? TextDirection.ltr : TextDirection.rtl,
      keyboardType: keyboardType,
      style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 15),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintTextDirection: TextDirection.rtl,
        prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
        suffixIcon: suffixIcon,
      ),
      validator: validator,
    );
  }

  Widget _buildSubmitButton(String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: (_loading || _isLocked) ? null : onTap,
        child: _loading
            ? const SizedBox(width: 22, height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5))
            : Text(label,
                style: const TextStyle(fontFamily: 'IBMPlexSansArabic', 
                    fontSize: 17, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
