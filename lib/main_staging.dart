import 'package:triple_vector_brawler/app/app.dart';
import 'package:triple_vector_brawler/bootstrap.dart';

Future<void> main() async {
  await bootstrap(() => const App());
}
