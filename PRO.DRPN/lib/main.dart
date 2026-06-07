import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shiksha_darpan/models/user_model.dart';
import 'package:shiksha_darpan/services/auth_service.dart';
import 'package:shiksha_darpan/services/database_service.dart';
import 'package:shiksha_darpan/screens/auth/login_screen.dart';
import 'package:shiksha_darpan/screens/attendance/teacher_dashboard_screen.dart';
import 'package:shiksha_darpan/screens/dashboard/district_dashboard_screen.dart';
import 'package:shiksha_darpan/screens/dashboard/state_dashboard_screen.dart';
import 'package:shiksha_darpan/screens/dashboard/national_dashboard_screen.dart';
import 'package:shiksha_darpan/screens/dashboard/principal_dashboard_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ShikshaDarpanApp());
}

// ─────────────────────────────────────────────────────────────────────────────
// Root application widget
// ─────────────────────────────────────────────────────────────────────────────
class ShikshaDarpanApp extends StatelessWidget {
  const ShikshaDarpanApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShikshaDarpan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const RootAuthWrapper(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RootAuthWrapper
//
// Listens to FirebaseAuth.authStateChanges().
//   • null  → no active session → show LoginScreen.
//   • User  → active session exists → fetch Firestore profile and route to
//             the appropriate dashboard (persistent login — the user is never
//             forced to log in again after their first successful sign-in).
//
// The loading splash prevents a white flash while Firestore is being queried.
// ─────────────────────────────────────────────────────────────────────────────
class RootAuthWrapper extends StatelessWidget {
  const RootAuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // ── Still waiting for the first auth event ────────────────────────────
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _SplashScreen();
        }

        // ── No logged-in user ─────────────────────────────────────────────────
        if (!snapshot.hasData || snapshot.data == null) {
          return const LoginScreen();
        }

        // ── A Firebase session exists — resolve the Firestore profile ─────────
        return _ProfileRouter(firebaseUser: snapshot.data!);
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ProfileRouter — async profile fetch → route to correct dashboard
// ─────────────────────────────────────────────────────────────────────────────
class _ProfileRouter extends StatefulWidget {
  const _ProfileRouter({required this.firebaseUser});
  final User firebaseUser;

  @override
  State<_ProfileRouter> createState() => _ProfileRouterState();
}

class _ProfileRouterState extends State<_ProfileRouter> {
  final _db = DatabaseService();

  Widget _dashboardFor(UserModel profile) {
    if (profile.role == UserRole.principal) {
      return const PrincipalDashboardScreen();
    }
    switch (profile.level) {
      case AdministrativeLevel.ground:
        return const TeacherDashboardScreen();
      case AdministrativeLevel.intermediate:
        return const DistrictDashboardScreen();
      case AdministrativeLevel.state:
        return const StateDashboardScreen();
      case AdministrativeLevel.national:
        return const NationalDashboardScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: _db.getUserProfile(widget.firebaseUser.uid),
      builder: (context, snap) {
        // ── Loading ───────────────────────────────────────────────────────────
        if (snap.connectionState == ConnectionState.waiting) {
          return const _SplashScreen();
        }

        // ── Profile found → navigate to dashboard ─────────────────────────────
        if (snap.hasData && snap.data != null) {
          return _dashboardFor(snap.data!);
        }

        // ── Profile missing (orphaned auth session) → force re-login ─────────
        // This can happen if a Firestore document was deleted manually while
        // the user had an active Firebase session.
        AuthService().signOut(); // best-effort; no await needed in build()
        return const LoginScreen();
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SplashScreen — displayed while auth state / profile is being resolved
// ─────────────────────────────────────────────────────────────────────────────
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF060B24),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.account_balance, size: 56, color: Color(0xFF4FC3F7)),
            SizedBox(height: 24),
            Text(
              'ShikshaDarpan',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 28),
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                color: Color(0xFF4FC3F7),
                strokeWidth: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
