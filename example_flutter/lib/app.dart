import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:impaktfull_ui/impaktfull_ui.dart';
import 'package:locale_gen_example/repository/locale_repository.dart';
import 'package:locale_gen_example/screen/home_screen.dart';
import 'package:locale_gen_example/util/locale/localization_delegate.dart';
import 'package:locale_gen_example/viewmodel/locale/locale_viewmodel.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LocaleViewModel>(
      child: Consumer<LocaleViewModel>(
        builder: (context, viewModel, child) => ImpaktfullUiApp(
          title: 'Locale Gen',
          localizationsDelegates: [
            viewModel.localeDelegate,
            GlobalWidgetsLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          locale: viewModel.localeDelegate.activeLocale,
          supportedLocales: LocalizationDelegate.supportedLocales,
          home: const HomeScreen(),
        ),
      ),
      create: (context) => LocaleViewModel(LocaleRepository())..init(),
    );
  }
}
