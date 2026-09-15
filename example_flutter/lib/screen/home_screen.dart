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
    final viewModel = Provider.of<LocaleViewModel>(context);
    final delegate = viewModel.localeDelegate;
    final showKeys = delegate.showLocalizationKeys;
    final activeTag = showKeys
        ? 'keys'
        : delegate.newLocale?.toLanguageTag() ?? 'system';

    Widget localeButton(
      String id,
      String title,
      Future<void> Function() onTap,
    ) {
      return Expanded(
        // Keyed so `integration_test/docs_media_test.dart` can tap it.
        child: KeyedSubtree(
          key: ValueKey('locale_$id'),
          child: ImpaktfullUiButton(
            type: activeTag == id
                ? ImpaktfullUiButtonType.primary
                : ImpaktfullUiButtonType.secondary,
            fullWidth: true,
            title: title,
            onAsyncTap: onTap,
          ),
        ),
      );
    }

    return ImpaktfullUiScreen(
      title: 'locale_gen',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: ImpaktfullUiAutoLayout.vertical(
          spacing: 10,
          children: [
            ImpaktfullUiAutoLayout.horizontal(
              spacing: 8,
              children: [
                localeButton(
                  'system',
                  'System',
                  viewModel.onSwitchToSystemLanguage,
                ),
                localeButton('en', 'English', viewModel.onSwitchToEnglish),
                localeButton('nl', 'Nederlands', viewModel.onSwitchToDutch),
              ],
            ),
            ImpaktfullUiAutoLayout.horizontal(
              spacing: 8,
              children: [
                localeButton('fi-FI', 'Suomi', viewModel.onSwitchToFiFi),
                localeButton(
                  'zh-Hans-CN',
                  '简体中文',
                  viewModel.onSwitchToZHHansCN,
                ),
                localeButton('keys', 'Keys', viewModel.showTranslationKeys),
              ],
            ),
            _Section(
              title: 'ICU MessageFormat',
              rows: [
                ('mf_greeting', localization.mfGreeting(name: 'John')),
                (
                  'mf_cart_count (1, 3)',
                  '${localization.mfCartCount(count: 1)} · ${localization.mfCartCount(count: 3)}',
                ),
                ('mf_pronoun', localization.mfPronoun(gender: 'female')),
                (
                  'mf_rank (1, 2, 3)',
                  '${localization.mfRank(place: 1)} · ${localization.mfRank(place: 2)} · ${localization.mfRank(place: 3)}',
                ),
                ('mf_total', localization.mfTotal(total: 1234.56)),
                (
                  'mf_placed_at · mf_meeting_at',
                  '${localization.mfPlacedAt(placedAt: DateTime(2026, 9, 15))} · ${localization.mfMeetingAt(at: DateTime(2026, 9, 15, 14, 30))}',
                ),
                (
                  'mf_race',
                  localization.mfRace(
                    d: const Duration(minutes: 1, seconds: 42),
                  ),
                ),
              ],
            ),
            _Section(
              title: 'sprintf',
              rows: [
                ('test (overridden at runtime)', localization.test),
                ('test_arg3', localization.testArg3('John', 3)),
                (
                  'test_non_positional',
                  localization.testNonPositional('John', 2.5),
                ),
              ],
            ),
            _Section(
              title: 'JSON-object plural (legacy)',
              rows: [
                (
                  'test_plural (1, 4)',
                  '${localization.testPlural(1, 1)} · ${localization.testPlural(4, 4)}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<(String, String)> rows;

  const _Section({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4E4EA)),
      ),
      child: ImpaktfullUiAutoLayout.vertical(
        spacing: 6,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6E56CF),
            ),
          ),
          for (final (key, value) in rows)
            ImpaktfullUiAutoLayout.vertical(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  key,
                  style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'Menlo',
                    color: Color(0xFF8A8A99),
                  ),
                ),
                Text(value, style: const TextStyle(fontSize: 15)),
              ],
            ),
        ],
      ),
    );
  }
}
