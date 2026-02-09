/*
import 'package:flutter/material.dart';
import 'package:med_shakthi/src/features/checkout/presentation/screens/address_store.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Feature Imports
import 'package:med_shakthi/src/features/dashboard/pharmacy_home_screen.dart';
import 'package:med_shakthi/src/features/auth/presentation/screens/login_page.dart';
import 'package:med_shakthi/src/features/dashboard/supplier_dashboard.dart';
import 'package:med_shakthi/src/features/cart/data/cart_data.dart';
import 'package:med_shakthi/src/features/wishlist/data/wishlist_service.dart';
import 'package:med_shakthi/src/core/theme/theme_provider.dart';
import 'package:med_shakthi/src/core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load the .env file
  await dotenv.load(fileName: ".env");

  // Initialize Supabase using values from .env
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartData()),
        ChangeNotifierProvider(create: (_) => AddressStore()),
        ChangeNotifierProvider(create: (_) => WishlistService()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Med Shakthi',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          // Use AuthGate to decide which screen to show
          home: const AuthGate(),
        );
      },
    );
  }
}

/// AUTH GATE: Decides navigation based on User Role
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isLoading = true;
  bool _isSupplier = false;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    final user = Supabase.instance.client.auth.currentUser;

    // If no user is logged in, stop loading
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      // Check if user ID exists in the 'suppliers' table
      final data = await Supabase.instance.client
          .from('suppliers')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (mounted) {
        setState(() {
          _isSupplier = data != null; // If data exists, they are a supplier
          _isLoading = false;
        });
      }
    } catch (e) {
      // On error, default to user view
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Show Loading while checking role
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF4C8077)),
        ),
      );
    }

    final user = Supabase.instance.client.auth.currentUser;

    // 2. Not Logged In -> Go to Login
    if (user == null) {
      return const LoginPage();
    }

    // 3. Logged In -> Check Role
    if (_isSupplier) {
fl      return const SupplierDashboard();
    } else {
      return const PharmacyHomeScreen();
    }
  }
}
*/

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Providers
import 'package:med_shakthi/src/features/cart/data/cart_data.dart';
import 'package:med_shakthi/src/features/checkout/presentation/screens/address_store.dart';
import 'package:med_shakthi/src/features/wishlist/data/wishlist_service.dart';

// Auth & Dashboards
import 'package:med_shakthi/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:med_shakthi/src/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:med_shakthi/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:med_shakthi/src/features/auth/presentation/screens/login_page.dart';
import 'package:med_shakthi/src/features/dashboard/pharmacy_home_screen.dart';
import 'package:med_shakthi/src/features/dashboard/supplier_dashboard.dart';

// 🔐 Reset Password Page
import 'package:med_shakthi/src/features/auth/presentation/screens/reset_password_page.dart';

/// 🔑 GLOBAL NAVIGATOR KEY (IMPORTANT)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<IAuthRepository>(
          create: (_) => AuthRepositoryImpl(Supabase.instance.client),
        ),
        ChangeNotifierProvider(
          create: (context) => AuthController(context.read<IAuthRepository>()),
        ),
        ChangeNotifierProvider(create: (_) => CartData()),
        ChangeNotifierProvider(create: (_) => AddressStore()),
        ChangeNotifierProvider(create: (_) => WishlistService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Med Shakthi',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7F9),
      ),
      home: const RootRouter(), // ✅ CORRECT
    );
  }
}

class RootRouter extends StatefulWidget {
  const RootRouter({super.key});

  @override
  State<RootRouter> createState() => _RootRouterState();
}

class _RootRouterState extends State<RootRouter> {
  Session? _session;
  bool _isRecoveringPassword = false;

  @override
  void initState() {
    super.initState();

    _session = Supabase.instance.client.auth.currentSession;

    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;

      if (!mounted) return;

      if (event == AuthChangeEvent.passwordRecovery) {
        setState(() {
          _isRecoveringPassword = true;
        });

        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const ResetPasswordPage()),
          (_) => false,
        );
        return;
      }

      setState(() {
        _session = session;
        _isRecoveringPassword = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // 🔐 PASSWORD RESET FLOW (HIGHEST PRIORITY)
    if (_isRecoveringPassword) {
      return const ResetPasswordPage();
    }

    // 🔐 NORMAL AUTH FLOW
    if (_session == null) {
      return const LoginPage();
    }

    return const AuthGate();
  }
}

/// 🔐 AUTH GATE (ROLE BASED NAVIGATION)
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isLoading = true;
  bool _isSupplier = false;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final data = await Supabase.instance.client
          .from('suppliers')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (mounted) {
        setState(() {
          _isSupplier = data != null;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ⏳ Loading
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF4C8077)),
        ),
      );
    }

    final user = Supabase.instance.client.auth.currentUser;

    // 🔐 Not logged in
    if (user == null) {
      return const LoginPage();
    }

    // 🧑‍⚕️ Supplier vs User
    if (_isSupplier) {
      return const SupplierDashboard();
    } else {
      return const PharmacyHomeScreen();
    }
  }
}
