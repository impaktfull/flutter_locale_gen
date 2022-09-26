import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:locale_gen_example/util/locale/localization.dart';
import 'package:locale_gen_example/viewmodel/locale/locale_viewmodel.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: const Text('locale gen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MaterialButton(
              child: const Text('System Language (Not translated)'),
              onPressed: Provider.of<LocaleViewModel>(context)
                  .onSwitchToSystemLanguage,
            ),
            MaterialButton(
              child: const Text('English (Not translated)'),
              onPressed:
                  Provider.of<LocaleViewModel>(context).onSwitchToEnglish,
            ),
            MaterialButton(
              child: const Text('Nederlands (Not translated)'),
              onPressed: Provider.of<LocaleViewModel>(context).onSwitchToDutch,
            ),
            MaterialButton(
              child: const Text('fi-FI (Not translated)'),
              onPressed: Provider.of<LocaleViewModel>(context).onSwitchToFiFi,
            ),
            MaterialButton(
              child: const Text('zh-Hans-CN (Not translated)'),
              onPressed:
                  Provider.of<LocaleViewModel>(context).onSwitchToZHHansCN,
            ),
            MaterialButton(
              child: const Text('show translation keys'),
              onPressed:
                  Provider.of<LocaleViewModel>(context).showTranslationKeys,
            ),
            Container(height: 32),
            Text(Localization.test),
            Text(Localization.testArg1('string')),
            Text(Localization.testArg2(1)),
            Text(Localization.testArg3('string', 1)),
            Text(Localization.testArg4('string', 1)),
            Text(Localization.testNonPositional('string', 1)),
          ],
        ),
      ),
    );
  }
}
