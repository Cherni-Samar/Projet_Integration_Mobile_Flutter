import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:e_team/presentation/providers/cart_provider.dart';
import 'package:e_team/presentation/providers/dexo_provider.dart';
import 'package:e_team/presentation/providers/echo_provider.dart';
import 'package:e_team/presentation/providers/hera_provider.dart';
import 'package:e_team/presentation/providers/kash_provider.dart';
import 'package:e_team/presentation/providers/locale_provider.dart';
import 'package:e_team/presentation/providers/owned_agents_provider.dart';
import 'package:e_team/presentation/providers/theme_provider.dart';
import 'package:e_team/presentation/providers/timo_provider.dart';
import 'package:e_team/presentation/providers/user_provider.dart';

class AppProviders extends StatelessWidget {
  final Widget child;

  const AppProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => HeraProvider()),
        ChangeNotifierProvider(create: (_) => EchoProvider()),
        ChangeNotifierProvider(create: (_) => KashProvider()),
        ChangeNotifierProvider(create: (_) => DexoProvider()),
        ChangeNotifierProvider(create: (_) => TimoProvider()),
        ChangeNotifierProxyProvider<UserProvider, OwnedAgentsProvider>(
          create: (_) => OwnedAgentsProvider(),
          update: (_, userProvider, owned) {
            owned ??= OwnedAgentsProvider();
            owned.syncFromActiveAgents(userProvider.activeAgents);
            return owned;
          },
        ),
      ],
      child: child,
    );
  }
}
