import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:bytelogik/core/storage/offline_storage_helper.dart';

part 'database_provider.g.dart';
@Riverpod(keepAlive: true) 
OfflineStorageHelper database(Ref ref) {
  final helper = OfflineStorageHelper.instance;
  ref.onDispose(() {
    helper.close();
  });
  return helper;
}
