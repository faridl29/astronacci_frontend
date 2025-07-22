import 'package:astronacci/blocs/auth/auth_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app.dart';
import 'services/api_service.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/user/user_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: apiService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                AuthBloc(apiService: apiService)..add(AuthStarted()),
          ),
          BlocProvider(
            create: (context) => UserBloc(apiService: apiService),
          ),
        ],
        child: MaterialApp.router(
          title: 'User Management App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            textTheme: GoogleFonts.poppinsTextTheme(),
            useMaterial3: true,
          ),
          routerConfig: AppRouter.router,
        ),
      ),
    );
  }
}
