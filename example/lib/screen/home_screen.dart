import 'package:flutter/material.dart';
import 'package:locale_gen_example/util/locale/localization.dart';
import 'package:locale_gen_example/viewmodel/locale/locale_viewmodel.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('locale gen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlatButton(
              child: const Text('System Language (Not translated)'),
              onPressed: Provider.of<LocaleViewModel>(context)
                  .onSwitchToSystemLanguage,
            ),
            FlatButton(
              child: const Text('English (Not translated)'),
              onPressed:
                  Provider.of<LocaleViewModel>(context).onSwitchToEnglish,
            ),
            FlatButton(
              child: const Text('Nederlands (Not translated)'),
              onPressed: Provider.of<LocaleViewModel>(context).onSwitchToDutch,
            ),
            Container(height: 32),
            Text(Localization.of(context).test),
            Text(Localization.of(context).testArg1('string')),
            Text(Localization.of(context).testArg2(1.0)),
            Text(Localization.of(context).testArg3('string', 1.0)),
            Text(Localization.of(context).testArg4('string', 1.0)),
          ],
        ),
      ),
    );
  }
}
