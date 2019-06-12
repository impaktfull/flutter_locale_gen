import 'package:kiwi/kiwi.dart';
import 'package:locale_gen_example/repository/locale_repository.dart';
import 'package:locale_gen_example/viewmodel/locale/locale_viewmodel.dart';

part 'injector.g.dart';

abstract class Injector {
  @Register.singleton(LocaleRepository)
  void registerCommonDependencies();

  @Register.factory(LocaleViewModel)
  void registerViewModelFactories();
}

void setupDependencyTree() {
  _$Injector()
    ..registerCommonDependencies()
    ..registerViewModelFactories();
}
