import 'package:voiceflow_notes/core/utils/result.dart';

abstract class UseCase<Type, Params> {
  Future<Result<Type>> call(Params params);
}

class NoParams {
  const NoParams();
}
