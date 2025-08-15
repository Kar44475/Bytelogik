import 'package:bytelogik/features/home/viewmodel/home_veiwmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


void main() {
  test('counter provider initial value is 0', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(counterProvider), 0);
  });

  test('increment increments', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(counterProvider.notifier);
    notifier.state++;
    expect(container.read(counterProvider), 1);
  });

  test('decrement decrements', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(counterProvider.notifier);
    notifier.state = 2;
    notifier.state--;
    expect(container.read(counterProvider), 1);
  });

  test('reset sets to 0', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(counterProvider.notifier);
    notifier.state = 5;
    notifier.state = 0;
    expect(container.read(counterProvider), 0);
  });
}
