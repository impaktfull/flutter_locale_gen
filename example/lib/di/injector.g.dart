// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'injector.dart';

// **************************************************************************
// InjectorGenerator
// **************************************************************************

class _$Injector extends Injector {
  void registerCommonDependencies() {
    final Container container = Container();
    container.registerSingleton((c) => LocaleRepository());
  }

  void registerViewModelFactories() {
    final Container container = Container();
    container.registerFactory((c) => LocaleViewModel(c<LocaleRepository>()));
  }
}
