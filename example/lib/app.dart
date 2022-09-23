import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:locale_gen_example/repository/locale_repository.dart';
import 'package:locale_gen_example/screen/home_screen.dart';
import 'package:locale_gen_example/util/locale/localization.dart';
import 'package:locale_gen_example/viewmodel/locale/locale_viewmodel.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LocaleViewModel>(
      child: Consumer<LocaleViewModel>(
        builder: (context, value, child) => MaterialApp(
          title: 'Locale Gen',
          theme: ThemeData(
            primarySwatch: Colors.red,
          ),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          locale: Localization.locale,
          supportedLocales: Localization.supportedLocales,
          home: HomeScreen(),
        ),
      ),
      create: (context) => LocaleViewModel(LocaleRepository())..init(),
    );
  }
}
