import 'package:flutter/material.dart';
import 'package:shiksha_darpan/models/user_model.dart';
import 'package:shiksha_darpan/services/auth_service.dart';
import 'package:shiksha_darpan/screens/attendance/teacher_dashboard_screen.dart';
import 'package:shiksha_darpan/screens/dashboard/district_dashboard_screen.dart';
import 'package:shiksha_darpan/screens/dashboard/state_dashboard_screen.dart';
import 'package:shiksha_darpan/screens/dashboard/national_dashboard_screen.dart';
import 'package:shiksha_darpan/screens/dashboard/principal_dashboard_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Palette constants
// ─────────────────────────────────────────────────────────────────────────────
const _bgDeep  = Color(0xFF060B24);
const _bgMid   = Color(0xFF0C1440);
const _bgLight = Color(0xFF132060);
const _accent  = Color(0xFF4FC3F7);

// ─────────────────────────────────────────────────────────────────────────────
// Per-category visual metadata
// ─────────────────────────────────────────────────────────────────────────────
class _PortalMeta {
  final AdministrativeLevel level;
  final String title;
  final String rolesLine;
  final IconData icon;
  final List<Color> gradient;
  final Color glow;
  /// Pre-baked glow with 35 % opacity for the card box-shadow.
  final Color shadowColor;
  /// Pre-baked glow with 14 % opacity for the icon chip background.
  final Color chipColor;

  const _PortalMeta({
    required this.level,
    required this.title,
    required this.rolesLine,
    required this.icon,
    required this.gradient,
    required this.glow,
    required this.shadowColor,
    required this.chipColor,
  });
}

