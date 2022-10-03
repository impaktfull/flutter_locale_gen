import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
            Container(height: 22),
            Text(LocaleViewModel.localizationInstance.test),
            Text(LocaleViewModel.localizationInstance.testArg1('string')),
            Text(LocaleViewModel.localizationInstance.testArg2(1)),
            Text(LocaleViewModel.localizationInstance.testArg3('string', 1)),
            Text(LocaleViewModel.localizationInstance.testArg4('string', 1)),
            Text(LocaleViewModel.localizationInstance.testNonPositional('string', 1)),
            Text(LocaleViewModel.localizationInstance.testPlural(4, 4)),
            Text(LocaleViewModel.localizationInstance.testPlural(1, 1)),
          ],
        ),
      ),
    );
  }
}
