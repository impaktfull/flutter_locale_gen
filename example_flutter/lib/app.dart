import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:impaktfull_ui/impaktfull_ui.dart';
import 'package:locale_gen_example/repository/locale_repository.dart';
import 'package:locale_gen_example/screen/home_screen.dart';
import 'package:locale_gen_example/util/locale/localization_delegate.dart';
import 'package:locale_gen_example/viewmodel/locale/locale_viewmodel.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  final bool showDebugFlag;

  const MyApp({super.key, this.showDebugFlag = kDebugMode});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LocaleViewModel>(
      child: Consumer<LocaleViewModel>(
        builder: (context, viewModel, child) => ImpaktfullUiApp(
          title: 'Locale Gen',
          showDebugFlag: showDebugFlag,
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