const _portals = <_PortalMeta>[
  _PortalMeta(
    level: AdministrativeLevel.ground,
    title: 'Ground Level',
    rolesLine: 'Teacher  •  Principal\nSMC Member  •  Staff',
    icon: Icons.school_rounded,
    gradient: [Color(0xFF1B5E20), Color(0xFF388E3C)],
    glow: Color(0xFF66BB6A),
    shadowColor: Color(0x5966BB6A), // 35 % opacity
    chipColor:   Color(0x2466BB6A), // 14 % opacity
  ),
  _PortalMeta(
    level: AdministrativeLevel.intermediate,
    title: 'Block / District',
    rolesLine: 'CRCC  •  BRCC\nDistrict Education Officer',
    icon: Icons.location_city_rounded,
    gradient: [Color(0xFFBF360C), Color(0xFFE64A19)],
    glow: Color(0xFFFF7043),
    shadowColor: Color(0x59FF7043),
    chipColor:   Color(0x24FF7043),
  ),
  _PortalMeta(
    level: AdministrativeLevel.state,
    title: 'State Level',
    rolesLine: 'DPI  •  Secretary\nState Education Minister',
    icon: Icons.map_rounded,
    gradient: [Color(0xFF4A148C), Color(0xFF7B1FA2)],
    glow: Color(0xFFCE93D8),
    shadowColor: Color(0x59CE93D8),
    chipColor:   Color(0x24CE93D8),
  ),
  _PortalMeta(
    level: AdministrativeLevel.national,
    title: 'National Level',
    rolesLine: 'Secretary MoE\nUnion Minister',
    icon: Icons.account_balance_rounded,
    gradient: [Color(0xFF0D47A1), Color(0xFF1976D2)],
    glow: Color(0xFF64B5F6),
    shadowColor: Color(0x5964B5F6),
    chipColor:   Color(0x2464B5F6),
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// LoginScreen
// ─────────────────────────────────────────────────────────────────────────────
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  AdministrativeLevel? _selected;
  bool _isLoading = false;

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ── Routing ────────────────────────────────────────────────────────────────
  void _routeUser(UserModel profile) {
    late final Widget dest;
    if (profile.role == UserRole.principal) {
      dest = const PrincipalDashboardScreen();
    } else {
      switch (profile.level) {
        case AdministrativeLevel.ground:
          dest = const TeacherDashboardScreen();
          break;
        case AdministrativeLevel.intermediate:
          dest = const DistrictDashboardScreen();
          break;
        case AdministrativeLevel.state:
          dest = const StateDashboardScreen();
          break;
        case AdministrativeLevel.national:
          dest = const NationalDashboardScreen();
          break;
      }
    }
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => dest,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  // ── Google Sign-In handler ─────────────────────────────────────────────────
  Future<void> _handleSignIn() async {
    if (_selected == null) return;
    setState(() => _isLoading = true);

    try {
      final profile =
          await _authService.signInWithGoogleForCategory(_selected!);
      if (profile == null) {
        setState(() => _isLoading = false);
        return; // user cancelled Google picker
      }
      if (mounted) _routeUser(profile);
    } on AccountNotRegisteredException catch (e) {
      _showDialog(
        title: 'Account Not Registered',
        message: e.toString(),
        icon: Icons.person_off_rounded,
        iconColor: Colors.orangeAccent,
      );
    } on AccessDeniedException catch (e) {
      _showDialog(
        title: 'Access Denied',
        message: e.toString(),
        icon: Icons.block_rounded,
        iconColor: Colors.redAccent,
      );
    } catch (e) {
      _showDialog(
        title: 'Authentication Error',
        message:
            'Something went wrong. Please try again.\n\n'
            '${e.toString().replaceFirst('Exception: ', '')}',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showDialog({
    required String title,
    required String message,
    IconData icon = Icons.error_outline_rounded,
    Color iconColor = Colors.redAccent,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF131A3E),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          Icon(icon, color: iconColor, size: 26),
          const SizedBox(width: 10),
          Expanded(
            child: Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 17)),
          ),
        ]),
        content: Text(
          message,
          style: const TextStyle(
              color: Color(0xBFFFFFFF), fontSize: 14, height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Understood',
                style: TextStyle(
                    color: _accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 15)),
          )
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        // Background gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_bgDeep, _bgMid, _bgLight],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),

        // Decorative blobs
        _blob(top: -90,  right: -90, size: 240, color: const Color(0x2E1565C0)),
        _blob(bottom: -110, left: -70, size: 280, color: const Color(0x124CAF50)),
        _blob(top: 250,  left: -50,  size: 160, color: const Color(0x0FFF9800)),

        // Scrollable content
        SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 36),
                  _buildSectionLabel(),
                  const SizedBox(height: 18),
                  _buildPortalGrid(),
                  const SizedBox(height: 32),
                  _buildSignInButton(),
                  const SizedBox(height: 20),
                  _buildSecurityNote(),
                ],
              ),
            ),
          ),
        ),

        // Loading overlay
        if (_isLoading)
          Container(
            color: const Color(0xA6000000), // ~65% opacity black
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 36, vertical: 28),
                decoration: BoxDecoration(
                  color: const Color(0xFF131A3E),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: const Color(0x144FFFFF),
                      width: 1),
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0x264FC3F7),
                        blurRadius: 30)
                  ],
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 42,
                      height: 42,
                      child: CircularProgressIndicator(
                          color: _accent, strokeWidth: 3),
                    ),
                    SizedBox(height: 18),
                    Text(
                      'Verifying your credentials…',
                      style: TextStyle(
                          color: Color(0xBFFFFFFF), fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ]),
    );
  }

  // ── Helper widgets ─────────────────────────────────────────────────────────

  Widget _blob({
    double? top, double? bottom, double? left, double? right,
    required double size, required Color color,
  }) {
    return Positioned(
      top: top, bottom: bottom, left: left, right: right,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(children: [
      // Logo
      Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(21, 101, 192, 0.45),
              blurRadius: 28,
              spreadRadius: 4,
            )
          ],
        ),
        child: const Icon(Icons.account_balance, size: 42, color: Colors.white),
      ),
      const SizedBox(height: 18),
      const Text(
        'ShikshaDarpan',
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 0.6,
        ),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 5),
      const Text(
        'National Education Monitoring System',
        style: TextStyle(
            fontSize: 13,
            color: Color(0x8CFFFFFF),
            letterSpacing: 0.4),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 12),
      // Tricolour stripe
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _stripe(const Color(0xFFFF9800)),
          _stripe(const Color(0xD9FFFFFF)),
          _stripe(const Color(0xFF4CAF50)),
        ],
      ),
    ]);
  }

  Widget _stripe(Color color) => Container(
        width: 44,
        height: 3,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(2)),
      );

  Widget _buildSectionLabel() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Your Portal',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        SizedBox(height: 4),
        Text(
          'Choose the administrative level matching your designation.',
          style: TextStyle(fontSize: 12.5, color: Color(0x73FFFFFF)),
        ),
      ],
    );
  }

  Widget _buildPortalGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _portals.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.92,
      ),
      itemBuilder: (_, i) => _PortalCard(
        meta: _portals[i],
        isSelected: _selected == _portals[i].level,
        onTap: () => setState(() => _selected = _portals[i].level),
      ),
    );
  }

  Widget _buildSignInButton() {
    final canPress = _selected != null && !_isLoading;
    return AnimatedOpacity(
      opacity: _selected != null ? 1.0 : 0.45,
      duration: const Duration(milliseconds: 300),
      child: GestureDetector(
        onTap: canPress ? _handleSignIn : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          height: 58,
          decoration: BoxDecoration(
            gradient: canPress
                ? const LinearGradient(
                    colors: [Color(0xFF1565C0), Color(0xFF1E88E5)])
                : null,
            color: canPress ? null : const Color(0x12FFFFFF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: canPress
                  ? Colors.transparent
                  : const Color(0x21FFFFFF),
            ),
            boxShadow: canPress
                ? const [
                    BoxShadow(
                      color: Color.fromRGBO(21, 101, 192, 0.45),
                      blurRadius: 18,
                      offset: Offset(0, 6),
                    )
                  ]
                : const [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(7),
                ),
                alignment: Alignment.center,
                child: const Text('G',
                    style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4285F4))),
              ),
              const SizedBox(width: 14),
              Text(
                _selected == null
                    ? 'Select a portal to continue'
                    : 'Continue with Google',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: canPress
                      ? Colors.white
                      : const Color(0x59FFFFFF),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityNote() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0x0AFFFFFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x12FFFFFF)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.verified_user_rounded,
                size: 15, color: Color(0xCC69F0AE)),
            SizedBox(width: 7),
            Text(
              'Role-Verified Secure Access',
              style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xCC69F0AE)),
            ),
          ]),
          SizedBox(height: 7),
          Text(
            'Your Google account is validated against your pre-assigned role '
            'in Firestore. Cross-category login is strictly blocked — a '
            'Teacher account cannot access the District, State, or National portals.',
            style: TextStyle(
                fontSize: 11.5,
                color: Color(0x61FFFFFF),
                height: 1.55),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _PortalCard — individual category selection card
// ─────────────────────────────────────────────────────────────────────────────
class _PortalCard extends StatelessWidget {
  const _PortalCard({
    required this.meta,
    required this.isSelected,
    required this.onTap,
  });

  final _PortalMeta meta;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: meta.gradient,
                )
              : null,
          color: isSelected ? null : const Color(0x0DFFFFFF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? meta.glow
                : const Color(0x1CFFFFFF),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: meta.shadowColor,
                    blurRadius: 22,
                    spreadRadius: 2,
                  )
                ]
              : const [],
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                // Icon chip
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0x33FFFFFF)
                        : meta.chipColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(meta.icon,
                      color: isSelected ? Colors.white : meta.glow,
                      size: 20),
                ),
                const Spacer(),
                // Check indicator
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: isSelected
                      ? Container(
                          key: const ValueKey('check'),
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle),
                          child: Icon(Icons.check,
                              size: 11, color: meta.gradient.first),
                        )
                      : const SizedBox.shrink(key: ValueKey('empty')),
                ),
              ]),
              const Spacer(),
              Text(
                meta.title,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? Colors.white
                      : const Color(0xE0FFFFFF),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                meta.rolesLine,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9.5,
                  color: isSelected
                      ? const Color(0xB3FFFFFF)
                      : const Color(0x59FFFFFF),
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
