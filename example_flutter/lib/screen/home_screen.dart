import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:locale_gen_example/util/locale/localization.dart';
import 'package:locale_gen_example/viewmodel/locale/locale_viewmodel.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = Localization.of(context);
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: const Text('locale gen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MaterialButton(
              onPressed: Provider.of<LocaleViewModel>(
                context,
              ).onSwitchToSystemLanguage,
              child: const Text('System Language (Not translated)'),
            ),
            MaterialButton(
              onPressed: Provider.of<LocaleViewModel>(
                context,
              ).onSwitchToEnglish,
              child: const Text('English (Not translated)'),
            ),
            MaterialButton(
              onPressed: Provider.of<LocaleViewModel>(context).onSwitchToDutch,
              child: const Text('Nederlands (Not translated)'),
            ),
            MaterialButton(
              onPressed: Provider.of<LocaleViewModel>(context).onSwitchToFiFi,
              child: const Text('fi-FI (Not translated)'),
            ),
            MaterialButton(
              onPressed: Provider.of<LocaleViewModel>(
                context,
              ).onSwitchToZHHansCN,
              child: const Text('zh-Hans-CN (Not translated)'),
            ),
            MaterialButton(
              onPressed: Provider.of<LocaleViewModel>(
                context,
              ).showTranslationKeys,
              child: const Text('show translation keys'),
            ),
            Container(height: 22),
            Text(localization.test),
            Text(localization.testArg1('string')),
            Text(localization.testArg2(1)),
            Text(localization.testArg3('string', 1)),
            Text(localization.testArg4('string', 1)),
            Text(localization.testNonPositional('string', 1)),
            Text(localization.testPlural(4, 4)),
            Text(localization.testPlural(1, 1)),
          ],
        ),
      ),
    );
  }
}
