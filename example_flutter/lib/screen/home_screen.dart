import 'package:flutter/material.dart';
import 'package:impaktfull_ui/impaktfull_ui.dart';
import 'package:locale_gen_example/util/locale/localization.dart';
import 'package:locale_gen_example/viewmodel/locale/locale_viewmodel.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = Localization.of(context);
    return ImpaktfullUiScreen(
      title: 'locale_gen',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ImpaktfullUiAutoLayout.vertical(
          spacing: 16,
          children: [
            ImpaktfullUiButton(
              type: ImpaktfullUiButtonType.primary,
              fullWidth: true,
              title: 'System Language (Not translated)',
              onAsyncTap: Provider.of<LocaleViewModel>(
                context,
              ).onSwitchToSystemLanguage,
            ),
            ImpaktfullUiButton(
              type: ImpaktfullUiButtonType.primary,
              fullWidth: true,
              title: 'English (Not translated)',
              onAsyncTap: Provider.of<LocaleViewModel>(
                context,
              ).onSwitchToEnglish,
            ),
            ImpaktfullUiButton(
              type: ImpaktfullUiButtonType.primary,
              fullWidth: true,
              title: 'Nederlands (Not translated)',
              onAsyncTap: Provider.of<LocaleViewModel>(context).onSwitchToDutch,
            ),
            ImpaktfullUiButton(
              type: ImpaktfullUiButtonType.primary,
              fullWidth: true,
              title: 'fi-FI (Not translated)',
              onAsyncTap: Provider.of<LocaleViewModel>(context).onSwitchToFiFi,
            ),
            ImpaktfullUiButton(
              type: ImpaktfullUiButtonType.primary,
              fullWidth: true,
              title: 'zh-Hans-CN (Not translated)',
              onAsyncTap: Provider.of<LocaleViewModel>(
                context,
              ).onSwitchToZHHansCN,
            ),
            ImpaktfullUiButton(
              type: ImpaktfullUiButtonType.secondary,
              fullWidth: true,
              title: 'show translation keys',
              onAsyncTap: Provider.of<LocaleViewModel>(
                context,
              ).showTranslationKeys,
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ImpaktfullUiAutoLayout.vertical(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 2,
                children: [
                  Text(localization.test),
                  Text(localization.testArg1('string')),
                  Text(localization.testArg2(1)),
                  Text(localization.testArg3('string', 1)),
                  Text(localization.testArg4('string', 1)),
                  Text(localization.testNonPositional('string', 1)),
                  Text(localization.testPlural(4, 4)),
                  Text(localization.testPlural(1, 1)),
                  Text(localization.mfGreeting(name: 'John')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
