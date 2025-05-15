import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'data/datasources/failure_remote_data_source.dart';
import 'data/repositories/failure_repository_impl.dart';
import 'presentation/providers/failure_provider.dart';
import 'presentation/providers/pie_chart_provider.dart';
import 'presentation/pages/home_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/deformat_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final client = http.Client();
            final remoteDataSource =
                FailureRemoteDataSourceImpl(client: client);
            final repository =
                FailureRepositoryImpl(remoteDataSource: remoteDataSource);
            return FailureProvider(repository: repository);
          },
        ),
        ChangeNotifierProvider(create: (_) => PieChartProvider()),
        ChangeNotifierProvider(create: (_) => DeformatProvider()),
      ],
      child: MaterialApp(
        title: 'Limo-KPI',
        theme: AppTheme.lightTheme,
        locale: const Locale('uk', 'UA'),
        supportedLocales: const [
          Locale('uk', 'UA'),
          Locale('en', 'US'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        debugShowCheckedModeBanner: false,
        home: const HomePage(),
      ),
    );
  }
}
